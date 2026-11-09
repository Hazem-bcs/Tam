import 'dart:async';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';

/// Development-only state shared by booking and trip-history data adapters.
/// Repositories translate these data failures into their own domain failures.
final class MockTripStore {
  MockTripStore({Iterable<Trip> seed = const [], DateTime Function()? now})
    : _seed = {for (final trip in seed) trip.id: trip},
      _now = now ?? DateTime.now {
    _trips = Map.of(_seed);
  }
  final Map<String, Trip> _seed;
  late final Map<String, Trip> _trips;
  final DateTime Function() _now;
  final _changes = StreamController<List<Trip>>.broadcast(sync: true);
  final Map<String, Trip> _requests = {};
  var _sequence = 0;

  List<Trip> get trips {
    final values = _trips.values.toList()
      ..sort((a, b) {
        final byTime = b.createdAt.compareTo(a.createdAt);
        return byTime == 0 ? a.id.compareTo(b.id) : byTime;
      });
    return List.unmodifiable(values);
  }

  Stream<List<Trip>> get changes => _changes.stream;
  Trip? find(String id) => _trips[id];

  Trip create(TripBookingInput input, {required String idempotencyKey}) {
    if (idempotencyKey.trim().isEmpty) {
      throw const MockTripStoreFailure('IDEMPOTENCY_KEY_REQUIRED');
    }
    final previous = _requests[idempotencyKey];
    if (previous != null) {
      if (previous.booking != input) {
        throw const MockTripStoreFailure('IDEMPOTENCY_CONFLICT');
      }
      return _trips[previous.id]!;
    }
    String id;
    do {
      id = 'mock-trip-${++_sequence}';
    } while (_trips.containsKey(id));
    final trip = Trip(
      id: id,
      booking: input,
      createdAt: _now().toUtc(),
      status: input.scheduledAt == null
          ? TripStatus.requested
          : TripStatus.scheduled,
    );
    _trips[id] = trip;
    _requests[idempotencyKey] = trip;
    _changes.add(trips);
    return trip;
  }

  Trip cancel(String id) {
    final trip = _trips[id];
    if (trip == null) throw const MockTripStoreFailure('TRIP_NOT_FOUND');
    if (trip.status == TripStatus.cancelled) return trip;
    if (!trip.canCancel) {
      throw const MockTripStoreFailure('TRIP_NOT_CANCELLABLE');
    }
    final live = trip.live;
    final timestamp = _now().toUtc();
    final updated = live == null
        ? trip.withStatus(TripStatus.cancelled)
        : trip.withLive(
            TripStatus.cancelled,
            TripLiveDetails(
              revision: live.revision + 1,
              updatedAt: timestamp.isBefore(live.updatedAt)
                  ? live.updatedAt
                  : timestamp,
              statusChangedAt: timestamp.isBefore(live.updatedAt)
                  ? live.updatedAt
                  : timestamp,
              driver: live.driver,
            ),
          );
    _trips[id] = updated;
    _changes.add(trips);
    return updated;
  }

  /// Compare-and-set keeps cancellation and driver events from overwriting
  /// each other; booking identity never changes during a live update.
  Trip updateLive(Trip updated, {required int expectedRevision}) {
    final previous = _trips[updated.id];
    if (previous == null) throw const MockTripStoreFailure('TRIP_NOT_FOUND');
    final oldRevision = previous.live?.revision ?? 0;
    final live = updated.live;
    if (oldRevision != expectedRevision ||
        live == null ||
        live.revision != oldRevision + 1 ||
        previous.booking != updated.booking ||
        previous.createdAt != updated.createdAt ||
        !previous.status.canTransitionTo(updated.status) ||
        live.updatedAt.isBefore(
          previous.live?.updatedAt ?? previous.createdAt,
        ) ||
        (previous.status == TripStatus.scheduled &&
            updated.status == TripStatus.requested &&
            _now().toUtc().isBefore(previous.booking.scheduledAt!))) {
      throw const MockTripStoreFailure('TRIP_STATE_CONFLICT');
    }
    _trips[updated.id] = updated;
    _changes.add(trips);
    return updated;
  }

  void clear() => _reset(const {});

  /// Remove session-created operations and restore only synthetic fixtures.
  /// Notification fixtures can then resolve their shared historic-trip IDs.
  void resetSession() => _reset(_seed);

  void _reset(Map<String, Trip> seed) {
    _trips
      ..clear()
      ..addAll(seed);
    _requests.clear();
    _changes.add(trips);
  }

  Future<void> dispose() => _changes.close();
}

final class MockTripStoreFailure implements Exception {
  const MockTripStoreFailure(this.code);
  final String code;
}
