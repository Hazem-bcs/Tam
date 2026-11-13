import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_journey.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';

/// The highlighted card only renders actual repository-backed active trips.
class ActiveTripCard extends StatelessWidget {
  const ActiveTripCard({super.key, required this.trip, required this.onFollow});
  final Trip trip;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final colors = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: colors.surfaceContainerLow,
      elevation: AppElevation.flat,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        side: BorderSide(color: colors.primaryContainer),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('trips-active-${trip.id}'),
        onTap: onFollow,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                runSpacing: AppSpacing.sm,
                spacing: AppSpacing.md,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 12, color: colors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        l.tripsActiveJourney,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    tripStatusLabel(l, trip.status),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              TripJourney(
                pickup: trip.booking.pickup,
                destination: trip.booking.destination,
              ),
              const SizedBox(height: AppSpacing.md),
              Divider(color: colors.outlineVariant, height: 1),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l.tripsFollowJourney,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(Icons.chevron_left, color: colors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
