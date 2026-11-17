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
    this.asset,
    this.danger = false,
  });

  final IconData icon;
  final String? asset;
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
      minVerticalPadding: AppSpacing.xs,
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.md,
        vertical: 0,
      ),
      leading: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: (danger ? colors.errorContainer : colors.primaryContainer)
              .withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: asset == null
            ? Icon(icon, color: accent)
            : Padding(
                padding: const EdgeInsets.all(5),
                child: Image.asset(asset!, excludeFromSemantics: true),
              ),
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
