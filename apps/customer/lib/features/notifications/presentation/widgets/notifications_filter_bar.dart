import 'package:flutter/material.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

import '../../domain/customer_notification.dart';

enum NotificationsFeedFilter { all, unread, trips, offers, account, system }

extension NotificationsFeedFilterX on NotificationsFeedFilter {
  bool accepts(CustomerNotification notification) => switch (this) {
    NotificationsFeedFilter.all => true,
    NotificationsFeedFilter.unread => notification.isUnread,
    NotificationsFeedFilter.trips => notification.kind == NotificationKind.trip,
    NotificationsFeedFilter.offers =>
      notification.kind == NotificationKind.offer,
    NotificationsFeedFilter.account =>
      notification.kind == NotificationKind.account,
    NotificationsFeedFilter.system =>
      notification.kind == NotificationKind.system ||
          notification.kind == NotificationKind.unknown,
  };
}

class NotificationsFilterBar extends StatelessWidget {
  const NotificationsFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final NotificationsFeedFilter selected;
  final ValueChanged<NotificationsFeedFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final labels = AppLocalizations.of(context);
    final entries = <(NotificationsFeedFilter, String, IconData)>[
      (
        NotificationsFeedFilter.all,
        labels.notificationsAllFilter,
        Icons.apps_rounded,
      ),
      (
        NotificationsFeedFilter.unread,
        labels.notificationsUnreadFilter,
        Icons.circle_notifications_outlined,
      ),
      (
        NotificationsFeedFilter.trips,
        labels.notificationsTripsFilter,
        Icons.directions_car_outlined,
      ),
      (
        NotificationsFeedFilter.offers,
        labels.notificationsOffersFilter,
        Icons.local_offer_outlined,
      ),
      (
        NotificationsFeedFilter.account,
        labels.notificationsAccountFilter,
        Icons.person_outline_rounded,
      ),
      (
        NotificationsFeedFilter.system,
        labels.notificationsSystemFilter,
        Icons.tune_rounded,
      ),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          for (final entry in entries) ...[
            Semantics(
              button: true,
              selected: selected == entry.$1,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  key: Key('notifications-filter-${entry.$1.name}'),
                  onTap: () => onChanged(entry.$1),
                  borderRadius: BorderRadius.circular(28),
                  child: AnimatedContainer(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    constraints: const BoxConstraints(minHeight: 46),
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected == entry.$1
                          ? colors.primary
                          : colors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: selected == entry.$1
                            ? colors.primary
                            : colors.outlineVariant,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          entry.$3,
                          size: 17,
                          color: selected == entry.$1
                              ? colors.onPrimary
                              : colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          entry.$2,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: selected == entry.$1
                                    ? colors.onPrimary
                                    : colors.onSurface,
                                fontWeight: selected == entry.$1
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
