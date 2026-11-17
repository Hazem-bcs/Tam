import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// No balance is available through the current Settings repository contract.
class SettingsWalletSummary extends StatelessWidget {
  const SettingsWalletSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/notifications/wallet.webp',
            width: 36,
            height: 36,
            excludeFromSemantics: true,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(t.rideRequestWallet, style: theme.textTheme.titleSmall),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              t.settingsWalletUnavailable,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
