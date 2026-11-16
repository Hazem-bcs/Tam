import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// A compact brand bar, with predictable alignment at every text scale.
class HomeMasthead extends StatelessWidget {
  const HomeMasthead({
    super.key,
    required this.onNotifications,
    required this.isGuest,
    required this.isAuthenticated,
    this.phoneE164,
    this.notificationsButton,
  });

  final VoidCallback onNotifications;
  final bool isGuest;
  final bool isAuthenticated;
  final String? phoneE164;
  final Widget? notificationsButton;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final type = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 14, 20, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            t.appName,
            style: type.headlineLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(width: 1, height: 36, color: colors.outlineVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.homeGreeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: type.labelMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  isGuest
                      ? t.authGuestTitle
                      : isAuthenticated
                      ? t.authSignedInTitle
                      : t.homePhoneTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: type.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (phoneE164 != null)
                  Text(
                    phoneE164!,
                    textDirection: TextDirection.ltr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: type.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          notificationsButton ??
              IconButton(
                key: const Key('home-notifications'),
                tooltip: t.navNotifications,
                onPressed: onNotifications,
                style: IconButton.styleFrom(
                  backgroundColor: colors.surfaceContainerLowest,
                  foregroundColor: colors.primary,
                  minimumSize: const Size.square(AppDimensions.minTapTarget),
                  side: BorderSide(color: colors.outlineVariant),
                ),
                icon: const Icon(Icons.notifications_none_rounded),
              ),
        ],
      ),
    );
  }
}
