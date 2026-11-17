import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';

class TripDetailsStatusCard extends StatelessWidget {
  const TripDetailsStatusCard({super.key, required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final vehicle = switch (trip.booking.vehicleClassId) {
      'standard' => 'sedan',
      'comfort' => 'comfort',
      'van' => 'van',
      'motorbike' => 'motorbike',
      _ => null,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            Text(t.tripsTripNumber(trip.id), style: theme.textTheme.titleSmall),
            TripStatusBadge(status: trip.status),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          tripDateLabel(context, trip.createdAt),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Row(
            children: [
              if (vehicle != null)
                Image.asset(
                  'assets/maps/vehicle-$vehicle-user.png',
                  width: 76,
                  height: 46,
                  excludeFromSemantics: true,
                )
              else
                Icon(
                  Icons.directions_car_outlined,
                  color: theme.colorScheme.primary,
                ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.tripsVehicleClass, style: theme.textTheme.bodySmall),
                    Text(
                      tripVehicleLabel(t, trip.booking.vehicleClassId),
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
