import 'dart:async';
import 'package:tam_customer/shared/domain/trip.dart';

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
      status: TripStatus.requested,
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
    final updated = trip.withStatus(TripStatus.cancelled);
    _trips[id] = updated;
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
