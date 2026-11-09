import 'package:equatable/equatable.dart';
import 'package:tam_customer/shared/domain/trip.dart';

const _same = Object();

enum ActiveTripPhase { loading, ready, empty, failed }

final class ActiveTripState extends Equatable {
  const ActiveTripState({
    this.phase = ActiveTripPhase.loading,
    this.trip,
    this.refreshing = false,
    this.cancelling = false,
    this.cancelUncertain = false,
    this.offline = false,
    this.positionStale = false,
    this.failure,
    this.actionFailure,
    this.lastSyncedAt,
  });
  final ActiveTripPhase phase;
  final Trip? trip;
  final bool refreshing, cancelling, cancelUncertain, offline, positionStale;
  final String? failure, actionFailure;
  final DateTime? lastSyncedAt;
  bool get canCancel =>
      trip != null &&
      trip!.canCancel &&
      !offline &&
      !cancelling &&
      !cancelUncertain;
  bool get canRebook =>
      trip != null && !trip!.status.isActive && !cancelling && !cancelUncertain;
  ActiveTripState copyWith({
    ActiveTripPhase? phase,
    Object? trip = _same,
    bool? refreshing,
    bool? cancelling,
    bool? cancelUncertain,
    bool? offline,
    bool? positionStale,
    Object? failure = _same,
    Object? actionFailure = _same,
    DateTime? lastSyncedAt,
  }) => ActiveTripState(
    phase: phase ?? this.phase,
    trip: identical(trip, _same) ? this.trip : trip as Trip?,
    refreshing: refreshing ?? this.refreshing,
    cancelling: cancelling ?? this.cancelling,
    cancelUncertain: cancelUncertain ?? this.cancelUncertain,
    offline: offline ?? this.offline,
    positionStale: positionStale ?? this.positionStale,
    failure: identical(failure, _same) ? this.failure : failure as String?,
    actionFailure: identical(actionFailure, _same)
        ? this.actionFailure
        : actionFailure as String?,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
  );
  @override
  List<Object?> get props => [
    phase,
    trip,
    refreshing,
    cancelling,
    cancelUncertain,
    offline,
    positionStale,
    failure,
    actionFailure,
    lastSyncedAt,
  ];
}
