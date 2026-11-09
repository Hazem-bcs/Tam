import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/completion/data/mock/mock_completion_repository.dart';
import 'package:tam_customer/features/completion/domain/completion_repository.dart';
import 'package:tam_customer/features/completion/presentation/bloc/completion_cubit.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'completion_test_support.dart';

void main() {
  late ControlledCompletionRepository repo;
  late CompletionCubit cubit;
  setUp(() async {
    repo = ControlledCompletionRepository();
    cubit = CompletionCubit(
      repo,
      tripId: 'mock-history-001',
      createIdempotencyKey: () => 'key-1',
    );
    await completionFlush();
  });
  tearDown(() async {
    await cubit.close();
    await repo.events.close();
  });
  test(
    'validates before dispatch and locks duplicate dispatch while pending',
    () async {
      await cubit.submit(0, '');
      expect(repo.calls, isEmpty);
      final result = Completer<TripCompletion>();
      repo.onSubmit = (_) => result.future;
      final sending = cubit.submit(4, '  رحلة مريحة  ');
      expect(cubit.state.canEdit, isFalse);
      await cubit.submit(5, 'new');
      await cubit.retry();
      expect(repo.calls.length, 1);
      expect(repo.calls.single.comment, 'رحلة مريحة');
      result.complete(
        completionSnapshot(revision: 2, rating: completionRating()),
      );
      await sending;
      expect(cubit.state.completion!.rating!.stars, 4);
      expect(cubit.state.intent, isNull);
      expect(cubit.state.canEdit, isFalse);
    },
  );
  test(
    'lost response freezes exact intent and retry keeps key/payload',
    () async {
      var attempt = 0;
      repo.onSubmit = (call) async {
        if (attempt++ == 0) {
          throw const CompletionFailure('NETWORK_ERROR', uncertain: true);
        }
        return completionSnapshot(
          revision: 2,
          rating: completionRating(key: call.key),
        );
      };
      await cubit.submit(4, 'رحلة مريحة');
      expect(cubit.state.uncertain, isTrue);
      await cubit.submit(1, 'changed');
      expect(repo.calls.length, 1);
      await cubit.retry();
      expect(
        repo.calls.map((c) => (c.key, c.stars, c.comment)).toSet().length,
        1,
      );
      expect(cubit.state.completion!.rating, isNotNull);
    },
  );
  test(
    'GET reconciliation restores persisted rating without submitting again',
    () async {
      final store = MockTripStore(seed: [completionTrip()]);
      final repository = MockCompletionRepository(
        store,
        now: () => completionNow,
      );
      final first = CompletionCubit(repository, tripId: 'mock-history-001');
      await completionFlush();
      repository.loseNextSubmitResponse = true;
      await first.submit(5, '');
      expect(first.state.uncertain, isTrue);
      await first.retry();
      expect(first.state.intent, isNull);
      await first.close();
      final reopened = CompletionCubit(repository, tripId: 'mock-history-001');
      await completionFlush();
      expect(reopened.state.completion!.rating!.stars, 5);
      expect(reopened.state.canEdit, isFalse);
      await reopened.close();
      await repository.dispose();
      await store.dispose();
    },
  );
  test(
    'older GET success and error cannot erase a newer acknowledgement',
    () async {
      final stale = Completer<TripCompletion>();
      repo.onFetch = () => stale.future;
      final reading = cubit.refresh();
      await cubit.submit(4, 'رحلة مريحة');
      stale.complete(completionSnapshot());
      await reading;
      expect(cubit.state.completion!.revision, 2);
      final failed = Completer<TripCompletion>();
      repo.onFetch = () => failed.future;
      final second = cubit.refresh();
      repo.onFetch = () async =>
          completionSnapshot(revision: 3, rating: completionRating());
      await cubit.refresh();
      failed.completeError(const CompletionFailure('NETWORK_ERROR'));
      await second;
      expect(cubit.state.failure, isNull);
      expect(cubit.state.completion!.revision, 3);
    },
  );
  test(
    'late read error started before submit does not label accepted rating failed',
    () async {
      final result = Completer<TripCompletion>();
      repo.onFetch = () => result.future;
      final reading = cubit.refresh();
      await cubit.submit(4, 'رحلة مريحة');
      result.completeError(const CompletionFailure('NETWORK_ERROR'));
      await reading;
      expect(cubit.state.failure, isNull);
      expect(cubit.state.completion!.rating, isNotNull);
    },
  );
  test(
    'latest read wins and immutable rating cannot change at same revision',
    () async {
      final first = Completer<TripCompletion>();
      repo.onFetch = () => first.future;
      final reading = cubit.refresh();
      repo.onFetch = () async =>
          completionSnapshot(revision: 2, rating: completionRating());
      await cubit.refresh();
      first.complete(completionSnapshot());
      await reading;
      repo.onFetch = () async =>
          completionSnapshot(revision: 2, rating: completionRating(stars: 1));
      await cubit.refresh();
      expect(cubit.state.completion!.rating!.stars, 4);
      expect(cubit.state.failure, 'INVALID_RESPONSE');
    },
  );
  test(
    'wrong trip read fails closed and disables further submission',
    () async {
      repo.onFetch = () async =>
          completionSnapshot(trip: completionTrip(id: 'other'));
      await cubit.refresh();
      await cubit.submit(5, '');
      expect(repo.calls, isEmpty);
      expect(cubit.state.failure, 'INVALID_RESPONSE');
    },
  );
  test(
    'wrong intent acknowledgement stays uncertain and reconciles through GET',
    () async {
      repo.onSubmit = (_) async =>
          completionSnapshot(revision: 2, rating: completionRating(stars: 1));
      await cubit.submit(4, 'رحلة مريحة');
      expect(cubit.state.uncertain, isTrue);
      expect(cubit.state.completion!.rating, isNull);
      repo.onFetch = () async =>
          completionSnapshot(revision: 2, rating: completionRating());
      await cubit.refresh();
      expect(cubit.state.intent, isNull);
      expect(cubit.state.uncertain, isFalse);
    },
  );
  test('GET cannot reconcile same key with changed payload', () async {
    repo.onSubmit = (_) async =>
        throw const CompletionFailure('NETWORK_ERROR', uncertain: true);
    await cubit.submit(4, 'رحلة مريحة');
    repo.onFetch = () async =>
        completionSnapshot(revision: 2, rating: completionRating(stars: 1));
    await cubit.refresh();
    expect(cubit.state.completion!.rating, isNull);
    expect(cubit.state.intent, isNotNull);
    expect(cubit.state.failure, 'INVALID_RESPONSE');
  });
  test('concurrent reconciliation survives a late failure from send', () async {
    final result = Completer<TripCompletion>();
    repo.onSubmit = (_) => result.future;
    final sending = cubit.submit(4, 'رحلة مريحة');
    repo.onFetch = () async =>
        completionSnapshot(revision: 2, rating: completionRating());
    await cubit.refresh();
    result.completeError(Exception('lost'));
    await sending;
    expect(cubit.state.submitting, isFalse);
    expect(cubit.state.failure, isNull);
    expect(cubit.state.intent, isNull);
  });
  test(
    'reset ends page, removes data and ignores late read and send',
    () async {
      final read = Completer<TripCompletion>(),
          send = Completer<TripCompletion>();
      repo.onFetch = () => read.future;
      repo.onSubmit = (_) => send.future;
      final reading = cubit.refresh(), sending = cubit.submit(4, 'رحلة مريحة');
      repo.events.add(const CompletionChange(sessionReset: true));
      expect(cubit.state.completion, isNull);
      expect(cubit.state.intent, isNull);
      read.complete(completionSnapshot());
      send.complete(
        completionSnapshot(revision: 2, rating: completionRating()),
      );
      await reading;
      await sending;
      await cubit.retry();
      expect(cubit.state.sessionEnded, isTrue);
      expect(cubit.state.completion, isNull);
    },
  );
  test(
    'closed page ignores late send without emitting or leaking intent',
    () async {
      final send = Completer<TripCompletion>();
      repo.onSubmit = (_) => send.future;
      final sending = cubit.submit(4, 'رحلة مريحة');
      await cubit.close();
      send.complete(
        completionSnapshot(revision: 2, rating: completionRating()),
      );
      await sending;
      expect(cubit.isClosed, isTrue);
    },
  );
  test(
    'secure keys differ across page lifetimes at an identical clock',
    () async {
      final a = CompletionCubit(
        repo,
        tripId: 'mock-history-001',
        now: () => completionNow,
      );
      final b = CompletionCubit(
        repo,
        tripId: 'mock-history-001',
        now: () => completionNow,
      );
      await completionFlush();
      await a.submit(4, '');
      await b.submit(4, '');
      final keys = repo.calls.map((call) => call.key).toSet();
      expect(keys.length, 2);
      expect(
        keys.every((key) => RegExp(r'^[a-f0-9]{48}$').hasMatch(key)),
        isTrue,
      );
      await a.close();
      await b.close();
    },
  );
}
