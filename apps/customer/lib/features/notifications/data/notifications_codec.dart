import 'dart:convert';

import '../domain/customer_notification.dart';
import '../domain/notifications_repository.dart';

/// Shared parsing for mock fixtures, API examples, and a future HTTP adapter.
abstract final class NotificationsCodec {
  static CustomerNotification item(Map<String, dynamic> json) {
    String requiredString(String key) {
      final value = json[key];
      if (value is! String || value.isEmpty) {
        throw FormatException('Missing/invalid $key');
      }
      return value;
    }

    NotificationCopy copy(Object? raw) {
      if (raw is! Map<String, dynamic> ||
          raw['ar'] is! String ||
          raw['en'] is! String) {
        throw const FormatException('Expected bilingual notification text');
      }
      return NotificationCopy(ar: raw['ar'] as String, en: raw['en'] as String);
    }

    DateTime utc(Object? raw) {
      if (raw is! String || !raw.endsWith('Z')) {
        throw const FormatException('Expected UTC ISO-8601 timestamp');
      }
      return DateTime.parse(raw).toUtc();
    }

    final rawTarget = json['target'];
    if (rawTarget is! Map<String, dynamic>) {
      throw const FormatException('Expected notification target object');
    }
    final targetType = switch (rawTarget['type']) {
      'home' => NotificationDestination.home,
      'trips' => NotificationDestination.trips,
      'trip' => NotificationDestination.trip,
      _ => NotificationDestination.unknown,
    };
    final rawTripId = rawTarget['trip_id'];
    return CustomerNotification(
      id: requiredString('id'),
      kind: switch (requiredString('kind')) {
        'trip' => NotificationKind.trip,
        'offer' => NotificationKind.offer,
        'account' => NotificationKind.account,
        'system' => NotificationKind.system,
        _ => NotificationKind.unknown,
      },
      title: copy(json['title']),
      body: copy(json['body']),
      createdAt: utc(json['created_at']),
      readAt: json['read_at'] == null ? null : utc(json['read_at']),
      target: NotificationTarget(
        destination: targetType,
        tripId:
            targetType == NotificationDestination.trip &&
                rawTripId is String &&
                rawTripId.trim().isNotEmpty
            ? rawTripId
            : null,
      ),
    );
  }

  static NotificationsBatch page(Map<String, dynamic> json) {
    final data = json['data'], meta = json['meta'];
    if (data is! List ||
        meta is! Map<String, dynamic> ||
        (meta['next_cursor'] != null && meta['next_cursor'] is! String)) {
      throw const FormatException('Invalid notification page');
    }
    return NotificationsBatch(
      items: List.unmodifiable(
        data.map((value) {
          if (value is! Map<String, dynamic>) {
            throw const FormatException('Invalid notification item');
          }
          return item(value);
        }),
      ),
      nextCursor: meta['next_cursor'] as String?,
    );
  }

  static int unreadCount(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid unread-count envelope');
    }
    final count = data['unread_count'];
    if (count is! int || count < 0) {
      throw const FormatException('Invalid unread_count');
    }
    return count;
  }

  static NotificationsReadAllResult readAll(Map<String, dynamic> json) {
    final count = unreadCount(json);
    final data = json['data'] as Map<String, dynamic>;
    final raw = data['read_at'];
    if (raw is! String || !raw.endsWith('Z')) {
      throw const FormatException('Invalid read_all read_at');
    }
    return NotificationsReadAllResult(
      readAt: DateTime.parse(raw).toUtc(),
      unreadCount: count,
    );
  }

  static CustomerNotification itemResponse(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid notification envelope');
    }
    return item(data);
  }

  static Map<String, dynamic> decode(String source) =>
      jsonDecode(source) as Map<String, dynamic>;
}
