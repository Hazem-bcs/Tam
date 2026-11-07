import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/home/domain/entities/home_content.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';

class HomeServices extends StatelessWidget {
  const HomeServices({
    super.key,
    required this.services,
    required this.onRideRequest,
  });
  final List<HomeService> services;
  final VoidCallback onRideRequest;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.homeChooseService, style: text.titleLarge),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, box) {
            const spacing = AppSpacing.sm;
            final columns = box.maxWidth >= 340 ? 3 : 2;
            final width = (box.maxWidth - spacing * (columns - 1)) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final service in services)
                  SizedBox(
                    width: width,
                    child: TamCard(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.md,
                      ),
                      onTap:
                          service.available &&
                              service.action == HomeAction.rideRequest
                          ? onRideRequest
                          : null,
                      child: Column(
                        children: [
                          Icon(
                            switch (service.id) {
                              HomeServiceId.ride => Icons.local_taxi_outlined,
                              HomeServiceId.food => Icons.restaurant_outlined,
                              HomeServiceId.shopping =>
                                Icons.shopping_bag_outlined,
                            },
                            color: service.available
                                ? colors.primary
                                : colors.onSurfaceVariant,
                            size: 38,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            switch (service.id) {
                              HomeServiceId.ride => t.homeRide,
                              HomeServiceId.food => t.homeFood,
                              HomeServiceId.shopping => t.homeShopping,
                            },
                            textAlign: TextAlign.center,
                            style: text.labelLarge,
                          ),
                          if (!service.available) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              t.homeComingSoon,
                              textAlign: TextAlign.center,
                              style: text.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
