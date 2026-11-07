import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/settings/presentation/bloc/settings_state.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.settingsPreferencesTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        TamCard(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            children: [
              SwitchListTile.adaptive(
                key: const Key('settings-notifications-switch'),
                contentPadding: EdgeInsets.zero,
                secondary: Icon(
                  Icons.notifications_outlined,
                  color: colors.primary,
                ),
                title: Text(t.settingsAccountNotifications),
                subtitle: Text(t.settingsNotificationHint),
                value: state.draftNotificationsEnabled,
                onChanged: state.isBusy ? null : onNotificationsChanged,
              ),
              if (state.notificationsDirty) ...[
                const SizedBox(height: AppSpacing.sm),
                TamButton.secondary(
                  label: t.settingsSavePreferences,
                  loadingLabel: t.settingsSaving,
                  isLoading:
                      state.activity == SettingsActivity.savingPreferences,
                  onPressed: state.isBusy ? null : onSave,
                ),
              ],
              if (state.errorTarget == SettingsErrorTarget.preferences &&
                  state.error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  t.settingsSaveError,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colors.error),
                ),
              ],
              const Divider(height: AppSpacing.xl),
              ListTile(
                key: const Key('settings-language-tile'),
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.language_outlined, color: colors.primary),
                title: Text(t.settingsLanguage),
                subtitle: Text(
                  languageCode == 'ar' ? t.settingsArabic : t.settingsEnglish,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: onLanguageTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
