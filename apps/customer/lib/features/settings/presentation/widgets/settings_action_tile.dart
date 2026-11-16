import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';

/// An accessible navigation row with a consistent icon well and chevron.
class SettingsActionTile extends StatelessWidget {
  const SettingsActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final typography = Theme.of(context).textTheme;
    final accent = danger ? colors.error : colors.primary;
    return ListTile(
      enabled: onTap != null,
      minVerticalPadding: AppSpacing.md,
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      leading: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: (danger ? colors.errorContainer : colors.primaryContainer)
              .withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Icon(icon, color: accent),
      ),
      title: Text(
        title,
        style: typography.titleSmall?.copyWith(
          color: danger ? colors.error : colors.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: typography.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
      trailing: onTap == null
          ? null
          : Icon(
              // Material mirrors this directional icon automatically in RTL.
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: danger ? colors.error : colors.onSurfaceVariant,
            ),
      onTap: onTap,
    );
  }
}
