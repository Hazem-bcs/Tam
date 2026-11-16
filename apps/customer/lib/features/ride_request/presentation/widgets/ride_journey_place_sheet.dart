import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'ride_place_picker.dart';

/// The active endpoint is the title; only the other endpoint needs context.
class RideJourneyPlaceSheet extends StatelessWidget {
  const RideJourneyPlaceSheet({
    super.key,
    required this.pickingPickup,
    required this.pickup,
    required this.destination,
    required this.onOtherEndpoint,
    required this.onSelected,
    this.onPickOnMap,
    this.status,
    this.savedAddressPickerBuilder,
  });
  final bool pickingPickup;
  final TripLocation? pickup, destination;
  final VoidCallback onOtherEndpoint;
  final ValueChanged<TripLocation> onSelected;
  final VoidCallback? onPickOnMap;
  final Widget? status;
  final Widget Function(ValueChanged<TripLocation>)? savedAddressPickerBuilder;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final other = pickingPickup ? destination : pickup;
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              pickingPickup
                  ? t.rideRequestSearchPickupTitle
                  : t.rideRequestSearchDestinationTitle,
              style: theme.textTheme.titleLarge,
            ),
          ),
          if (other != null)
            TextButton(
              onPressed: onOtherEndpoint,
              style: TextButton.styleFrom(
                alignment: AlignmentDirectional.centerStart,
                padding: EdgeInsets.zero,
                foregroundColor: theme.colorScheme.onSurfaceVariant,
              ),
              child: Row(
                children: [
                  Icon(
                    pickingPickup
                        ? Icons.location_on_outlined
                        : Icons.trip_origin_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      pickingPickup
                          ? t.rideRequestSearchTo(other.label)
                          : t.rideRequestSearchFrom(other.label),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: AppSpacing.md),
          if (status != null) ...[
            status!,
            const SizedBox(height: AppSpacing.sm),
          ],
          RidePlacePicker(
            key: ValueKey(pickingPickup),
            pickup: pickingPickup,
            embedded: true,
            onSelected: onSelected,
            onPickOnMap: onPickOnMap,
            savedAddressPickerBuilder: savedAddressPickerBuilder,
          ),
        ],
      ),
    );
  }
}
