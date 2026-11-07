import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/home/domain/entities/home_content.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';

class HomePromotionCard extends StatelessWidget {
  const HomePromotionCard({
    super.key,
    required this.promotion,
    required this.onRideRequest,
  });

  final HomePromotion promotion;
  final VoidCallback onRideRequest;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final typography = Theme.of(context).textTheme;
    final language = Localizations.localeOf(context).languageCode;
    final hero = promotion.kind == HomePromotionKind.hero;
    final action =
        promotion.enabled && promotion.action == HomeAction.rideRequest
        ? onRideRequest
        : null;

    final label = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          promotion.title.forLanguage(language),
          style: typography.titleMedium?.copyWith(
            color: scheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          promotion.subtitle.forLanguage(language),
          style: typography.bodyMedium?.copyWith(
            color: scheme.onPrimaryContainer,
          ),
        ),
        if (!promotion.enabled) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            t.homeComingSoon,
            style: typography.labelMedium?.copyWith(color: scheme.primary),
          ),
        ],
      ],
    );
    return TamCard(
      onTap: action,
      padding: EdgeInsets.zero,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final image = Icon(
                hero ? Icons.local_taxi_outlined : Icons.auto_awesome_outlined,
                color: scheme.primary,
                size: hero ? 70 : 42,
              );
              if (constraints.maxWidth < 290 ||
                  MediaQuery.textScalerOf(context).scale(16) > 24) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    image,
                    const SizedBox(height: AppSpacing.md),
                    label,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: label),
                  const SizedBox(width: AppSpacing.lg),
                  image,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
