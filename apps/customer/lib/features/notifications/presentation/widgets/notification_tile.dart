import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

import '../../domain/customer_notification.dart';
import 'tam_notification_icon.dart';

/// An actionable, accessible event; visual importance follows read state.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    this.onMarkRead,
    this.isPending = false,
  });

  final CustomerNotification notification;
  final VoidCallback onTap;
  final VoidCallback? onMarkRead;
  final bool isPending;

  String _actionLabel(AppLocalizations l10n) =>
      switch (notification.target.destination) {
        NotificationDestination.trip => l10n.notificationsOpenTrip,
        NotificationDestination.trips => l10n.notificationsOpenTrips,
        NotificationDestination.home => l10n.notificationsExploreServices,
        NotificationDestination.unknown => l10n.notificationsOpenNotification,
      };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final type = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final title = notification.title.forLanguage(language);
    final description = notification.body.forLanguage(language);
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(notification.createdAt.toLocal()));
    final unread = notification.isUnread;
    final primaryTripAction =
        unread &&
        notification.kind == NotificationKind.trip &&
        notification.target.canOpen;
    final showOpenAction =
        notification.isUnread &&
        notification.target.canOpen &&
        (notification.kind == NotificationKind.trip ||
            notification.kind == NotificationKind.offer);
    final showMarkRead =
        unread && onMarkRead != null && !notification.target.canOpen;
    final motion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      container: true,
      label:
          '$title, $description, $time, '
          '${unread ? l10n.notificationsUnread : l10n.notificationsRead}',
      child: AnimatedContainer(
        duration: motion ? Duration.zero : AppMotion.short,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: unread
              ? Color.lerp(
                  colors.primaryContainer,
                  colors.surfaceContainerLowest,
                  .56,
                )
              : colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: unread
                ? colors.primary.withValues(alpha: .26)
                : colors.outlineVariant.withValues(alpha: .7),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: unread ? .065 : .035),
              blurRadius: unread ? 18 : 11,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(21),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: Key('notification-${notification.id}'),
            borderRadius: BorderRadius.circular(21),
            onTap: isPending ? null : onTap,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 62,
                        width: 62,
                        child: isPending
                            ? Center(
                                child: SizedBox.square(
                                  dimension: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.primary,
                                  ),
                                ),
                              )
                            : TamNotificationIcon(notification: notification),
                      ),
                      const SizedBox(width: 12),
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
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: type.titleSmall?.copyWith(
                                      fontWeight: unread
                                          ? FontWeight.w800
                                          : FontWeight.w700,
                                      fontSize: 14.5,
                                      height: 1.35,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                ),
                                if (unread) ...[
                                  const SizedBox(width: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 7),
                                    child: Semantics(
                                      label: l10n.notificationsUnread,
                                      child: CircleAvatar(
                                        radius: 4,
                                        backgroundColor: colors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: type.bodySmall?.copyWith(
                                height: 1.52,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 9),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 13,
                                  color: colors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  time,
                                  style: type.labelSmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (showOpenAction || showMarkRead) ...[
                    const SizedBox(height: 6),
                    Padding(
                      padding: EdgeInsetsDirectional.zero,
                      child: Wrap(
                        spacing: 7,
                        runSpacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (showOpenAction)
                            primaryTripAction
                                ? FilledButton(
                                    onPressed: isPending ? null : onTap,
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size(0, 42),
                                      visualDensity: VisualDensity.compact,
                                      textStyle: type.labelMedium,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                      ),
                                      shape: const StadiumBorder(),
                                    ),
                                    child: Text(_actionLabel(l10n)),
                                  )
                                : TextButton(
                                    onPressed: isPending ? null : onTap,
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(0, 42),
                                      visualDensity: VisualDensity.compact,
                                      textStyle: type.labelMedium,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                      ),
                                    ),
                                    child: Text(_actionLabel(l10n)),
                                  ),
                          if (showMarkRead)
                            TextButton(
                              onPressed: isPending ? null : onMarkRead,
                              style: TextButton.styleFrom(
                                minimumSize: const Size(0, 42),
                                visualDensity: VisualDensity.compact,
                                textStyle: type.labelMedium,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                foregroundColor: colors.onSurfaceVariant,
                              ),
                              child: Text(l10n.notificationsMarkRead),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
