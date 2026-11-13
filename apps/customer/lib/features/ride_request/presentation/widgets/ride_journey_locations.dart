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
  });
  final TripLocation? pickup, destination;
  final VoidCallback? onPickup, onDestination;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            dense: true,
            leading: Icon(Icons.radio_button_checked, color: colors.primary),
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
            leading: Icon(Icons.place_rounded, color: colors.tertiary),
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
