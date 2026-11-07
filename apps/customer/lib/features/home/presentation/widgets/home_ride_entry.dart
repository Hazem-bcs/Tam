import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';

class HomeRideEntry extends StatelessWidget {
  const HomeRideEntry({super.key, required this.onRideRequest});
  final VoidCallback onRideRequest;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.homeRideEntryTitle, style: text.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        TamCard(
          onTap: onRideRequest,
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: scheme.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  t.homeRideEntryHint,
                  style: text.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: scheme.primary),
            ],
          ),
        ),
      ],
    );
  }
}
