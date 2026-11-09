import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/features/active_trip/domain/active_trip_repository.dart';
import 'package:tam_customer/features/active_trip/presentation/bloc/active_trip_state.dart';
import 'package:tam_customer/shared/domain/trip.dart';

export 'active_trip_state.dart';

final class ActiveTripCubit extends Cubit<ActiveTripState> {
  ActiveTripCubit(
    this._repository, {
    String? tripId,
    this.policy = const ActiveTripPolicy(),
    DateTime Function()? now,
    bool poll = true,
  }) : _tripId = tripId,
       _now = now ?? DateTime.now,
       super(const ActiveTripState()) {
    _subscription = _repository.changes.listen((_) {
      if (state.trip?.status.isActive ?? true) unawaited(refresh(silent: true));
    }, onError: (_) => _connectionFailure('NETWORK_ERROR'));
    if (poll) {
      _timer = Timer.periodic(policy.pollInterval, (_) {
        checkFreshness();
        unawaited(refresh(silent: true));
      });
    }
    unawaited(refresh());
  }
  final ActiveTripRepository _repository;
  final ActiveTripPolicy policy;
  final DateTime Function() _now;
  String? _tripId;
  late final StreamSubscription<void> _subscription;
  Timer? _timer;
  bool _loading = false, _dirty = false;
  int _epoch = 0;

  void checkFreshness() {
    if (isClosed || state.trip == null) return;
    final now = _now().toUtc();
    final last = state.lastSyncedAt;
    final position = state.trip!.live?.position;
    final stale =
        position != null &&
        now.difference(position.recordedAt) > policy.positionStaleAfter;
    final offline =
        state.offline ||
        (last != null && now.difference(last) > policy.staleAfter);
    emit(
      state.copyWith(
        offline: offline,
        positionStale: stale,
        failure: offline ? state.failure ?? 'STALE_DATA' : state.failure,
      ),
    );
  }

  Future<void> refresh({bool silent = false}) async {
    if (isClosed) return;
    if (_loading) {
      _dirty = true;
      return;
    }
    _loading = true;
    final epoch = _epoch;
    if (!silent) emit(state.copyWith(refreshing: true));
    try {
      final result = _tripId == null
          ? await _repository.current()
          : await _repository.fetch(_tripId!);
      if (isClosed || epoch != _epoch) return;
      if (result == null) {
        emit(
          state.copyWith(
            phase: ActiveTripPhase.empty,
            trip: null,
            refreshing: false,
            offline: false,
            failure: null,
          ),
        );
        return;
      }
      _accept(result);
    } on ActiveTripFailure catch (failure) {
      if (!isClosed && epoch == _epoch) _connectionFailure(failure.code);
    } on FormatException {
      if (!isClosed && epoch == _epoch) _connectionFailure('INVALID_RESPONSE');
    } finally {
      _loading = false;
      if (_dirty && !isClosed) {
        _dirty = false;
        unawaited(refresh(silent: true));
      }
    }
  }

  bool _accept(Trip trip) {
    final live = trip.live;
    if (live == null || (_tripId != null && trip.id != _tripId)) {
      _connectionFailure('INVALID_RESPONSE');
      return false;
    }
    final previous = state.trip;
    final old = previous?.live;
    if (old != null && live.revision < old.revision) {
      emit(state.copyWith(refreshing: false));
      return false;
    }
    if (old != null && live.revision == old.revision && previous != trip) {
      _connectionFailure('INVALID_RESPONSE');
      return false;
    }
    _tripId = trip.id;
    final now = _now().toUtc();
    final resolved = !trip.canCancel;
    emit(
      state.copyWith(
        phase: ActiveTripPhase.ready,
        trip: trip,
        refreshing: false,
        offline: false,
        failure: null,
        lastSyncedAt: now,
        cancelUncertain: resolved ? false : state.cancelUncertain,
        actionFailure: state.cancelUncertain && resolved
            ? trip.status == TripStatus.cancelled
                  ? null
                  : 'TRIP_NOT_CANCELLABLE'
            : state.actionFailure,
        positionStale:
            live.position != null &&
            now.difference(live.position!.recordedAt) >
                policy.positionStaleAfter,
      ),
    );
    if (!trip.status.isActive) _timer?.cancel();
    return true;
  }

  void _connectionFailure(String code) {
    if (isClosed) return;
    emit(
      state.copyWith(
        phase: state.trip == null
            ? ActiveTripPhase.failed
            : ActiveTripPhase.ready,
        refreshing: false,
        offline: true,
        failure: code,
      ),
    );
  }

  Future<void> cancel() async {
    final trip = state.trip;
    if (trip == null ||
        state.cancelling ||
        (!state.canCancel && !state.cancelUncertain)) {
      return;
    }
    _epoch++;
    emit(state.copyWith(cancelling: true, actionFailure: null));
    try {
      final updated = await _repository.cancel(trip.id);
      if (isClosed) return;
      if (updated.id != trip.id || updated.status != TripStatus.cancelled) {
        throw const ActiveTripFailure('INVALID_RESPONSE');
      }
      _epoch++;
      final accepted = _accept(updated);
      emit(
        state.copyWith(
          cancelling: false,
          cancelUncertain: !accepted || updated.canCancel,
          actionFailure: accepted && !updated.canCancel
              ? null
              : 'INVALID_RESPONSE',
        ),
      );
    } on ActiveTripFailure catch (failure) {
      if (isClosed) return;
      final latest = state.trip;
      if (latest != null &&
          latest.id == trip.id &&
          !latest.canCancel &&
          latest.live!.revision > trip.live!.revision) {
        emit(
          state.copyWith(
            cancelling: false,
            cancelUncertain: false,
            actionFailure: latest.status == TripStatus.cancelled
                ? null
                : 'TRIP_NOT_CANCELLABLE',
          ),
        );
        return;
      }
      final definitive = {
        'TRIP_NOT_CANCELLABLE',
        'TRIP_NOT_FOUND',
        'FORBIDDEN',
        'UNAUTHENTICATED',
        'VALIDATION_ERROR',
      }.contains(failure.code);
      emit(
        state.copyWith(
          cancelling: false,
          cancelUncertain: !definitive,
          actionFailure: failure.code,
        ),
      );
      if (definitive) unawaited(refresh());
    }
  }

  @override
  Future<void> close() async {
    _epoch++;
    _timer?.cancel();
    await _subscription.cancel();
    await super.close();
  }
}
