import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/home/domain/entities/home_content.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Inactive services are discoverable but never compete with booking.
class HomeServiceShowcase extends StatelessWidget {
  const HomeServiceShowcase({super.key, required this.services});

  final List<HomeService> services;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final upcoming = [
      for (final service in services)
        if (!service.available)
          switch (service.id) {
            HomeServiceId.ride => (t.homeRide, null),
            HomeServiceId.food => (t.homeFood, 'assets/images/food.webp'),
            HomeServiceId.shopping => (
              t.homeShopping,
              'assets/images/shopping.webp',
            ),
          },
    ];
    if (upcoming.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsetsDirectional.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.homeServicesComingSoon,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final item in upcoming)
                Semantics(
                  enabled: false,
                  label: '${item.$1}, ${t.homeComingSoon}',
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 68,
                      maxWidth: 225,
                    ),
                    padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 16, 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: colors.surfaceContainerLow,
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.$2 == null)
                          Icon(
                            Icons.route_outlined,
                            size: 40,
                            color: colors.primary,
                          )
                        else
                          Image.asset(
                            item.$2!,
                            width: 42,
                            height: 42,
                            fit: BoxFit.contain,
                            excludeFromSemantics: true,
                          ),
                        const SizedBox(width: 9),
                        Flexible(
                          child: Text(
                            item.$1,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
