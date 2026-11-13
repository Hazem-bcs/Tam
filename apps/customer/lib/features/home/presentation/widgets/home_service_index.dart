import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/home/domain/entities/home_content.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// An open service directory, with explicit non-interactive unavailable rows.
class HomeServiceIndex extends StatelessWidget {
  const HomeServiceIndex({
    super.key,
    required this.services,
    required this.onRideRequest,
  });
  final List<HomeService> services;
  final VoidCallback onRideRequest;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(t.homeChooseService, style: theme.textTheme.titleMedium),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final service in services)
          _ServiceRow(
            service: service,
            onTap: service.available && service.action == HomeAction.rideRequest
                ? onRideRequest
                : null,
            label: switch (service.id) {
              HomeServiceId.ride => t.homeRide,
              HomeServiceId.food => t.homeFood,
              HomeServiceId.shopping => t.homeShopping,
            },
            status: service.available ? null : t.homeComingSoon,
            colors: colors,
          ),
      ],
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.service,
    required this.onTap,
    required this.label,
    required this.status,
    required this.colors,
  });
  final HomeService service;
  final VoidCallback? onTap;
  final String label;
  final String? status;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      enabled: service.available,
      child: Material(
        color: colors.surface,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AppDimensions.controlMinHeight + AppSpacing.lg,
            ),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.outlineVariant)),
            ),
            child: Row(
              children: [
                Icon(
                  switch (service.id) {
                    HomeServiceId.ride => Icons.local_taxi_outlined,
                    HomeServiceId.food => Icons.restaurant_outlined,
                    HomeServiceId.shopping => Icons.shopping_bag_outlined,
                  },
                  color: service.available
                      ? colors.primary
                      : colors.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(child: Text(label, style: text.titleMedium)),
                const SizedBox(width: AppSpacing.sm),
                if (status != null)
                  Flexible(
                    child: Text(
                      status!,
                      style: text.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  )
                else if (onTap != null)
                  Icon(Icons.arrow_forward_rounded, color: colors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
