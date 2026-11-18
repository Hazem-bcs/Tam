import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_brand_logo.dart';

/// Compact identity; phone details belong in Account, not the action-first home.
class HomeMasthead extends StatelessWidget {
  const HomeMasthead({
    super.key,
    required this.onNotifications,
    required this.isGuest,
    required this.isAuthenticated,
    this.notificationsButton,
  });

  final VoidCallback onNotifications;
  final bool isGuest;
  final bool isAuthenticated;
  final Widget? notificationsButton;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final type = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const TamBrandLogo(width: 54, height: 38),
          const SizedBox(width: AppSpacing.md),
          Container(width: 1, height: 32, color: colors.outlineVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.homeGreeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: type.labelMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  isGuest
                      ? t.authGuestTitle
                      : isAuthenticated
                      ? t.authSignedInTitle
                      : t.homeBrowsingLabel,
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
                onPressed: onNotifications,
                tooltip: t.navNotifications,
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
