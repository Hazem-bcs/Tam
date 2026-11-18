import 'dart:async';

import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';

import 'mock_trip_snapshot_store.dart';

/// Development-only state shared by booking and trip-history data adapters.
/// Repositories translate these data failures into their own domain failures.
final class MockTripStore {
  MockTripStore({
    Iterable<Trip> seed = const [],
    DateTime Function()? now,
    MockTripSnapshotStore? snapshots,
  }) : _seed = {for (final trip in seed) trip.id: trip},
       _now = now ?? DateTime.now,
       _snapshots = snapshots {
    _trips = Map.of(_seed);
  }
  final Map<String, Trip> _seed;
  late final Map<String, Trip> _trips;
  final DateTime Function() _now;
  final _changes = StreamController<List<Trip>>.broadcast(sync: true);
  final Map<String, Trip> _requests = {};
  var _sequence = 0;
  final MockTripSnapshotStore? _snapshots;
  String? _owner;
  int _sessionEpoch = 0;
  Future<void> _ready = Future.value();
  Future<bool> _saved = Future.value(true);
  bool _restoreFailed = false;
  bool isRestoring = false;

  Future<void> openSession(String owner) {
    if (_owner == owner && !_restoreFailed) return _ready;
    _owner = owner;
    final epoch = ++_sessionEpoch;
    final completion = Completer<void>();
    _ready = completion.future;
    isRestoring = true;
    _reset(_seed, persist: false);
    unawaited(_restore(owner, epoch).whenComplete(() => completion.complete()));
    return _ready;
  }

  Future<void> _restore(String owner, int epoch) async {
    try {
      final restored = await _snapshots?.restore(owner) ?? const <Trip>[];
      if (epoch != _sessionEpoch) return;
      for (final trip in restored) {
        if (!_seed.containsKey(trip.id)) _trips[trip.id] = trip;
      }
      _restoreFailed = false;
    } catch (_) {
      if (epoch == _sessionEpoch) _restoreFailed = true;
    } finally {
      if (epoch == _sessionEpoch) {
        isRestoring = false;
        if (!_changes.isClosed) _changes.add(trips);
      }
    }
  }

  Future<void> ensureReady() async {
    await _ready;
    if (_restoreFailed && _owner != null) await openSession(_owner!);
    if (_restoreFailed) throw const MockTripStoreFailure('SERVICE_UNAVAILABLE');
  }

  void _persist() {
    final owner = _owner, snapshots = _snapshots;
    if (owner == null || snapshots == null || isRestoring || _restoreFailed) {
      return;
    }
    _saved = snapshots.save(
      owner,
      trips.where((trip) => !_seed.containsKey(trip.id)),
      _now().toUtc(),
    );
  }

  Future<void> flush() async {
    if (!await _saved) {
      _persist();
      if (!await _saved) {
        throw const MockTripStoreFailure('SERVICE_UNAVAILABLE');
      }
    }
  }

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
    _persist();
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
    _persist();
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
    _persist();
    _changes.add(trips);
    return updated;
  }

  void clear() => _reset(const {});

  /// Remove session-created operations and restore only synthetic fixtures.
  /// Notification fixtures can then resolve their shared historic-trip IDs.
  void resetSession() {
    ++_sessionEpoch;
    _owner = null;
    isRestoring = false;
    _restoreFailed = false;
    _ready = Future.value();
    _reset(_seed, persist: false);
    final snapshots = _snapshots;
    if (snapshots != null) {
      // Serialize logout deletion after in-flight writes, before another owner.
      _saved = snapshots.clear().then(
        (_) => true,
        onError: (Object _, StackTrace _) => false,
      );
    }
  }

  void _reset(Map<String, Trip> seed, {bool persist = true}) {
    _trips
      ..clear()
      ..addAll(seed);
    _requests.clear();
    if (persist) _persist();
    _changes.add(trips);
  }

  Future<void> dispose() {
    ++_sessionEpoch;
    return _changes.close();
  }
}

final class MockTripStoreFailure implements Exception {
  const MockTripStoreFailure(this.code);
  final String code;
}
