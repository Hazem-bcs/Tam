import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/support/data/mock/mock_support_repository.dart';
import 'package:tam_customer/features/support/data/unavailable_support_repository.dart';
import 'package:tam_customer/features/support/domain/support_repository.dart';
import 'support_test_support.dart';

Matcher failure(String code) =>
    isA<SupportFailure>().having((e) => e.code, 'code', code);
void main() {
  test('policy trims and counts Unicode code points at both boundaries', () {
    const policy = SupportPolicy();
    expect(policy.validateBody('  ${'😀' * 10}  '), '😀' * 10);
    expect(policy.validateBody('a' * 2000), hasLength(2000));
    for (final value in [' ' * 20, 'a' * 9, '😀' * 2001]) {
      expect(
        () => policy.validateBody(value),
        throwsA(failure('VALIDATION_ERROR')),
      );
    }
  });
  test(
    'catalog validates trip, categories and every linked operation',
    () async {
      final owned = supportStore();
      final r = MockSupportRepository(owned, now: () => supportNow);
      addTearDown(r.dispose);
      addTearDown(owned.dispose);
      expect(
        (await r.options()).categories.every((c) => !c.tripRequired),
        isTrue,
      );
      expect(
        (await r.options(
          tripId: 'trip-1',
        )).categories.any((c) => c.tripRequired),
        isTrue,
      );
      await expectLater(
        r.options(tripId: 'foreign'),
        throwsA(failure('TRIP_NOT_FOUND')),
      );
      await expectLater(
        r.create(
          clientRequestId: 'request-0000000001',
          categoryId: 'trip_issue',
          body: 'Details of the issue',
        ),
        throwsA(failure('INVALID_CATEGORY')),
      );
      await expectLater(
        r.create(
          clientRequestId: 'request-0000000001',
          categoryId: 'unknown',
          body: 'Details of the issue',
        ),
        throwsA(failure('INVALID_CATEGORY')),
      );
      final t = await r.create(
        clientRequestId: 'request-0000000001',
        categoryId: 'trip_issue',
        body: 'Details of the issue',
        tripId: 'trip-1',
      );
      owned.clear();
      await expectLater(r.ticket(t.id), throwsA(failure('TRIP_NOT_FOUND')));
      await expectLater(r.tickets(), throwsA(failure('TRIP_NOT_FOUND')));
      await expectLater(
        r.create(
          clientRequestId: t.clientRequestId,
          categoryId: t.categoryId,
          body: t.body,
          tripId: t.tripId,
        ),
        throwsA(failure('TRIP_NOT_FOUND')),
      );
    },
  );
  test(
    'pagination is 20, stable across prepend, with opaque invalid cursors',
    () async {
      final store = supportStore();
      var time = supportNow;
      final repo = MockSupportRepository(store, now: () => time);
      addTearDown(repo.dispose);
      addTearDown(store.dispose);
      expect((await repo.tickets()).tickets, isEmpty);
      for (var i = 0; i < 25; i++) {
        time = time.add(const Duration(seconds: 1));
        await repo.create(
          clientRequestId: 'request-${i.toString().padLeft(16, '0')}',
          categoryId: 'general',
          body: 'Issue details $i',
        );
      }
      final first = await repo.tickets();
      expect(first.tickets, hasLength(20));
      time = time.add(const Duration(seconds: 1));
      await repo.create(
        clientRequestId: 'request-latest0001',
        categoryId: 'general',
        body: 'New issue details',
      );
      final next = await repo.tickets(cursor: first.nextCursor);
      expect(next.tickets, hasLength(5));
      expect(next.nextCursor, isNull);
      expect({
        ...first.tickets.map((t) => t.id),
        ...next.tickets.map((t) => t.id),
      }, hasLength(25));
      await expectLater(
        repo.tickets(cursor: 'bad'),
        throwsA(failure('INVALID_CURSOR')),
      );
      repo.resetSession();
      await expectLater(
        repo.tickets(cursor: first.nextCursor),
        throwsA(failure('INVALID_CURSOR')),
      );
    },
  );
  test(
    'lost response, duplicate concurrency, payload conflict and logout isolation',
    () async {
      final store = supportStore();
      final repo = MockSupportRepository(
        store,
        now: () => supportNow,
        scenario: SupportMockScenario.lostResponse,
      );
      addTearDown(repo.dispose);
      addTearDown(store.dispose);
      Future<SupportTicket> create({String body = 'Details of the issue'}) =>
          repo.create(
            clientRequestId: 'request-0000000001',
            categoryId: 'general',
            body: body,
          );
      await expectLater(
        create(),
        throwsA(
          isA<SupportFailure>().having((e) => e.uncertain, 'uncertain', true),
        ),
      );
      final accepted = await create();
      final duplicates = await Future.wait([create(), create()]);
      expect(duplicates.every((t) => t.id == accepted.id), isTrue);
      expect((await repo.tickets()).tickets, hasLength(1));
      await expectLater(
        create(body: 'Different issue text'),
        throwsA(failure('IDEMPOTENCY_CONFLICT')),
      );
      expect(await repo.ticket(accepted.id), accepted);
      final events = <SupportChange>[];
      final sub = repo.changes.listen(events.add);
      repo.resetSession();
      expect(events.single.sessionReset, isTrue);
      expect((await repo.tickets()).tickets, isEmpty);
      await expectLater(
        repo.ticket(accepted.id),
        throwsA(failure('TICKET_NOT_FOUND')),
      );
      await sub.cancel();
    },
  );
  test(
    'legal is unpublished and API/offline never fall back to mock success',
    () async {
      final store = supportStore();
      final repo = MockSupportRepository(store);
      final offline = MockSupportRepository(
        store,
        scenario: SupportMockScenario.offline,
      );
      addTearDown(repo.dispose);
      addTearDown(offline.dispose);
      addTearDown(store.dispose);
      for (final kind in LegalDocumentKind.values) {
        expect(await repo.legal(kind, languageCode: 'ar'), isNull);
        await expectLater(
          offline.legal(kind, languageCode: 'en'),
          throwsA(failure('NETWORK_ERROR')),
        );
        await expectLater(
          const UnavailableSupportRepository().legal(kind, languageCode: 'ar'),
          throwsA(failure('SERVICE_UNAVAILABLE')),
        );
      }
      await expectLater(
        const UnavailableSupportRepository().create(
          clientRequestId: 'request-0000000001',
          categoryId: 'general',
          body: 'Details of the issue',
        ),
        throwsA(failure('SERVICE_UNAVAILABLE')),
      );
      expect(
        SupportMockScenario.parse('lost_response'),
        SupportMockScenario.lostResponse,
      );
    },
  );
}
