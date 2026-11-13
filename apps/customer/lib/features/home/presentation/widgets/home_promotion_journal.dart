import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/home/domain/entities/home_content.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Server-authored promotions presented as compact editorial notes.
class HomePromotionJournal extends StatelessWidget {
  const HomePromotionJournal({
    super.key,
    required this.promotion,
    required this.onRideRequest,
  });
  final HomePromotion promotion;
  final VoidCallback onRideRequest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final action =
        promotion.enabled && promotion.action == HomeAction.rideRequest
        ? onRideRequest
        : null;
    return Material(
      color: colors.surface,
      child: InkWell(
        onTap: action,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSpacing.xs,
                height: AppSpacing.xl,
                decoration: BoxDecoration(
                  color: promotion.kind == HomePromotionKind.hero
                      ? colors.primary
                      : colors.outline,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promotion.title.forLanguage(language),
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      promotion.subtitle.forLanguage(language),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    if (!promotion.enabled) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        AppLocalizations.of(context).homeComingSoon,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (action != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.arrow_forward_rounded, color: colors.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
