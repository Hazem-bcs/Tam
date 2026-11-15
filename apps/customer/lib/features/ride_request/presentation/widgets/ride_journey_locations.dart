import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';

class RideJourneyLocations extends StatelessWidget {
  const RideJourneyLocations({
    super.key,
    this.pickup,
    this.destination,
    this.onPickup,
    this.onDestination,
    this.compact = false,
  });
  final TripLocation? pickup, destination;
  final VoidCallback? onPickup, onDestination;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    if (compact) {
      final endpoints = [
        _EndpointSummary(
          caption: t.rideRequestPickup,
          label: pickup?.label ?? t.rideRequestPickupHint,
          icon: Icons.trip_origin_rounded,
          onTap: onPickup,
        ),
        _EndpointSummary(
          caption: t.rideRequestDestination,
          label: destination?.label ?? t.rideRequestDestinationHint,
          icon: Icons.location_on_outlined,
          onTap: onDestination,
        ),
      ];
      return LayoutBuilder(
        builder: (context, bounds) {
          final stacked =
              bounds.maxWidth < 300 ||
              MediaQuery.textScalerOf(context).scale(12) > 18;
          return stacked
              ? Column(children: endpoints)
              : Row(
                  children: [
                    Expanded(child: endpoints.first),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: endpoints.last),
                  ],
                );
        },
      );
    }
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            dense: true,
            minTileHeight: 48,
            leading: Icon(
              Icons.radio_button_checked,
              size: 20,
              color: colors.primary,
            ),
            title: Text(pickup?.label ?? t.rideRequestPickupHint),
            subtitle: pickup == null ? null : Text(t.rideRequestPickup),
            onTap: onPickup,
            trailing: onPickup == null
                ? null
                : const Icon(Icons.edit_outlined, size: 18),
          ),
          Divider(
            height: 1,
            indent: AppSpacing.lg,
            endIndent: AppSpacing.lg,
            color: colors.outlineVariant,
          ),
          ListTile(
            dense: true,
            minTileHeight: 48,
            leading: Icon(Icons.place_rounded, size: 20, color: colors.primary),
            title: Text(destination?.label ?? t.rideRequestDestinationHint),
            subtitle: destination == null
                ? null
                : Text(t.rideRequestDestination),
            onTap: onDestination,
            trailing: onDestination == null
                ? null
                : const Icon(Icons.edit_outlined, size: 18),
          ),
        ],
      ),
    );
  }
}

class _EndpointSummary extends StatelessWidget {
  const _EndpointSummary({
    required this.caption,
    required this.label,
    required this.icon,
    this.onTap,
  });
  final String caption, label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  caption,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.labelMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
