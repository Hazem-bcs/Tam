import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/features/maps/domain/foreground_location.dart';
import 'package:tam_customer/features/maps/domain/location_fix.dart';
import 'package:tam_customer/features/maps/domain/maps_repository.dart';
import 'package:tam_customer/features/maps/presentation/widgets/map_camera_focus.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// Distinguishes the device's camera focus from the user's chosen address.
/// Merely centering on GPS never silently selects an address for saving.
final class AddressMapSelectionState {
  const AddressMapSelectionState({
    this.location,
    this.focus,
    this.locating = false,
    this.locationFailed = false,
  });

  final TripLocation? location;
  final MapCameraFocus? focus;
  final bool locating;
  final bool locationFailed;
}

final class AddressMapSelectionCubit extends Cubit<AddressMapSelectionState> {
  AddressMapSelectionCubit({
    required MapsRepository repository,
    required DeviceLocation deviceLocation,
    required String language,
    required bool reverseAvailable,
    ForegroundLocation? sharedLocation,
    TripLocation? initialLocation,
  }) : _repository = repository,
       _deviceLocation = deviceLocation,
       _language = language,
       _reverseAvailable = reverseAvailable,
       _sharedLocation = sharedLocation,
       _followingDevice = initialLocation == null,
       super(
         AddressMapSelectionState(
           location: initialLocation,
           focus: _initialFocus(initialLocation, sharedLocation),
         ),
       ) {
    _deviceUpdates = _sharedLocation?.positionUpdates.listen(_deviceMoved);
  }

  static MapCameraFocus? _initialFocus(
    TripLocation? selected,
    ForegroundLocation? shared,
  ) {
    final point = selected?.point ?? shared?.cachedPoint;
    return point == null ? null : MapCameraFocus(point, 0);
  }

  final MapsRepository _repository;
  final DeviceLocation _deviceLocation;
  final ForegroundLocation? _sharedLocation;
  final String _language;
  final bool _reverseAvailable;
  StreamSubscription<GeoPoint>? _deviceUpdates;
  Timer? _reverseTimer;
  int _selectionRevision = 0;
  int _locateRevision = 0;
  int _focusRevision = 0;
  bool _followingDevice;

  static String coordinates(GeoPoint point) =>
      '${point.latitude.toStringAsFixed(5)}, '
      '${point.longitude.toStringAsFixed(5)}';

  /// Called once when the editor opens. Uses a fresh session fix instantly;
  /// if missing, reuses the app's sensor without another permission prompt.
  void centerOnKnownLocation() {
    if (isClosed || !_followingDevice || _sharedLocation == null) return;
    final cached = _sharedLocation.cachedPoint;
    if (cached != null) {
      _deviceMoved(cached);
      return;
    }
    unawaited(
      _sharedLocation.locateWithoutPrompt().then(
        _deviceMoved,
        onError: (Object _, StackTrace __) {
          // The map keeps its configured fallback center if permission is absent.
        },
      ),
    );
  }

  void _deviceMoved(GeoPoint point) {
    if (isClosed || !_followingDevice) return;
    final previous = state.focus?.point;
    if (previous != null &&
        locationDistanceMeters(previous, point) <
            (_sharedLocation?.policy.updateDistanceMeters ?? 20)) {
      return;
    }
    emit(
      AddressMapSelectionState(
        location: state.location,
        focus: MapCameraFocus(point, ++_focusRevision),
        locating: state.locating,
      ),
    );
  }

  void select(GeoPoint point, {bool recenter = false}) {
    if (isClosed) return;
    _followingDevice = false;
    final revision = ++_selectionRevision;
    ++_locateRevision;
    _reverseTimer?.cancel();
    final focus = recenter
        ? MapCameraFocus(point, ++_focusRevision)
        : state.focus;
    emit(
      AddressMapSelectionState(
        location: TripLocation(label: coordinates(point), point: point),
        focus: focus,
      ),
    );
    if (!_reverseAvailable) return;

    _reverseTimer = Timer(const Duration(milliseconds: 400), () async {
      try {
        final resolved = await _repository.reverse(point, language: _language);
        if (isClosed || revision != _selectionRevision) return;
        if (resolved.point != point || resolved.label.trim().isEmpty) return;
        emit(AddressMapSelectionState(location: resolved, focus: state.focus));
      } catch (_) {
        // Keep exact coordinates internally; never invent a street address.
      }
    });
  }

  Future<void> locate() async {
    if (isClosed || state.locating) return;
    final request = ++_locateRevision;
    emit(
      AddressMapSelectionState(
        location: state.location,
        focus: state.focus,
        locating: true,
      ),
    );
    try {
      final point = await _deviceLocation.locate();
      if (isClosed || request != _locateRevision) return;
      select(point, recenter: true);
    } catch (_) {
      if (isClosed || request != _locateRevision) return;
      emit(
        AddressMapSelectionState(
          location: state.location,
          focus: state.focus,
          locationFailed: true,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    ++_selectionRevision;
    ++_locateRevision;
    _reverseTimer?.cancel();
    await _deviceUpdates?.cancel();
    await super.close();
  }
}
