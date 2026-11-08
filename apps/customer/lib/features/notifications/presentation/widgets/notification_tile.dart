import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

import '../../domain/customer_notification.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    this.isPending = false,
  });

  final CustomerNotification notification;
  final VoidCallback onTap;
  final bool isPending;

  IconData get _icon => switch (notification.kind) {
    NotificationKind.trip => Icons.local_taxi_outlined,
    NotificationKind.offer => Icons.local_offer_outlined,
    NotificationKind.account => Icons.verified_user_outlined,
    NotificationKind.system ||
    NotificationKind.unknown => Icons.notifications_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final title = notification.title.forLanguage(language);
    final body = notification.body.forLanguage(language);
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(notification.createdAt.toLocal()));

    return Semantics(
      container: true,
      label:
          '$title, ${notification.isUnread ? l10n.notificationsUnread : l10n.notificationsRead}',
      button: true,
      child: Card(
        color: notification.isUnread
            ? colors.primaryContainer
            : colors.surfaceContainerLowest,
        child: InkWell(
          key: Key('notification-${notification.id}'),
          onTap: isPending ? null : onTap,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppDimensions.minTapTarget,
                  height: AppDimensions.minTapTarget,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Icon(_icon, color: colors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.titleMedium,
                              softWrap: true,
                            ),
                          ),
                          if (notification.isUnread) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Semantics(
                              label: l10n.notificationsUnread,
                              child: Icon(
                                Icons.circle,
                                size: AppSpacing.md,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        body,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        time,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
