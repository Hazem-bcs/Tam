import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';

class SettingsAccountLinks extends StatelessWidget {
  const SettingsAccountLinks({
    super.key,
    required this.enabled,
    required this.onAddresses,
  });
  final bool enabled;
  final VoidCallback onAddresses;

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
        const SizedBox(height: AppSpacing.lg),
        Text(
          t.settingsInfoTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        TamCard(child: Text(t.settingsMockNotice)),
      ],
    );
  }
}
