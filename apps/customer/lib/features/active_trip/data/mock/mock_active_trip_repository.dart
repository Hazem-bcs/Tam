import 'dart:async';

import 'package:tam_customer/features/active_trip/data/mock/active_trip_scenario.dart';
import 'package:tam_customer/features/active_trip/data/mock/active_trip_simulation.dart';
import 'package:tam_customer/features/active_trip/domain/active_trip_repository.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';

/// Application-owned engine. All trip state, including live metadata, lives in
/// MockTripStore; this adapter owns only its clock, subscription and timer.
final class MockActiveTripRepository implements ActiveTripRepository {
  MockActiveTripRepository(
    this._store, {
    DateTime Function()? now,
    this.scenario = ActiveTripScenario.success,
    ActiveTripTimings timings = const ActiveTripTimings(),
    bool autoStart = true,
  }) : _now = now ?? DateTime.now,
       _simulation = ActiveTripSimulation(timings, scenario) {
    _subscription = _store.changes.listen((_) {
      if (!_advancing && !_disposed) scheduleMicrotask(advance);
    });
    if (autoStart) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => advance());
    }
  }
  final MockTripStore _store;
  final DateTime Function() _now;
  final ActiveTripScenario scenario;
  final ActiveTripSimulation _simulation;
  late final StreamSubscription<List<Trip>> _subscription;
  Timer? _timer;
  bool _disposed = false, _advancing = false;
  bool failNextFetch = false, loseNextCancelResponse = false;

  /// Also called on resume/read, catching up elapsed simulated driver events.
  void advance() {
    if (_disposed || _advancing || _store.isRestoring) return;
    _advancing = true;
    try {
      final now = _now().toUtc();
      for (final initial in _store.trips) {
        var trip = initial;
        for (var step = 0; step < 8; step++) {
          final next = _simulation.next(trip, now);
          if (next == null) break;
          final changed = next.status != trip.status;
          trip = _store.updateLive(
            next,
            expectedRevision: trip.live?.revision ?? 0,
          );
          if (!changed) break;
        }
      }
    } finally {
      _advancing = false;
    }
  }

  void _checkConnection(Trip? trip) {
    if (_disposed) throw const ActiveTripFailure('SERVICE_UNAVAILABLE');
    if (failNextFetch) {
      failNextFetch = false;
      throw const ActiveTripFailure('NETWORK_ERROR');
    }
    if (scenario == ActiveTripScenario.disconnect && trip != null) {
      final age = _now().toUtc().difference(trip.createdAt).inSeconds;
      if (age >= 20 && age < 35) throw const ActiveTripFailure('NETWORK_ERROR');
    }
  }

  @override
  Future<Trip?> fetch(String tripId) async {
    await _ready();
    advance();
    final trip = _store.find(tripId);
    _checkConnection(trip);
    if (trip == null || trip.live != null) return trip;
    // Historic terminal records remain viewable without inventing an assignment.
    return trip.withLive(
      trip.status,
      TripLiveDetails(
        revision: 1,
        updatedAt: trip.createdAt,
        statusChangedAt: trip.createdAt,
      ),
    );
  }

  @override
  Future<Trip?> current() async {
    await _ready();
    advance();
    final active = _store.trips.where((trip) => trip.status.isActive).toList()
      ..sort((a, b) {
        final aScheduled = a.status == TripStatus.scheduled;
        final bScheduled = b.status == TripStatus.scheduled;
        if (aScheduled != bScheduled) return aScheduled ? 1 : -1;
        if (aScheduled) {
          final time = a.booking.scheduledAt!.compareTo(b.booking.scheduledAt!);
          if (time != 0) return time;
        }
        final created = b.createdAt.compareTo(a.createdAt);
        return created == 0 ? a.id.compareTo(b.id) : created;
      });
    final trip = active.firstOrNull;
    _checkConnection(trip);
    return trip;
  }

  @override
  Future<Trip> cancel(String tripId) async {
    await _ready();
    advance();
    _checkConnection(_store.find(tripId));
    try {
      final trip = _store.cancel(tripId);
      await _store.flush();
      if (loseNextCancelResponse) {
        loseNextCancelResponse = false;
        throw const ActiveTripFailure('NETWORK_ERROR');
      }
      return (await fetch(trip.id))!;
    } on MockTripStoreFailure catch (failure) {
      throw ActiveTripFailure(failure.code);
    }
  }

  Future<void> _ready() async {
    try {
      await _store.ensureReady();
      await _store.flush();
    } on MockTripStoreFailure catch (failure) {
      throw ActiveTripFailure(failure.code);
    }
  }

  @override
  Stream<void> get changes => _store.changes.map((_) {});
  void resetSession() {
    failNextFetch = false;
    loseNextCancelResponse = false;
  }

  Future<void> dispose() async {
    _disposed = true;
    _timer?.cancel();
    await _subscription.cancel();
  }
}
