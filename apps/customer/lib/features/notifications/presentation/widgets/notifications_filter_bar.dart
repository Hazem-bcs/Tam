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

/// Edge-to-edge horizontal filters. The next partially visible chip is the
/// scroll affordance; spacing exists between chips, never around the strip.
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
    final scaledTextHeight = MediaQuery.textScalerOf(context).scale(18);
    final stripHeight = scaledTextHeight + 30 < 48
        ? 48.0
        : scaledTextHeight + 30;

    return SizedBox(
      height: stripHeight,
      child: ListView.separated(
        key: const Key('notifications-filter-list'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 12),
        physics: const BouncingScrollPhysics(),
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final entry = entries[index];
          final isSelected = selected == entry.$1;
          return Semantics(
            button: true,
            selected: isSelected,
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
                  constraints: const BoxConstraints(minHeight: 48),
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary
                        : colors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isSelected
                          ? colors.primary
                          : colors.outlineVariant,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        entry.$3,
                        size: 16,
                        color: isSelected
                            ? colors.onPrimary
                            : colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        entry.$2,
                        maxLines: 1,
                        softWrap: false,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              fontSize: 13,
                              color: isSelected
                                  ? colors.onPrimary
                                  : colors.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
