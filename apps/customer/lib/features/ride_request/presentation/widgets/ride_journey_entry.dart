import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';

import 'ride_artwork.dart';

class RideJourneyEntry extends StatelessWidget {
  const RideJourneyEntry({
    super.key,
    this.pickup,
    this.destination,
    this.status,
    required this.onPickup,
    required this.onDestination,
    required this.onContinue,
  });
  final Widget? status;
  final TripLocation? pickup, destination;
  final VoidCallback onPickup, onDestination;
  final VoidCallback? onContinue;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), theme = Theme.of(context);
    return Padding(
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
          if (status != null) ...[
            status!,
            const SizedBox(height: AppSpacing.sm),
          ],
          Row(
            children: [
              const RideArtwork(
                type: RideArtworkType.sedan,
                width: 56,
                height: 44,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.rideRequestFlowStartTitle,
                      style: theme.textTheme.titleLarge,
                    ),
                    Text(
                      l.rideRequestFlowStartSubtitle,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TamButton.primary(
            key: const Key('ride-flow-continue'),
            label: pickup != null && destination != null
                ? l.rideRequestProgressVehicle
                : l.rideRequestFlowStartAction,
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}
