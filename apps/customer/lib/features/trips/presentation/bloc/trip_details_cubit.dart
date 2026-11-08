import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/features/trips/domain/trips_repository.dart';
import 'package:tam_customer/shared/domain/trip.dart';

const _unchanged = Object();

final class TripDetailsState extends Equatable {
  const TripDetailsState({
    this.trip,
    this.isLoading = true,
    this.isCancelling = false,
    this.isNotFound = false,
    this.errorCode,
    this.actionErrorCode,
  });

  final Trip? trip;
  final bool isLoading;
  final bool isCancelling;
  final bool isNotFound;
  final String? errorCode;
  final String? actionErrorCode;

  TripDetailsState copyWith({
    Object? trip = _unchanged,
    bool? isLoading,
    bool? isCancelling,
    bool? isNotFound,
    Object? errorCode = _unchanged,
    Object? actionErrorCode = _unchanged,
  }) => TripDetailsState(
    trip: identical(trip, _unchanged) ? this.trip : trip as Trip?,
    isLoading: isLoading ?? this.isLoading,
    isCancelling: isCancelling ?? this.isCancelling,
    isNotFound: isNotFound ?? this.isNotFound,
    errorCode: identical(errorCode, _unchanged)
        ? this.errorCode
        : errorCode as String?,
    actionErrorCode: identical(actionErrorCode, _unchanged)
        ? this.actionErrorCode
        : actionErrorCode as String?,
  );

  @override
  List<Object?> get props => [
    trip,
    isLoading,
    isCancelling,
    isNotFound,
    errorCode,
    actionErrorCode,
  ];
}

final class TripDetailsCubit extends Cubit<TripDetailsState> {
  TripDetailsCubit(this._repository, this.tripId)
    : super(const TripDetailsState()) {
    _subscription = _repository.changes.listen((_) {
      unawaited(reload(silent: true));
    });
    unawaited(reload());
  }

  final TripsRepository _repository;
  final String tripId;
  late final StreamSubscription<void> _subscription;
  int _revision = 0;

  Future<void> reload({bool silent = false}) async {
    final revision = ++_revision;
    if (!silent) {
      emit(state.copyWith(isLoading: true, errorCode: null));
    }
    try {
      final trip = await _repository.find(tripId);
      if (isClosed || revision != _revision) return;
      emit(
        state.copyWith(
          trip: trip,
          isNotFound: trip == null,
          isLoading: false,
          errorCode: null,
        ),
      );
    } on TripsFailure catch (failure) {
      if (isClosed || revision != _revision) return;
      emit(state.copyWith(isLoading: false, errorCode: failure.code));
    }
  }

  /// Never cancel a completed/in-progress trip; repeated cancelled is blocked.
  Future<bool> cancel() async {
    final trip = state.trip;
    if (state.isCancelling || trip == null || !trip.canCancel) return false;
    emit(state.copyWith(isCancelling: true, actionErrorCode: null));
    try {
      final updated = await _repository.cancel(trip.id);
      if (isClosed) return false;
      emit(
        state.copyWith(
          trip: updated,
          isCancelling: false,
          actionErrorCode: null,
        ),
      );
      return true;
    } on TripsFailure catch (failure) {
      if (isClosed) return false;
      emit(state.copyWith(isCancelling: false, actionErrorCode: failure.code));
      return false;
    }
  }

  @override
  Future<void> close() async {
    _revision++;
    await _subscription.cancel();
    await super.close();
  }
}
