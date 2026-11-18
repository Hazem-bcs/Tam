import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/features/active_trip/domain/active_trip_repository.dart';
import 'package:tam_customer/features/active_trip/domain/upcoming_trips_repository.dart';
import 'package:tam_customer/shared/domain/trip.dart';

final class HomeUpcomingTripsState {
  const HomeUpcomingTripsState({
    this.trips = const [],
    this.loading = true,
    this.failed = false,
  });
  final List<Trip> trips;
  final bool loading, failed;
}

/// Owns the home reservation list, without coupling it to the booking draft.
final class HomeUpcomingTripsCubit extends Cubit<HomeUpcomingTripsState> {
  HomeUpcomingTripsCubit(this._repository)
    : super(const HomeUpcomingTripsState()) {
    _subscription = _repository.changes.listen(
      (_) => unawaited(load()),
      onError: (_) {
        if (!isClosed) {
          emit(
            HomeUpcomingTripsState(
              trips: state.trips,
              loading: false,
              failed: true,
            ),
          );
        }
      },
    );
    unawaited(load());
  }
  final UpcomingTripsRepository _repository;
  late final StreamSubscription<void> _subscription;
  int _generation = 0;

  Future<void> load({bool showLoading = false}) async {
    final generation = ++_generation;
    emit(
      HomeUpcomingTripsState(
        trips: state.trips,
        loading: showLoading || state.loading,
      ),
    );
    try {
      final trips = await _repository.upcoming();
      if (isClosed || generation != _generation) return;
      emit(
        HomeUpcomingTripsState(trips: List.unmodifiable(trips), loading: false),
      );
    } on ActiveTripFailure {
      if (!isClosed && generation == _generation) {
        emit(
          HomeUpcomingTripsState(
            trips: state.trips,
            loading: false,
            failed: true,
          ),
        );
      }
    } on FormatException {
      if (!isClosed && generation == _generation) {
        emit(
          HomeUpcomingTripsState(
            trips: state.trips,
            loading: false,
            failed: true,
          ),
        );
      }
    }
  }

  @override
  Future<void> close() async {
    ++_generation;
    await _subscription.cancel();
    await super.close();
  }
}
