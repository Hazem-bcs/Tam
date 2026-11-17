import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/formatters/ride_time_label.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';

/// A calm trip summary: status first, metadata second.
class TripDetailsStatusCard extends StatelessWidget {
  const TripDetailsStatusCard({super.key, required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final type = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TripStatusBadge(status: trip.status),
            ),
            const SizedBox(height: AppSpacing.md),
            Directionality(
              textDirection: Directionality.of(context),
              child: Text(
                l.tripsTripNumber(trip.id),
                maxLines: 3,
                softWrap: true,
                style: type.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _DetailMeta(
              icon: Icons.access_time_rounded,
              label: l.tripsCreatedAt,
              value: tripDateLabel(context, trip.createdAt),
            ),
            if (trip.booking.scheduledAt != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _DetailMeta(
                icon: Icons.event_outlined,
                label: l.tripsScheduledTime,
                value: rideTimeLabel(context, trip.booking.scheduledAt!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailMeta extends StatelessWidget {
  const _DetailMeta({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final type = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: colors.onSurfaceVariant),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: type.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: type.bodySmall?.copyWith(
              color: colors.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
