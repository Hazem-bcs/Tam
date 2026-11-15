import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/core/config/app_config.dart';
import 'package:tam_customer/features/maps/domain/location_fix.dart';
import 'package:tam_customer/features/maps/domain/maps_repository.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';

final class RideLocationState {
  const RideLocationState({
    this.fix,
    this.fixRevision = 0,
    this.locating = false,
    this.failure,
    this.point,
    this.address,
    this.resolving = false,
  });
  final int fixRevision;
  final GeoPoint? fix, point;
  final String? failure, address;
  final bool locating, resolving;

  RideLocationState copy({
    GeoPoint? fix,
    int? fixRevision,
    bool? locating,
    String? failure,
    GeoPoint? point,
    String? address,
    bool? resolving,
    bool clearPoint = false,
  }) => RideLocationState(
    fix: fix ?? this.fix,
    fixRevision: fixRevision ?? this.fixRevision,
    locating: locating ?? this.locating,
    failure: failure,
    point: clearPoint ? null : point ?? this.point,
    address: clearPoint ? null : address,
    resolving: resolving ?? this.resolving,
  );
}

enum PickupValidation { unchanged, moved, unavailable }

/// Consumes the app's shared location; manual edits always win pending reads.
final class RideLocationCubit extends Cubit<RideLocationState> {
  RideLocationCubit({
    required this.repository,
    required this.device,
    required this.settings,
    required this.language,
    this.policy = AppConfig.locationPolicy,
  }) : super(const RideLocationState());
  final MapsRepository repository;
  final DeviceLocation device;
  final DeviceLocationSettings settings;
  final String language;
  final LocationPolicy policy;
  int _fixEpoch = 0, _pointEpoch = 0;
  bool _returningFromSettings = false;

  Future<void> locate({bool requireFresh = false}) async {
    if (isClosed || state.locating) return;
    final epoch = ++_fixEpoch;
    emit(state.copy(locating: true, address: state.address));
    try {
      final fix = await device.locate(requireFresh: requireFresh);
      if (!isClosed && epoch == _fixEpoch) {
        emit(
          state.copy(
            fix: fix,
            fixRevision: state.fixRevision + 1,
            locating: false,
            address: state.address,
          ),
        );
      }
    } catch (error) {
      if (!isClosed && epoch == _fixEpoch) {
        emit(
          state.copy(
            locating: false,
            failure: error is MapsFailure ? error.code : 'LOCATION_UNAVAILABLE',
            address: state.address,
          ),
        );
      }
    }
  }

  /// Called before sending a manual pickup to the draft, even in the same frame.
  void keepManualPickup() {
    if (isClosed) return;
    _fixEpoch++;
    emit(state.copy(locating: false, address: state.address));
  }

  /// Revalidate a GPS-origin draft at the booking boundary. Small device jitter
  /// preserves the reviewed pickup; meaningful movement requires a new quote.
  Future<PickupValidation> validatePickup(GeoPoint pickup) async {
    if (isClosed || state.locating) return PickupValidation.unavailable;
    final revision = state.fixRevision;
    await locate(requireFresh: true);
    if (isClosed ||
        state.failure != null ||
        state.fixRevision == revision ||
        state.fix == null) {
      return PickupValidation.unavailable;
    }
    return locationDistanceMeters(pickup, state.fix!) >
            policy.pickupMovementMeters
        ? PickupValidation.moved
        : PickupValidation.unchanged;
  }

  Future<void> selectPoint(GeoPoint point) async {
    if (isClosed) return;
    final epoch = ++_pointEpoch;
    emit(state.copy(point: point, resolving: true));
    try {
      final location = await repository.reverse(point, language: language);
      if (location.point != point) throw const MapsFailure('INVALID_RESPONSE');
      if (!isClosed && epoch == _pointEpoch) {
        emit(state.copy(address: location.label, resolving: false));
      }
    } catch (_) {
      // Exact coordinates remain usable without a reverse-geocoding server.
      if (!isClosed && epoch == _pointEpoch) {
        emit(state.copy(resolving: false));
      }
    }
  }

  void clearPoint() {
    if (isClosed) return;
    _pointEpoch++;
    emit(state.copy(clearPoint: true, resolving: false));
  }

  Future<void> openSettings() async {
    if (isClosed) return;
    _returningFromSettings = true;
    try {
      final opened = state.failure == 'LOCATION_DENIED_FOREVER'
          ? await settings.openAppSettings()
          : await settings.openLocationSettings();
      if (!opened && !isClosed) {
        _returningFromSettings = false;
        emit(
          state.copy(failure: 'LOCATION_UNAVAILABLE', address: state.address),
        );
      }
    } catch (_) {
      if (!isClosed) {
        _returningFromSettings = false;
        emit(
          state.copy(failure: 'LOCATION_UNAVAILABLE', address: state.address),
        );
      }
    }
  }

  void resumed() {
    if (!_returningFromSettings || isClosed) return;
    _returningFromSettings = false;
    locate();
  }

  @override
  Future<void> close() {
    _fixEpoch++;
    _pointEpoch++;
    return super.close();
  }
}
