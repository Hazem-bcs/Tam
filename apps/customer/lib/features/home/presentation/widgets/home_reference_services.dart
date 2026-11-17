import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/home/domain/entities/home_content.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// The ride tile is the single booking entry; upcoming services stay disabled.
class HomeReferenceServices extends StatelessWidget {
  const HomeReferenceServices({
    super.key,
    required this.services,
    required this.onRideRequest,
  });
  final List<HomeService> services;
  final VoidCallback onRideRequest;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            l.homeChooseService,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < services.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ServiceTile(
                  service: services[i],
                  onRideRequest: onRideRequest,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service, required this.onRideRequest});
  final HomeService service;
  final VoidCallback onRideRequest;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), theme = Theme.of(context);
    final label = switch (service.id) {
      HomeServiceId.ride => l.homeRide,
      HomeServiceId.food => l.homeFood,
      HomeServiceId.shopping => l.homeShopping,
    };
    final asset = switch (service.id) {
      HomeServiceId.ride => 'assets/maps/vehicle-comfort-user.png',
      HomeServiceId.food => 'assets/images/food.webp',
      HomeServiceId.shopping => 'assets/images/shopping.webp',
    };
    final canBook =
        service.id == HomeServiceId.ride &&
        service.available &&
        service.action == HomeAction.rideRequest;
    return Semantics(
      button: canBook,
      enabled: canBook,
      label: service.available ? label : '$label، ${l.homeComingSoon}',
      excludeSemantics: true,
      child: Material(
        color: theme.colorScheme.surfaceContainerLow.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: canBook
              ? const Key('home-ride-entry')
              : Key('home-service-${service.id.name}'),
          onTap: canBook ? onRideRequest : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 20),
                  child: service.available
                      ? null
                      : Text(
                          l.homeComingSoon,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
                Image.asset(
                  asset,
                  height: 64,
                  width: 88,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
