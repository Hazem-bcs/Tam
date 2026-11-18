import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/core/config/app_config.dart';
import 'package:tam_customer/features/maps/domain/location_fix.dart';
import 'package:tam_customer/features/maps/domain/maps_repository.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';

final class RideLocationState {
  const RideLocationState({
    this.fix,
    this.focusPoint,
    this.fixRevision = 0,
    this.focusRevision = 0,
    this.locating = false,
    this.failure,
    this.point,
    this.address,
    this.resolving = false,
  });
  final int fixRevision, focusRevision;
  final GeoPoint? fix, point, focusPoint;
  final String? failure, address;
  final bool locating, resolving;

  RideLocationState copy({
    GeoPoint? fix,
    GeoPoint? focusPoint,
    int? fixRevision,
    int? focusRevision,
    bool? locating,
    String? failure,
    GeoPoint? point,
    String? address,
    bool? resolving,
    bool clearPoint = false,
  }) => RideLocationState(
    fix: fix ?? this.fix,
    focusPoint: focusPoint ?? this.focusPoint,
    fixRevision: fixRevision ?? this.fixRevision,
    focusRevision: focusRevision ?? this.focusRevision,
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

  Future<void> locate({
    bool requireFresh = false,
    bool focusMap = false,
  }) async {
    if (isClosed || state.locating) return;
    final epoch = ++_fixEpoch;
    final selectedAtRequest = _pointEpoch;
    emit(state.copy(locating: true, address: state.address));
    try {
      final fix = await device.locate(requireFresh: requireFresh);
      if (!isClosed && epoch == _fixEpoch) {
        final focus = focusMap && selectedAtRequest == _pointEpoch;
        if (focus) _pointEpoch++;
        emit(
          state.copy(
            fix: fix,
            focusPoint: focus ? fix : state.focusPoint,
            fixRevision: state.fixRevision + 1,
            focusRevision: state.focusRevision + (focus ? 1 : 0),
            clearPoint: focus,
            resolving: focus ? false : state.resolving,
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
    emit(state.copy(point: point, resolving: true, failure: state.failure));
    try {
      final location = await repository.reverse(point, language: language);
      if (location.point != point) throw const MapsFailure('INVALID_RESPONSE');
      if (!isClosed && epoch == _pointEpoch) {
        emit(
          state.copy(
            address: location.label,
            resolving: false,
            failure: state.failure,
          ),
        );
      }
    } catch (_) {
      // Exact coordinates remain usable without a reverse-geocoding server.
      if (!isClosed && epoch == _pointEpoch) {
        emit(state.copy(resolving: false, failure: state.failure));
      }
    }
  }

  void clearPoint() {
    if (isClosed) return;
    _pointEpoch++;
    emit(
      state.copy(clearPoint: true, resolving: false, failure: state.failure),
    );
  }

  Future<void> openSettings({String? failure}) async {
    if (isClosed) return;
    _returningFromSettings = true;
    try {
      final opened =
          const {
            'LOCATION_DENIED_FOREVER',
            'LOCATION_PRECISE_REQUIRED',
          }.contains(failure ?? state.failure)
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
    locate(requireFresh: true, focusMap: true);
  }

  @override
  Future<void> close() {
    _fixEpoch++;
    _pointEpoch++;
    return super.close();
  }
}
