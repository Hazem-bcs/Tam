import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/home/domain/entities/home_content.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Services are truthful: coming-soon cards are not tappable.
class HomeServiceShowcase extends StatelessWidget {
  const HomeServiceShowcase({super.key, required this.services});
  final List<HomeService> services;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final ride = services.where((s) => s.id == HomeServiceId.ride).firstOrNull;
    final food = services.where((s) => s.id == HomeServiceId.food).firstOrNull;
    final shop = services
        .where((s) => s.id == HomeServiceId.shopping)
        .firstOrNull;
    final upcoming = [
      if (ride != null && !ride.available) (t.homeRide, null),
      if (food != null && !food.available) (t.homeFood, 'food.webp'),
      if (shop != null && !shop.available) (t.homeShopping, 'shopping.webp'),
    ];
    if (upcoming.isEmpty) return const SizedBox.shrink();
    final narrow =
        MediaQuery.sizeOf(context).width < 355 ||
        MediaQuery.textScalerOf(context).scale(14) > 21;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                t.homeServicesHeading,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          t.homeServicesDescription,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.md),
        if (narrow)
          for (final item in upcoming) ...[
            _ServiceTile(label: item.$1, asset: item.$2),
            const SizedBox(height: AppSpacing.sm),
          ]
        else
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final item in upcoming)
                SizedBox(
                  width:
                      (MediaQuery.sizeOf(context).width.clamp(0, 560) - 48) / 2,
                  child: _ServiceTile(label: item.$1, asset: item.$2),
                ),
            ],
          ),
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.label, required this.asset});
  final String label;
  final String? asset;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    return Semantics(
      enabled: false,
      child: Container(
        constraints: const BoxConstraints(minHeight: 100),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: colors.outlineVariant),
        ),
        padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 8, 8),
        child: Row(
          children: [
            if (asset == null)
              SizedBox(
                width: 67,
                height: 75,
                child: Icon(
                  Icons.route_outlined,
                  size: 32,
                  color: colors.primary,
                ),
              )
            else
              Image.asset(
                'assets/images/$asset',
                width: 67,
                height: 75,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                excludeFromSemantics: true,
              ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    t.homeComingSoon,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
