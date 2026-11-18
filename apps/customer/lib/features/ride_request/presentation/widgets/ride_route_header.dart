import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// The route stays visible and editable while the map and journey change below.
class RideRouteHeader extends StatelessWidget {
  const RideRouteHeader({
    super.key,
    this.pickup,
    this.destination,
    required this.onBack,
    this.onPickup,
    this.onDestination,
    this.onSwap,
    this.backToHome = false,
  });
  final TripLocation? pickup, destination;
  final bool backToHome;
  final VoidCallback onBack;
  final VoidCallback? onPickup, onDestination, onSwap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), theme = Theme.of(context);
    final c = theme.colorScheme;
    return Material(
      elevation: AppElevation.raised,
      shadowColor: c.shadow.withValues(alpha: .12),
      color: c.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.sheet),
        side: BorderSide(color: c.outlineVariant.withValues(alpha: .6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _RouteEndpoint(
                  key: const Key('ride-header-pickup'),
                  icon: Icons.trip_origin_rounded,
                  caption: l.rideRequestPhasePickup,
                  label: pickup?.label ?? l.rideRequestPickupHint,
                  onTap: onPickup,
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 48),
                  child: Divider(
                    height: 1,
                    color: c.outlineVariant.withValues(alpha: .6),
                  ),
                ),
                _RouteEndpoint(
                  key: const Key('ride-header-destination'),
                  icon: Icons.location_on_rounded,
                  caption: l.rideRequestDestination,
                  label: destination?.label ?? l.rideRequestDestinationHint,
                  onTap: onDestination,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                key: const Key('ride-flow-back'),
                onPressed: onBack,
                tooltip: backToHome
                    ? l.activeTripHome
                    : MaterialLocalizations.of(context).backButtonTooltip,
                icon: Icon(
                  backToHome ? Icons.home_outlined : Icons.arrow_back_rounded,
                ),
              ),
              if (onSwap != null)
                IconButton(
                  key: const Key('ride-swap-route'),
                  onPressed: onSwap,
                  tooltip: l.rideRequestSwapRoute,
                  icon: const Icon(Icons.swap_vert_rounded),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
    );
  }
}

class _RouteEndpoint extends StatelessWidget {
  const _RouteEndpoint({
    super.key,
    required this.icon,
    required this.caption,
    required this.label,
    this.onTap,
  });
  final IconData icon;
  final String caption, label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: onTap != null,
      label: '$caption: $label',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Row(
              children: [
                Icon(icon, size: 23, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.edit_outlined,
                    size: 15,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
