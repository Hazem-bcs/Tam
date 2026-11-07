import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/notifications/data/mock/mock_notifications_repository.dart';
import 'package:tam_customer/features/notifications/presentation/bloc/notifications_cubit.dart';
import 'package:tam_customer/features/notifications/presentation/bloc/notifications_state.dart';

void main() {
  test('initial load, pagination and refresh preserve unique ids', () async {
    final repository = MockNotificationsRepository();
    addTearDown(repository.dispose);
    final cubit = NotificationsCubit(repository);
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.status, NotificationsLoadStatus.ready);
    expect(cubit.state.items.length, 7);
    expect(cubit.state.unreadCount, 4);
    await cubit.load(refresh: true);
    expect(cubit.state.items.map((item) => item.id).toSet().length, 7);
  });

  test('load fails explicitly and succeeds after retry', () async {
    final repository = MockNotificationsRepository();
    addTearDown(repository.dispose);
    final cubit = NotificationsCubit(repository);
    addTearDown(cubit.close);
    repository.failOnce(MockNotificationsOperation.page);
    await cubit.load();
    expect(cubit.state.status, NotificationsLoadStatus.error);
    expect(cubit.state.items, isEmpty);
    await cubit.load();
    expect(cubit.state.status, NotificationsLoadStatus.ready);
    expect(cubit.state.error, isNull);
  });

  test('refresh error retains last known data, no invented success', () async {
    final repository = MockNotificationsRepository();
    addTearDown(repository.dispose);
    final cubit = NotificationsCubit(repository);
    addTearDown(cubit.close);
    await cubit.load();
    repository.failOnce(MockNotificationsOperation.count);
    await cubit.load(refresh: true);
    expect(cubit.state.status, NotificationsLoadStatus.ready);
    expect(cubit.state.items, isNotEmpty);
    expect(cubit.state.error, isNotNull);
    expect(cubit.state.unreadCount, 4);
    await cubit.load(refresh: true);
    expect(cubit.state.error, isNull);
  });

  test('mutation error preserves unread count and retry succeeds', () async {
    final repository = MockNotificationsRepository();
    addTearDown(repository.dispose);
    final cubit = NotificationsCubit(repository);
    addTearDown(cubit.close);
    await cubit.load();
    repository.failOnce(MockNotificationsOperation.read);
    await cubit.markAsRead('notice-trip-complete-001');
    expect(cubit.state.unreadCount, 4);
    expect(cubit.state.items.first.isUnread, isTrue);
    expect(cubit.state.mutationError, isNotNull);
    await cubit.markAsRead('notice-trip-complete-001');
    expect(cubit.state.items.first.isUnread, isFalse);
    expect(cubit.state.unreadCount, 3);
    await cubit.markAsRead('notice-trip-complete-001');
    expect(cubit.state.unreadCount, 3);
  });

  test('mark-all failure is retryable without optimistic read', () async {
    final repository = MockNotificationsRepository();
    addTearDown(repository.dispose);
    final cubit = NotificationsCubit(repository);
    addTearDown(cubit.close);
    await cubit.load();
    repository.failOnce(MockNotificationsOperation.readAll);
    await cubit.markAllAsRead();
    expect(cubit.state.mutationError, isNotNull);
    expect(cubit.state.items.first.isUnread, isTrue);
    await cubit.markAllAsRead();
    expect(cubit.state.unreadCount, 0);
    expect(cubit.state.items.every((item) => !item.isUnread), isTrue);
  });

  test('close cancels badge stream subscription', () async {
    final repository = MockNotificationsRepository();
    final cubit = NotificationsCubit(repository);
    expect(repository.hasUnreadListeners, isTrue);
    await cubit.close();
    expect(repository.hasUnreadListeners, isFalse);
    await repository.dispose();
  });
}
