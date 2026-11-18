import 'package:flutter/material.dart';
import 'package:tam_customer/app/preferences/app_preferences_cubit.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/settings/presentation/bloc/settings_state.dart';
import 'package:tam_customer/features/settings/presentation/widgets/settings_action_tile.dart';
import 'package:tam_customer/features/settings/presentation/widgets/settings_appearance_preferences.dart';
import 'package:tam_customer/features/settings/presentation/widgets/settings_group.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

class SettingsPreferencesSection extends StatelessWidget {
  const SettingsPreferencesSection({
    super.key,
    required this.state,
    required this.languageCode,
    required this.onNotificationsChanged,
    required this.onLanguageTap,
    this.preferences,
  });

  final AppPreferencesCubit? preferences;
  final SettingsState state;
  final String languageCode;
  final ValueChanged<bool> onNotificationsChanged;
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
                  horizontal: AppSpacing.xs,
                  vertical: 0,
                ),
                secondary: Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Image.asset(
                      'assets/notifications/notification_bell.webp',
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
                title: Text(
                  t.settingsAccountNotifications,
                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
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
            ],
          ),
        ),
        if (preferences != null)
          SettingsAppearancePreferences(controller: preferences!),
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
