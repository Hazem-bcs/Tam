import 'dart:async';
import 'dart:convert';

import '../../domain/customer_notification.dart';
import '../../domain/notifications_repository.dart';
import 'notifications_fixture.dart';

enum MockNotificationsOperation { page, count, read, readAll }

/// Isolated mutable mock; counter stream and mutations share one source.
final class MockNotificationsRepository implements NotificationsRepository {
  MockNotificationsRepository({
    List<CustomerNotification>? seed,
    DateTime Function()? clock,
  }) : _seed = List.unmodifiable(seed ?? seededNotifications()),
       _clock = clock ?? DateTime.now {
    _items = List.of(_seed);
    _items.sort((a, b) {
      final date = b.createdAt.compareTo(a.createdAt);
      return date == 0 ? a.id.compareTo(b.id) : date;
    });
  }

  final List<CustomerNotification> _seed;
  late final List<CustomerNotification> _items;
  final DateTime Function() _clock;
  final _changes = StreamController<int>.broadcast(sync: true);
  final Set<MockNotificationsOperation> _failurePlan = {};
  bool _disposed = false;

  bool get hasUnreadListeners => _changes.hasListener;

  /// Session data is local to one entered account/guest session.
  void resetSession() {
    if (_disposed) return;
    _items
      ..clear()
      ..addAll(_seed);
    _items.sort((a, b) {
      final date = b.createdAt.compareTo(a.createdAt);
      return date == 0 ? a.id.compareTo(b.id) : date;
    });
    _failurePlan.clear();
    _broadcast();
  }

  /// Test-only fault switch; never accessed by UI or feature state.
  void failOnce(MockNotificationsOperation operation) =>
      _failurePlan.add(operation);

  void _check(MockNotificationsOperation operation) {
    if (_disposed) {
      throw StateError('Notifications repository is disposed');
    }
    if (_failurePlan.remove(operation)) {
      throw const NotificationsFailure(NotificationsFailureCode.network);
    }
  }

  int get _count => _items.where((item) => item.isUnread).length;
  void _broadcast() => _changes.add(_count);

  @override
  Stream<int> get unreadChanges => _changes.stream;

  @override
  Future<int> getUnreadCount() async {
    _check(MockNotificationsOperation.count);
    return _count;
  }

  @override
  Future<NotificationsBatch> getPage({int limit = 20, String? cursor}) async {
    _check(MockNotificationsOperation.page);
    if (limit < 1 || limit > 50) {
      throw const NotificationsFailure(NotificationsFailureCode.invalidCursor);
    }
    var offset = 0;
    if (cursor != null) {
      try {
        final value = utf8.decode(
          base64Url.decode(base64Url.normalize(cursor)),
        );
        if (!RegExp(r'^n1:[0-9]+$').hasMatch(value)) {
          throw const FormatException('Invalid cursor');
        }
        offset = int.parse(value.substring(3));
        if (offset > _items.length) throw const FormatException('Out of range');
      } on FormatException {
        throw const NotificationsFailure(
          NotificationsFailureCode.invalidCursor,
        );
      }
    }
    final end = (offset + limit).clamp(0, _items.length);
    return NotificationsBatch(
      items: List.unmodifiable(_items.sublist(offset, end)),
      nextCursor: end == _items.length
          ? null
          : base64Url.encode(utf8.encode('n1:$end')).replaceAll('=', ''),
    );
  }

  @override
  Future<CustomerNotification> markAsRead(String id) async {
    _check(MockNotificationsOperation.read);
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) {
      throw const NotificationsFailure(NotificationsFailureCode.notFound);
    }
    final previous = _items[index];
    if (previous.isUnread) {
      _items[index] = previous.withReadAt(_clock().toUtc());
      _broadcast();
    }
    return _items[index];
  }

  @override
  Future<NotificationsReadAllResult> markAllAsRead() async {
    _check(MockNotificationsOperation.readAll);
    final now = _clock().toUtc();
    var changed = false;
    for (var index = 0; index < _items.length; index++) {
      if (_items[index].isUnread) {
        _items[index] = _items[index].withReadAt(now);
        changed = true;
      }
    }
    if (changed) _broadcast();
    return NotificationsReadAllResult(readAt: now, unreadCount: _count);
  }

  Future<void> dispose() {
    _disposed = true;
    return _changes.close();
  }
}
