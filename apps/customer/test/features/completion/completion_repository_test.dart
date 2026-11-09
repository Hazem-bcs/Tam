import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/completion/data/mock/completion_mock_scenario.dart';
import 'package:tam_customer/features/completion/data/mock/mock_completion_repository.dart';
import 'package:tam_customer/features/completion/data/unavailable_completion_repository.dart';
import 'package:tam_customer/features/completion/domain/completion_repository.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'completion_test_support.dart';

void main() {
  late MockTripStore store;
  late MockCompletionRepository repo;
  setUp(() {
    store = MockTripStore(
      seed: [
        completionTrip(),
        completionTrip(id: 'other'),
      ],
    );
    repo = MockCompletionRepository(store, now: () => completionNow);
  });
  tearDown(() async {
    await repo.dispose();
    await store.dispose();
  });
  Matcher failure(String code) =>
      throwsA(isA<CompletionFailure>().having((f) => f.code, 'code', code));
  Future<TripCompletion> submit({
    String id = 'mock-history-001',
    int stars = 4,
    String comment = ' رحلة مريحة ',
    String key = 'key-1',
  }) => repo.submitRating(
    id,
    stars: stars,
    comment: comment,
    idempotencyKey: key,
  );
  test(
    'legacy completed trip works without driver/live and preserves booking amount',
    () async {
      final value = await repo.fetch('mock-history-001');
      expect(value.canRate, isTrue);
      expect(value.trip.live, isNull);
      expect(value.trip.booking.fare.amountMinor, 25000);
      final saved = await submit();
      expect(saved.rating!.comment, 'رحلة مريحة');
      expect(saved.revision, greaterThan(value.revision));
      expect(store.find('mock-history-001'), value.trip);
      expect((await repo.fetch('mock-history-001')).rating, saved.rating);
    },
  );
  test('same key and normalized payload is idempotent and immutable', () async {
    final saved = await submit();
    expect(await submit(comment: 'رحلة مريحة'), saved);
    await expectLater(submit(stars: 5), failure('IDEMPOTENCY_CONFLICT'));
    await expectLater(
      submit(comment: 'changed'),
      failure('IDEMPOTENCY_CONFLICT'),
    );
    await expectLater(submit(id: 'other'), failure('IDEMPOTENCY_CONFLICT'));
    await expectLater(
      submit(key: 'new-key'),
      failure('RATING_ALREADY_SUBMITTED'),
    );
    expect((await repo.fetch('mock-history-001')).rating, saved.rating);
  });
  test('one trip cannot receive concurrent duplicate submissions', () async {
    final first = submit();
    final duplicate = expectLater(
      submit(key: 'second'),
      failure('RATING_ALREADY_SUBMITTED'),
    );
    expect((await first).rating!.stars, 4);
    await duplicate;
  });
  test(
    'policy uses Unicode code points after trimming, optional empty comment',
    () async {
      const policy = CompletionPolicy();
      expect(policy.validate(1, '   '), '');
      expect(policy.validate(5, '  ${'😀' * 500}  ').runes.length, 500);
      expect(
        () => policy.validate(5, '😀' * 501),
        throwsA(isA<CompletionFailure>()),
      );
      for (final stars in [-1, 0, 6]) {
        await expectLater(submit(stars: stars), failure('VALIDATION_ERROR'));
      }
      await expectLater(submit(key: ' '), failure('VALIDATION_ERROR'));
      expect((await submit(comment: '')).rating!.comment, '');
    },
  );
  for (final status in TripStatus.values.where(
    (s) => s != TripStatus.completed,
  )) {
    test('rejects read and rating for ${status.name}', () async {
      final local = MockTripStore(seed: [completionTrip(status: status)]);
      final repository = MockCompletionRepository(local);
      await expectLater(
        repository.fetch('mock-history-001'),
        failure('TRIP_NOT_COMPLETED'),
      );
      await expectLater(
        repository.submitRating(
          'mock-history-001',
          stars: 4,
          comment: '',
          idempotencyKey: 'key',
        ),
        failure('TRIP_NOT_COMPLETED'),
      );
      await repository.dispose();
      await local.dispose();
    });
  }
  test('missing trip never creates a rating', () async {
    await expectLater(repo.fetch('missing'), failure('TRIP_NOT_FOUND'));
    await expectLater(submit(id: 'missing'), failure('TRIP_NOT_FOUND'));
  });
  test('lost response reconciles by GET or same key retry', () async {
    repo.loseNextSubmitResponse = true;
    await expectLater(
      submit(),
      throwsA(
        isA<CompletionFailure>().having((f) => f.uncertain, 'uncertain', true),
      ),
    );
    final saved = await repo.fetch('mock-history-001');
    expect(saved.rating, isNotNull);
    expect(await submit(), saved);
  });
  test(
    'deterministic offline never writes; lost_response scenario accepts once',
    () async {
      final offline = MockCompletionRepository(
        store,
        scenario: CompletionMockScenario.offline,
      );
      await expectLater(
        offline.fetch('mock-history-001'),
        failure('NETWORK_ERROR'),
      );
      await expectLater(
        offline.submitRating(
          'mock-history-001',
          stars: 5,
          comment: '',
          idempotencyKey: 'k',
        ),
        failure('NETWORK_ERROR'),
      );
      await offline.dispose();
      final lost = MockCompletionRepository(
        store,
        scenario: CompletionMockScenario.lostResponse,
      );
      await expectLater(
        lost.submitRating(
          'mock-history-001',
          stars: 5,
          comment: '',
          idempotencyKey: 'k',
        ),
        failure('NETWORK_ERROR'),
      );
      expect((await lost.fetch('mock-history-001')).rating!.stars, 5);
      expect(
        (await lost.submitRating(
          'mock-history-001',
          stars: 5,
          comment: '',
          idempotencyKey: 'k',
        )).rating!.stars,
        5,
      );
      await lost.dispose();
    },
  );
  test('reset wipes ratings and idempotency; disposal fails closed', () async {
    await submit();
    final events = <CompletionChange>[];
    final sub = repo.changes.listen(events.add);
    repo.resetSession();
    expect(events.single.sessionReset, isTrue);
    expect((await repo.fetch('mock-history-001')).rating, isNull);
    expect((await submit(stars: 1)).rating!.stars, 1);
    await sub.cancel();
  });
  test('unavailable implementation has no mock fallback', () async {
    const unavailable = UnavailableCompletionRepository();
    await expectLater(
      unavailable.fetch('mock-history-001'),
      failure('SERVICE_UNAVAILABLE'),
    );
    await expectLater(
      unavailable.submitRating(
        'mock-history-001',
        stars: 4,
        comment: '',
        idempotencyKey: 'k',
      ),
      failure('SERVICE_UNAVAILABLE'),
    );
  });
  test('scenario parser rejects unknown central configuration', () {
    expect(
      CompletionMockScenario.parse('lost_response'),
      CompletionMockScenario.lostResponse,
    );
    expect(() => CompletionMockScenario.parse('oops'), throwsArgumentError);
  });
}
