import 'customer_notification.dart';

enum NotificationsFailureCode {
  serviceUnavailable,
  network,
  invalidCursor,
  notFound,
  unauthorized,
  invalidResponse,
}

final class NotificationsFailure implements Exception {
  const NotificationsFailure(this.code);
  final NotificationsFailureCode code;

  @override
  String toString() => 'NotificationsFailure(${code.name})';
}

final class NotificationsBatch {
  const NotificationsBatch({required this.items, required this.nextCursor});
  final List<CustomerNotification> items;
  final String? nextCursor;
}

final class NotificationsReadAllResult {
  const NotificationsReadAllResult({
    required this.readAt,
    required this.unreadCount,
  });
  final DateTime readAt;
  final int unreadCount;
}

/// The badge and inbox read the same underlying repository count.
abstract interface class NotificationsUnreadCountSource {
  Future<int> getUnreadCount();
  Stream<int> get unreadChanges;
}

abstract interface class NotificationsRepository
    implements NotificationsUnreadCountSource {
  Future<NotificationsBatch> getPage({int limit = 20, String? cursor});
  Future<CustomerNotification> markAsRead(String id);
  Future<NotificationsReadAllResult> markAllAsRead();
}
