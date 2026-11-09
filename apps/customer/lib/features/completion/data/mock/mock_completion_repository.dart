import 'dart:async';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import '../../domain/completion_repository.dart';
import 'completion_mock_scenario.dart';

/// Application-session owned simulation; never modifies the trip lifecycle.
final class MockCompletionRepository implements CompletionRepository {
  MockCompletionRepository(
    this._store, {
    DateTime Function()? now,
    this.policy = const CompletionPolicy(),
    this.scenario = CompletionMockScenario.success,
  }) : _now = now ?? DateTime.now {
    _subscription = _store.changes.listen((_) {
      if (!_disposed) _changes.add(const CompletionChange());
    });
  }
  final MockTripStore _store;
  final DateTime Function() _now;
  final CompletionPolicy policy;
  final CompletionMockScenario scenario;
  final _ratings = <String, TripRating>{};
  final _requests = <String, TripRating>{};
  final _revisions = <String, int>{};
  final _snapshots = <String, Trip>{};
  final _scenarioUsed = <String>{};
  final _changes = StreamController<CompletionChange>.broadcast(sync: true);
  late final StreamSubscription<List<Trip>> _subscription;
  bool _disposed = false;
  bool failNextFetch = false,
      failNextSubmit = false,
      loseNextSubmitResponse = false;

  TripCompletion _resolve(String tripId) {
    if (_disposed) throw const CompletionFailure('SERVICE_UNAVAILABLE');
    final trip = _store.find(tripId);
    if (trip == null) throw const CompletionFailure('TRIP_NOT_FOUND');
    if (trip.status != TripStatus.completed) {
      throw const CompletionFailure('TRIP_NOT_COMPLETED');
    }
    if (_snapshots[tripId] != trip) {
      _snapshots[tripId] = trip;
      _revisions[tripId] = (_revisions[tripId] ?? 0) + 1;
    }
    return TripCompletion(
      trip: trip,
      rating: _ratings[tripId],
      revision: _revisions[tripId]!,
    );
  }

  @override
  Future<TripCompletion> fetch(String tripId) async {
    final completion = _resolve(tripId);
    if (failNextFetch || scenario == CompletionMockScenario.offline) {
      failNextFetch = false;
      throw const CompletionFailure('NETWORK_ERROR');
    }
    return completion;
  }

  @override
  Future<TripCompletion> submitRating(
    String tripId, {
    required int stars,
    required String comment,
    required String idempotencyKey,
  }) async {
    _resolve(tripId);
    final value = policy.validate(stars, comment);
    if (idempotencyKey.trim().isEmpty) {
      throw const CompletionFailure('VALIDATION_ERROR');
    }
    final previous = _requests[idempotencyKey];
    if (previous != null) {
      if (previous.tripId != tripId ||
          previous.stars != stars ||
          previous.comment != value) {
        throw const CompletionFailure('IDEMPOTENCY_CONFLICT');
      }
      return _resolve(tripId);
    }
    if (_ratings.containsKey(tripId)) {
      throw const CompletionFailure('RATING_ALREADY_SUBMITTED');
    }
    if (failNextSubmit || scenario == CompletionMockScenario.offline) {
      failNextSubmit = false;
      throw const CompletionFailure('NETWORK_ERROR');
    }
    final trip = _store.find(tripId)!;
    final floor = trip.live?.statusChangedAt ?? trip.createdAt;
    final timestamp = _now().toUtc();
    final rating = TripRating(
      id: '$tripId-rating',
      tripId: tripId,
      stars: stars,
      comment: value,
      idempotencyKey: idempotencyKey,
      submittedAt: timestamp.isBefore(floor) ? floor : timestamp,
    );
    _ratings[tripId] = rating;
    _requests[idempotencyKey] = rating;
    _revisions[tripId] = _revisions[tripId]! + 1;
    if (loseNextSubmitResponse ||
        (scenario == CompletionMockScenario.lostResponse &&
            _scenarioUsed.add(tripId))) {
      loseNextSubmitResponse = false;
      throw const CompletionFailure('NETWORK_ERROR', uncertain: true);
    }
    _changes.add(const CompletionChange());
    return _resolve(tripId);
  }

  @override
  Stream<CompletionChange> get changes => _changes.stream;
  void resetSession() {
    _ratings.clear();
    _requests.clear();
    _revisions.clear();
    _snapshots.clear();
    _scenarioUsed.clear();
    failNextFetch = failNextSubmit = loseNextSubmitResponse = false;
    if (!_disposed) _changes.add(const CompletionChange(sessionReset: true));
  }

  Future<void> dispose() async {
    _disposed = true;
    await _subscription.cancel();
    await _changes.close();
  }
}
