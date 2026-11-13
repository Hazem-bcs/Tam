import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Brand and session identity; phone direction never follows the page direction.
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme.apply(
      bodyColor: colors.onPrimary,
      displayColor: colors.onPrimary,
    );
    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.homeGreeting, style: text.bodySmall),
        Text(
          isGuest
              ? t.authGuestTitle
              : isAuthenticated
              ? t.authSignedInTitle
              : t.homePhoneTitle,
          style: text.labelMedium,
        ),
        if (phoneE164 != null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              phoneE164!,
              textDirection: TextDirection.ltr,
              style: text.bodySmall,
            ),
          ),
      ],
    );
    return LayoutBuilder(
      builder: (context, bounds) {
        final compact =
            bounds.maxWidth < 300 ||
            MediaQuery.textScalerOf(context).scale(16) > 24;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (compact)
                  Expanded(child: Text(t.appName, style: text.headlineLarge))
                else
                  Text(t.appName, style: text.displayLarge),
                const SizedBox(width: AppSpacing.lg),
                if (!compact) Expanded(child: identity),
                const SizedBox(width: AppSpacing.sm),
                IconButtonTheme(
                  data: IconButtonThemeData(
                    style: IconButton.styleFrom(
                      foregroundColor: colors.onPrimary,
                      backgroundColor: colors.onPrimary.withValues(alpha: 0.12),
                      minimumSize: const Size.square(
                        AppDimensions.minTapTarget,
                      ),
                    ),
                  ),
                  child:
                      notificationsButton ??
                      IconButton(
                        key: const Key('home-notifications'),
                        onPressed: onNotifications,
                        tooltip: t.navNotifications,
                        icon: const Icon(Icons.notifications_none_rounded),
                      ),
                ),
              ],
            ),
            if (compact) ...[const SizedBox(height: AppSpacing.sm), identity],
          ],
        );
      },
    );
  }
}
