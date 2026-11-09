import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';

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
        ListTile(
          key: const Key('settings-addresses'),
          leading: const Icon(Icons.bookmark_border),
          title: Text(t.addressesTitle),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: AppDimensions.iconSize,
          ),
          onTap: enabled ? onAddresses : null,
        ),
        ListTile(
          key: const Key('settings-change-phone'),
          leading: const Icon(Icons.phone_outlined),
          title: Text(t.accountManagementChangePhone),
          onTap: enabled ? onChangePhone : null,
        ),
        ListTile(
          key: const Key('settings-delete-account'),
          leading: const Icon(Icons.person_remove_outlined),
          title: Text(t.accountManagementDeleteAccount),
          onTap: enabled ? onDeleteAccount : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          t.settingsInfoTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final item in [
          (
            const Key('settings-support'),
            Icons.headset_mic_outlined,
            t.settingsHelp,
            onSupport,
          ),
          (
            const Key('settings-terms'),
            Icons.description_outlined,
            t.settingsTerms,
            onTerms,
          ),
          (
            const Key('settings-privacy'),
            Icons.privacy_tip_outlined,
            t.settingsPrivacy,
            onPrivacy,
          ),
        ])
          ListTile(
            key: item.$1,
            leading: Icon(item.$2),
            title: Text(item.$3),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: AppDimensions.iconSize,
            ),
            onTap: enabled ? item.$4 : null,
          ),
        const SizedBox(height: AppSpacing.md),
        TamCard(child: Text(t.settingsMockNotice)),
      ],
    );
  }
}
