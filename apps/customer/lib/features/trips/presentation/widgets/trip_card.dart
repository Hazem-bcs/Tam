import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_journey.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/formatters/ride_time_label.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';

/// A bordered history card. The whole card opens details (no nested tap targets).
class TripCard extends StatelessWidget {
  const TripCard({super.key, required this.trip, required this.onTap});
  final Trip trip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return TamCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TripStatusBadge(status: trip.status),
          ),
          const SizedBox(height: AppSpacing.md),
          if (trip.booking.scheduledAt != null) ...[
            Text(
              l.tripsScheduledAt(
                rideTimeLabel(context, trip.booking.scheduledAt!),
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          TripJourney(
            pickup: trip.booking.pickup,
            destination: trip.booking.destination,
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: scheme.outlineVariant, height: 1),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                tripMoneyLabel(context, trip.booking.fare),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.primary,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      l.tripsDetails,
                      softWrap: true,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(Icons.chevron_left, color: scheme.onSurface),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
