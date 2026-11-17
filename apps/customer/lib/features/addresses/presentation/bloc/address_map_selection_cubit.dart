import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/features/maps/domain/maps_repository.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// The map only selects coordinates. AddressEditorCubit continues to own
/// validation, address persistence, and the saved-address domain contract.
final class AddressMapSelectionState {
  const AddressMapSelectionState({
    this.location,
    this.locating = false,
    this.locationFailed = false,
  });

  final TripLocation? location;
  final bool locating;
  final bool locationFailed;
}

final class AddressMapSelectionCubit extends Cubit<AddressMapSelectionState> {
  AddressMapSelectionCubit({
    required MapsRepository repository,
    required DeviceLocation deviceLocation,
    required String language,
    required bool reverseAvailable,
    TripLocation? initialLocation,
  }) : _repository = repository,
       _deviceLocation = deviceLocation,
       _language = language,
       _reverseAvailable = reverseAvailable,
       super(AddressMapSelectionState(location: initialLocation));

  final MapsRepository _repository;
  final DeviceLocation _deviceLocation;
  final String _language;
  final bool _reverseAvailable;
  Timer? _reverseTimer;
  int _selectionRevision = 0;
  int _locateRevision = 0;

  /// A coordinate label is accurate even when reverse geocoding is not
  /// configured or the device is offline. It is never presented as an address.
  static String coordinates(GeoPoint point) =>
      '${point.latitude.toStringAsFixed(5)}, '
      '${point.longitude.toStringAsFixed(5)}';

  void select(GeoPoint point) {
    if (isClosed) return;
    final revision = ++_selectionRevision;
    ++_locateRevision;
    _reverseTimer?.cancel();
    emit(
      AddressMapSelectionState(
        location: TripLocation(label: coordinates(point), point: point),
      ),
    );
    if (!_reverseAvailable) return;

    // Debounce repeated selection updates caused by map drags.
    _reverseTimer = Timer(const Duration(milliseconds: 400), () async {
      try {
        final resolved = await _repository.reverse(point, language: _language);
        if (isClosed || revision != _selectionRevision) return;
        if (resolved.point != point || resolved.label.trim().isEmpty) return;
        emit(AddressMapSelectionState(location: resolved));
      } catch (_) {
        // Preserve the actual selected coordinate; no fabricated street name.
      }
    });
  }

  Future<void> locate() async {
    if (isClosed || state.locating) return;
    final request = ++_locateRevision;
    emit(AddressMapSelectionState(location: state.location, locating: true));
    try {
      final point = await _deviceLocation.locate();
      if (isClosed || request != _locateRevision) return;
      select(point);
    } catch (_) {
      if (isClosed || request != _locateRevision) return;
      emit(
        AddressMapSelectionState(
          location: state.location,
          locationFailed: true,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    ++_selectionRevision;
    ++_locateRevision;
    _reverseTimer?.cancel();
    return super.close();
  }
}
