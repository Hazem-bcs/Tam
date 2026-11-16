import 'dart:convert';

import '../domain/customer_notification.dart';
import '../domain/notifications_repository.dart';

/// Shared parsing for mock fixtures, API examples, and a future HTTP adapter.
abstract final class NotificationsCodec {
  static CustomerNotification item(Map<String, dynamic> json) {
    String requiredString(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Missing/invalid $key');
      }
      return value;
    }

    NotificationCopy copy(Object? raw) {
      if (raw is! Map<String, dynamic> ||
          raw['ar'] is! String ||
          raw['en'] is! String ||
          (raw['ar'] as String).trim().isEmpty ||
          (raw['en'] as String).trim().isEmpty) {
        throw const FormatException('Expected bilingual notification text');
      }
      return NotificationCopy(ar: raw['ar'] as String, en: raw['en'] as String);
    }

    if (!json.containsKey('read_at')) {
      throw const FormatException('Missing read_at');
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
      type: json['type'] is String ? json['type'] as String : null,
      kind: switch (requiredString('kind')) {
        'trip' => NotificationKind.trip,
        'offer' => NotificationKind.offer,
        'account' => NotificationKind.account,
        'system' => NotificationKind.system,
        _ => NotificationKind.unknown,
      },
      title: copy(json['title']),
      body: copy(json['body']),
      createdAt: _utc(json['created_at']),
      readAt: json['read_at'] == null ? null : _utc(json['read_at']),
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
        !meta.containsKey('next_cursor') ||
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
    return NotificationsReadAllResult(
      readAt: _utc(data['read_at']),
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

  // DateTime.parse normalizes impossible dates (e.g. February 30). Reject
  // those at the transport boundary rather than displaying a different date.
  static DateTime _utc(Object? raw) {
    if (raw is! String) {
      throw const FormatException('Expected UTC ISO-8601 timestamp');
    }
    final match = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(?:\.\d+)?Z$',
    ).firstMatch(raw);
    if (match == null) {
      throw const FormatException('Expected UTC ISO-8601 timestamp');
    }
    final parsed = DateTime.parse(raw);
    final components = [
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
    ];
    for (var index = 0; index < components.length; index++) {
      if (components[index] != int.parse(match.group(index + 1)!)) {
        throw const FormatException('Invalid calendar timestamp');
      }
    }
    return parsed;
  }

  static Map<String, dynamic> decode(String source) =>
      jsonDecode(source) as Map<String, dynamic>;
}
