import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/notifications/data/mock/mock_notifications_repository.dart';
import 'package:tam_customer/features/notifications/data/mock/notifications_fixture.dart';
import 'package:tam_customer/features/notifications/domain/customer_notification.dart';
import 'package:tam_customer/features/notifications/presentation/bloc/notifications_cubit.dart';
import 'package:tam_customer/features/notifications/presentation/bloc/notifications_state.dart';

void main() {
  List<CustomerNotification> seed(int count) {
    final item = seededNotifications().first;
    return List.generate(
      count,
      (i) => CustomerNotification(
        id: 'notification-page-${i.toString().padLeft(3, '0')}',
        kind: item.kind,
        title: item.title,
        body: item.body,
        createdAt: item.createdAt.subtract(Duration(minutes: i)),
        readAt: i.isEven ? null : DateTime.utc(2026, 11, 7, 12),
        target: item.target,
      ),
    );
  }

  test('cubit page-more appends remaining items exactly once', () async {
    final repository = MockNotificationsRepository(seed: seed(25));
    final cubit = NotificationsCubit(repository);
    addTearDown(() async {
      await cubit.close();
      await repository.dispose();
    });
    await cubit.load();
    expect(cubit.state.items.length, 20);
    expect(cubit.state.hasMore, isTrue);
    await cubit.loadMore();
    expect(cubit.state.items.length, 25);
    expect(cubit.state.hasMore, isFalse);
    await cubit.loadMore();
    expect(cubit.state.items.length, 25);
    expect(cubit.state.items.map((e) => e.id).toSet().length, 25);
  });

  test('pagination failure retains cursor and pages then retries', () async {
    final repository = MockNotificationsRepository(seed: seed(25));
    final cubit = NotificationsCubit(repository);
    addTearDown(() async {
      await cubit.close();
      await repository.dispose();
    });
    await cubit.load();
    final cursor = cubit.state.nextCursor;
    repository.failOnce(MockNotificationsOperation.page);
    await cubit.loadMore();
    expect(cubit.state.status, NotificationsLoadStatus.ready);
    expect(cubit.state.items.length, 20);
    expect(cubit.state.nextCursor, cursor);
    expect(cubit.state.moreError, isNotNull);
    await cubit.loadMore();
    expect(cubit.state.items.length, 25);
    expect(cubit.state.moreError, isNull);
  });
}
