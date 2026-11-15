import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// A useful next action, not a filler promotion or fabricated statistic.
class NextTripPrompt extends StatelessWidget {
  const NextTripPrompt({super.key, required this.onRequestRide});
  final VoidCallback onRequestRide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l = AppLocalizations.of(context);
    return Material(
      color: colors.primaryContainer,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        key: const Key('trips-new-ride'),
        onTap: onRequestRide,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.alt_route_rounded,
                    color: colors.primary,
                    size: 25,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.tripsNextPrompt,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.tripsNextSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onPrimaryContainer.withValues(alpha: .8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(Icons.arrow_back_rounded, color: colors.primary, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
