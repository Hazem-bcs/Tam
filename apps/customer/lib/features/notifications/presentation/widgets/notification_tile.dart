import 'package:flutter/material.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

import '../../domain/customer_notification.dart';

/// TAM Activity: a compact event on the journey timeline, not a generic card.
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
    NotificationKind.trip => Icons.directions_car_filled_rounded,
    NotificationKind.offer => Icons.local_offer_rounded,
    NotificationKind.account => Icons.verified_user_rounded,
    NotificationKind.system => Icons.campaign_rounded,
    NotificationKind.unknown => Icons.notifications_rounded,
  };

  Color get _accent => switch (notification.kind) {
    NotificationKind.trip => const Color(0xFF8D153A),
    NotificationKind.offer => const Color(0xFF9C6030),
    NotificationKind.account => const Color(0xFF3C745D),
    NotificationKind.system ||
    NotificationKind.unknown => const Color(0xFF666275),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final title = notification.title.forLanguage(language);
    final body = notification.body.forLanguage(language);
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(notification.createdAt.toLocal()));
    final accent = _accent;
    final isUnread = notification.isUnread;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      container: true,
      label:
          '$title, $body, $time, '
          '${isUnread ? l10n.notificationsUnread : l10n.notificationsRead}',
      button: true,
      child: AnimatedContainer(
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFFFFF1F4) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnread ? const Color(0xFFF7E3E9) : Colors.transparent,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: Key('notification-${notification.id}'),
            onTap: isPending ? null : onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12, 13, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 44,
                    child: Column(
                      children: [
                        Container(
                          width: 43,
                          height: 43,
                          decoration: BoxDecoration(
                            color: isUnread
                                ? Colors.white
                                : accent.withValues(alpha: 0.095),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          alignment: Alignment.center,
                          child: isPending
                              ? SizedBox(
                                  width: 17,
                                  height: 17,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: accent,
                                  ),
                                )
                              : Icon(_icon, color: accent, size: 21),
                        ),
                        const SizedBox(height: 7),
                        Container(
                          height: 24,
                          width: 2,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 13),
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
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 14.5,
                                  height: 1.40,
                                  color: const Color(0xFF291B20),
                                  fontWeight: isUnread
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                            if (isUnread) ...[
                              const SizedBox(width: 8),
                              Semantics(
                                label: l10n.notificationsUnread,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 7),
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF8D153A),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12.5,
                            height: 1.47,
                            color: const Color(0xFF776C70),
                          ),
                        ),
                        const SizedBox(height: 9),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 13,
                              color: Color(0xFF91858A),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              time,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10.5,
                                color: const Color(0xFF91858A),
                              ),
                            ),
                            const Spacer(),
                            if (notification.target.canOpen)
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                textDirection: TextDirection.ltr,
                                size: 12,
                                color: Color(0xFF9A7782),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
