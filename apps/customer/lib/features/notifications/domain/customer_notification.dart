/// Domain values deliberately contain no route names, URLs or Flutter types.
enum NotificationKind { trip, offer, account, system, unknown }

enum NotificationDestination { home, trips, trip, unknown }

final class NotificationCopy {
  const NotificationCopy({required this.ar, required this.en});
  final String ar;
  final String en;
  String forLanguage(String language) => language == 'ar' ? ar : en;
}

final class NotificationTarget {
  const NotificationTarget({required this.destination, this.tripId});
  final NotificationDestination destination;
  final String? tripId;
  bool get canOpen => switch (destination) {
    NotificationDestination.home || NotificationDestination.trips => true,
    NotificationDestination.trip => tripId != null && tripId!.trim().isNotEmpty,
    NotificationDestination.unknown => false,
  };
}

final class CustomerNotification {
  const CustomerNotification({
    required this.id,
    required this.kind,
    this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.readAt,
    required this.target,
  });

  final String id;
  final NotificationKind kind;

  /// Optional server-defined semantic code; never interpreted as an asset path.
  final String? type;
  final NotificationCopy title;
  final NotificationCopy body;
  final DateTime createdAt;
  final DateTime? readAt;
  final NotificationTarget target;

  bool get isUnread => readAt == null;

  CustomerNotification withReadAt(DateTime when) => CustomerNotification(
    id: id,
    kind: kind,
    type: type,
    title: title,
    body: body,
    createdAt: createdAt,
    readAt: readAt ?? when.toUtc(),
    target: target,
  );
}
