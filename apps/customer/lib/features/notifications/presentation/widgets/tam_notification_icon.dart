import 'package:flutter/material.dart';

import '../../domain/customer_notification.dart';

/// A single visual vocabulary of standalone transparent WebP illustrations.
/// The server sends semantic type codes, never image paths or arbitrary URLs.
class TamNotificationIcon extends StatelessWidget {
  const TamNotificationIcon({
    super.key,
    required this.notification,
    this.size = 56,
  });

  final CustomerNotification notification;
  final double size;

  static const _semanticAssets = <String, String>{
    'ride.completed': 'ride_completed',
    'ride.driver_arrived': 'driver_arrived',
    'ride.scheduled': 'ride_scheduled',
    'ride.cancelled': 'ride_cancelled',
    'ride.history': 'ride_repeat',
    'ride.details': 'ride_scheduled',
    'ride.rating': 'ride_rating',
    'offer.available': 'discount_offer',
    'offer.gift': 'gift',
    'payment.received': 'payment',
    'wallet.updated': 'wallet',
    'account.welcome': 'account',
    'account.security': 'security',
    'system.announcement': 'announcement',
    'system.alert': 'warning',
    'system.message': 'message',
  };

  String get _asset {
    final mapped = _semanticAssets[notification.type];
    if (mapped != null) return mapped;
    return switch (notification.kind) {
      NotificationKind.trip => 'ride_scheduled',
      NotificationKind.offer => 'discount_offer',
      NotificationKind.account => 'security',
      NotificationKind.system => 'announcement',
      NotificationKind.unknown => 'information',
    };
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Image.asset(
      'assets/notifications/$_asset.webp',
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.notifications_outlined,
        size: size * .55,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}
