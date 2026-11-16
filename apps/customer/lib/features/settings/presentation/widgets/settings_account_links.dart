import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/settings/presentation/widgets/settings_action_tile.dart';
import 'package:tam_customer/features/settings/presentation/widgets/settings_group.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Destinations stay owned by their respective features and router policies.
class SettingsAccountLinks extends StatelessWidget {
  const SettingsAccountLinks({
    super.key,
    required this.enabled,
    required this.onAddresses,
    required this.onSupport,
    required this.onTerms,
    required this.onPrivacy,
    required this.onChangePhone,
    required this.onDeleteAccount,
  });

  final VoidCallback onChangePhone, onDeleteAccount;
  final bool enabled;
  final VoidCallback onAddresses, onSupport, onTerms, onPrivacy;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          title: t.settingsAccountSectionTitle,
          children: [
            SettingsActionTile(
              key: const Key('settings-addresses'),
              icon: Icons.bookmark_outline_rounded,
              title: t.addressesTitle,
              subtitle: t.addressesDescription,
              onTap: enabled ? onAddresses : null,
            ),
            SettingsActionTile(
              key: const Key('settings-change-phone'),
              icon: Icons.phone_iphone_rounded,
              title: t.accountManagementChangePhone,
              onTap: enabled ? onChangePhone : null,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        SettingsGroup(
          title: t.settingsInfoTitle,
          children: [
            SettingsActionTile(
              key: const Key('settings-support'),
              icon: Icons.support_agent_rounded,
              title: t.settingsHelp,
              onTap: enabled ? onSupport : null,
            ),
            SettingsActionTile(
              key: const Key('settings-terms'),
              icon: Icons.description_outlined,
              title: t.settingsTerms,
              onTap: enabled ? onTerms : null,
            ),
            SettingsActionTile(
              key: const Key('settings-privacy'),
              icon: Icons.shield_outlined,
              title: t.settingsPrivacy,
              onTap: enabled ? onPrivacy : null,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        SettingsGroup(
          title: t.settingsDangerSectionTitle,
          children: [
            SettingsActionTile(
              key: const Key('settings-delete-account'),
              icon: Icons.delete_outline_rounded,
              title: t.accountManagementDeleteAccount,
              danger: true,
              onTap: enabled ? onDeleteAccount : null,
            ),
          ],
        ),
      ],
    );
  }
}
