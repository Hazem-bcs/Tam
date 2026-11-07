import '../domain/customer_notification.dart';
import '../domain/notifications_repository.dart';

/// No HTTP endpoint exists yet. Never substitute mock success in API mode.
final class UnavailableNotificationsRepository
    implements NotificationsRepository {
  const UnavailableNotificationsRepository();

  Never _unavailable() => throw const NotificationsFailure(
    NotificationsFailureCode.serviceUnavailable,
  );

  @override
  Future<int> getUnreadCount() async => _unavailable();

  @override
  Stream<int> get unreadChanges => const Stream<int>.empty();

  @override
  Future<NotificationsBatch> getPage({int limit = 20, String? cursor}) async =>
      _unavailable();

  @override
  Future<CustomerNotification> markAsRead(String id) async => _unavailable();

  @override
  Future<NotificationsReadAllResult> markAllAsRead() async => _unavailable();
}
