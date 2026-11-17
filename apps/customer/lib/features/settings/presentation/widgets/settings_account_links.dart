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
    this.destinationsOnly = false,
    this.supportOnly = false,
    this.onCoupons,
  });

  final VoidCallback onChangePhone, onDeleteAccount;
  final VoidCallback? onCoupons;
  final bool enabled;
  final bool destinationsOnly, supportOnly;
  final VoidCallback onAddresses, onSupport, onTerms, onPrivacy;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!supportOnly)
          SettingsGroup(
            title: t.settingsAccountSectionTitle,
            children: [
              SettingsActionTile(
                key: const Key('settings-addresses'),
                asset: 'assets/images/address_pin.webp',
                icon: Icons.bookmark_outline_rounded,
                title: t.addressesTitle,
                subtitle: t.addressesDescription,
                onTap: enabled ? onAddresses : null,
              ),
              SettingsActionTile(
                key: const Key('settings-coupons'),
                asset: 'assets/notifications/discount_offer.webp',
                icon: Icons.local_offer_outlined,
                title: t.homeCouponTitle,
                subtitle: t.homeCouponHint,
                onTap: enabled ? onCoupons : null,
              ),
              SettingsActionTile(
                key: const Key('settings-change-phone'),
                asset: 'assets/notifications/account.webp',
                icon: Icons.phone_iphone_rounded,
                title: t.accountManagementChangePhone,
                onTap: enabled ? onChangePhone : null,
              ),
            ],
          ),
        if (!destinationsOnly) ...[
          if (!supportOnly) const SizedBox(height: AppSpacing.lg),
          SettingsGroup(
            title: t.settingsInfoTitle,
            children: [
              SettingsActionTile(
                key: const Key('settings-support'),
                asset: 'assets/notifications/support.webp',
                icon: Icons.support_agent_rounded,
                title: t.settingsHelp,
                onTap: enabled ? onSupport : null,
              ),
              SettingsActionTile(
                key: const Key('settings-terms'),
                asset: 'assets/notifications/information.webp',
                icon: Icons.description_outlined,
                title: t.settingsTerms,
                onTap: enabled ? onTerms : null,
              ),
              SettingsActionTile(
                key: const Key('settings-privacy'),
                asset: 'assets/notifications/security.webp',
                icon: Icons.shield_outlined,
                title: t.settingsPrivacy,
                onTap: enabled ? onPrivacy : null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SettingsGroup(
            title: t.settingsDangerSectionTitle,
            children: [
              SettingsActionTile(
                key: const Key('settings-delete-account'),
                asset: 'assets/notifications/warning.webp',
                icon: Icons.delete_outline_rounded,
                title: t.accountManagementDeleteAccount,
                danger: true,
                onTap: enabled ? onDeleteAccount : null,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
