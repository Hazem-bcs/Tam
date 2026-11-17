import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Quiet account actions: sign-out is deliberate, while version information
/// is a lightweight footer instead of another large settings card.
class SettingsBottomActions extends StatelessWidget {
  const SettingsBottomActions({
    super.key,
    required this.busy,
    required this.loggingOut,
    required this.onLogout,
  });

  final bool busy;
  final bool loggingOut;
  final VoidCallback onLogout;

  void _showVersionInfo(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final type = Theme.of(context).textTheme;
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: Icon(Icons.info_outline_rounded, color: colors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              t.settingsDevelopmentDisclosureTitle,
              style: type.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              t.settingsMockNotice,
              style: type.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final type = Theme.of(context).textTheme;

    return Column(
      children: [
        Center(
          child: TextButton.icon(
            key: const Key('settings-logout-action'),
            onPressed: busy || loggingOut ? null : onLogout,
            style: TextButton.styleFrom(
              foregroundColor: colors.primary,
              minimumSize: const Size(
                double.infinity,
                AppDimensions.minTapTarget,
              ),
              backgroundColor: colors.primaryContainer.withValues(alpha: 0.5),
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
            ),
            icon: loggingOut
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.error,
                    ),
                  )
                : const Icon(Icons.logout_rounded, size: 20),
            label: Text(
              loggingOut ? t.settingsLoggingOut : t.settingsLogout,
              style: type.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Divider(
          color: colors.outlineVariant.withValues(alpha: 0.65),
          height: AppDimensions.borderWidth,
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: TextButton.icon(
            key: const Key('settings-version-disclosure'),
            onPressed: () => _showVersionInfo(context),
            style: TextButton.styleFrom(
              foregroundColor: colors.onSurfaceVariant,
              minimumSize: const Size(168, AppDimensions.minTapTarget),
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
            icon: const Icon(Icons.info_outline_rounded, size: 18),
            label: Text(
              t.settingsDevelopmentDisclosureTitle,
              style: type.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }
}
