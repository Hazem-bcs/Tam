import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/settings/presentation/bloc/settings_state.dart';
import 'package:tam_customer/features/settings/presentation/widgets/settings_action_tile.dart';
import 'package:tam_customer/features/settings/presentation/widgets/settings_group.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';

class SettingsPreferencesSection extends StatelessWidget {
  const SettingsPreferencesSection({
    super.key,
    required this.state,
    required this.languageCode,
    required this.onNotificationsChanged,
    required this.onSave,
    required this.onLanguageTap,
  });

  final SettingsState state;
  final String languageCode;
  final ValueChanged<bool> onNotificationsChanged;
  final VoidCallback onSave;
  final VoidCallback onLanguageTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return SettingsGroup(
      title: t.settingsPreferencesTitle,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile.adaptive(
                key: const Key('settings-notifications-switch'),
                contentPadding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                secondary: Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: colors.primary,
                  ),
                ),
                title: Text(
                  t.settingsAccountNotifications,
                  style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  t.settingsInternalNotificationHint,
                  style: text.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                value: state.draftNotificationsEnabled,
                onChanged: state.isBusy ? null : onNotificationsChanged,
              ),
              if (state.notificationsDirty) ...[
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: TamButton.secondary(
                    label: t.settingsSavePreferences,
                    loadingLabel: t.settingsSaving,
                    isLoading:
                        state.activity == SettingsActivity.savingPreferences,
                    onPressed: state.isBusy ? null : onSave,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (state.errorTarget == SettingsErrorTarget.preferences &&
                  state.error != null)
                Padding(
                  padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
                  child: Text(
                    t.settingsSaveError,
                    style: text.bodySmall?.copyWith(color: colors.error),
                  ),
                ),
            ],
          ),
        ),
        SettingsActionTile(
          key: const Key('settings-language-tile'),
          icon: Icons.language_rounded,
          title: t.settingsLanguage,
          subtitle: languageCode == 'ar' ? t.settingsArabic : t.settingsEnglish,
          onTap: onLanguageTap,
        ),
      ],
    );
  }
}
