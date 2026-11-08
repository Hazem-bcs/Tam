import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/notifications/data/mock/mock_notifications_repository.dart';
import 'package:tam_customer/features/notifications/data/mock/notifications_fixture.dart';
import 'package:tam_customer/features/notifications/data/notifications_codec.dart';
import 'package:tam_customer/features/notifications/data/unavailable_notifications_repository.dart';
import 'package:tam_customer/features/notifications/domain/customer_notification.dart';
import 'package:tam_customer/features/notifications/domain/notifications_repository.dart';

void main() {
  final readTime = DateTime.utc(2026, 11, 7, 15);

  test(
    'fixture is sorted, paginated and merges without duplicate ids',
    () async {
      final repository = MockNotificationsRepository(clock: () => readTime);
      addTearDown(repository.dispose);
      final first = await repository.getPage(limit: 2);
      expect(first.items.length, 2);
      expect(first.items.first.id, 'notice-trip-complete-001');
      expect(first.nextCursor, isNotNull);
      final second = await repository.getPage(
        limit: 2,
        cursor: first.nextCursor,
      );
      expect(
        second.items
            .map((item) => item.id)
            .toSet()
            .intersection(first.items.map((item) => item.id).toSet()),
        isEmpty,
      );
      var cursor = second.nextCursor;
      final ids = {
        ...first.items.map((item) => item.id),
        ...second.items.map((item) => item.id),
      };
      while (cursor != null) {
        final batch = await repository.getPage(limit: 2, cursor: cursor);
        ids.addAll(batch.items.map((item) => item.id));
        cursor = batch.nextCursor;
      }
      expect(ids.length, mockNotificationsFixture.length);
      expect((await repository.getPage(limit: 50)).nextCursor, isNull);
    },
  );

  test('read is idempotent and count stream has one emission', () async {
    final repository = MockNotificationsRepository(clock: () => readTime);
    addTearDown(repository.dispose);
    final changes = <int>[];
    final subscription = repository.unreadChanges.listen(changes.add);
    addTearDown(subscription.cancel);
    expect(await repository.getUnreadCount(), 4);
    final first = await repository.markAsRead('notice-trip-complete-001');
    expect(first.readAt, readTime);
    final repeated = await repository.markAsRead('notice-trip-complete-001');
    expect(repeated.readAt, first.readAt);
    expect(await repository.getUnreadCount(), 3);
    expect(changes, [3]);
    await repository.markAsRead('notice-account-001');
    expect(await repository.getUnreadCount(), 3);
    expect(changes, [3]);
  });

  test('read-all only affects unread and is idempotent', () async {
    final repository = MockNotificationsRepository(clock: () => readTime);
    addTearDown(repository.dispose);
    final result = await repository.markAllAsRead();
    expect(result.unreadCount, 0);
    expect(await repository.getUnreadCount(), 0);
    expect(
      (await repository.getPage(
        limit: 50,
      )).items.every((item) => !item.isUnread),
      isTrue,
    );
    final again = await repository.markAllAsRead();
    expect(again.unreadCount, 0);
  });

  test('read failure changes neither item nor count, retry succeeds', () async {
    final repository = MockNotificationsRepository(clock: () => readTime);
    addTearDown(repository.dispose);
    repository.failOnce(MockNotificationsOperation.read);
    await expectLater(
      repository.markAsRead('notice-trip-complete-001'),
      throwsA(isA<NotificationsFailure>()),
    );
    expect(await repository.getUnreadCount(), 4);
    expect((await repository.getPage()).items.first.isUnread, isTrue);
    expect(
      (await repository.markAsRead('notice-trip-complete-001')).isUnread,
      isFalse,
    );
  });

  test(
    'invalid pagination and non-existent item have typed failures',
    () async {
      final repository = MockNotificationsRepository();
      addTearDown(repository.dispose);
      for (final cursor in ['bad', '!']) {
        await expectLater(
          repository.getPage(cursor: cursor),
          throwsA(
            isA<NotificationsFailure>().having(
              (failure) => failure.code,
              'code',
              NotificationsFailureCode.invalidCursor,
            ),
          ),
        );
      }
      await expectLater(
        repository.getPage(limit: 51),
        throwsA(isA<NotificationsFailure>()),
      );
      await expectLater(
        repository.markAsRead('does-not-exist'),
        throwsA(
          isA<NotificationsFailure>().having(
            (failure) => failure.code,
            'code',
            NotificationsFailureCode.notFound,
          ),
        ),
      );
    },
  );

  test('empty mock remains an empty success and count zero', () async {
    final repository = MockNotificationsRepository(seed: []);
    addTearDown(repository.dispose);
    final page = await repository.getPage();
    expect(page.items, isEmpty);
    expect(page.nextCursor, isNull);
    expect(await repository.getUnreadCount(), 0);
  });

  test('unknown target and missing trip id never become navigable', () {
    final unknown = NotificationsCodec.item(mockNotificationsFixture[4]);
    expect(unknown.target.destination, NotificationDestination.unknown);
    expect(unknown.target.canOpen, isFalse);
    final missing = NotificationsCodec.item(mockNotificationsFixture[5]);
    expect(missing.target.destination, NotificationDestination.trip);
    expect(missing.target.tripId, isNull);
    expect(missing.target.canOpen, isFalse);
    final trip = NotificationsCodec.item(mockNotificationsFixture.first);
    expect(trip.target.tripId, 'mock-history-001');
    expect(trip.target.canOpen, isTrue);
  });

  test(
    'codec requires UTC, bilingual text, envelope and nonnegative count',
    () {
      final item = Map<String, dynamic>.from(mockNotificationsFixture.first);
      item['created_at'] = '2026-11-07T15:00:00+03:00';
      expect(() => NotificationsCodec.item(item), throwsFormatException);
      expect(
        () => NotificationsCodec.unreadCount({
          'data': {'unread_count': -1},
        }),
        throwsFormatException,
      );
      expect(
        () => NotificationsCodec.page({
          'data': [],
          'meta': {'next_cursor': null},
        }).items,
        returnsNormally,
      );
    },
  );

  test('API mode is unavailable without mock fallback', () async {
    const repository = UnavailableNotificationsRepository();
    await expectLater(
      repository.getPage(),
      throwsA(
        isA<NotificationsFailure>().having(
          (failure) => failure.code,
          'code',
          NotificationsFailureCode.serviceUnavailable,
        ),
      ),
    );
    await expectLater(
      repository.getUnreadCount(),
      throwsA(isA<NotificationsFailure>()),
    );
    await expectLater(
      repository.markAllAsRead(),
      throwsA(isA<NotificationsFailure>()),
    );
  });

  test('fixtures use bilingual required shape', () {
    for (final fixture in mockNotificationsFixture) {
      final decoded = NotificationsCodec.item(fixture);
      expect(decoded.title.ar, isNotEmpty);
      expect(decoded.title.en, isNotEmpty);
      expect(decoded.createdAt.isUtc, isTrue);
    }
  });
}
