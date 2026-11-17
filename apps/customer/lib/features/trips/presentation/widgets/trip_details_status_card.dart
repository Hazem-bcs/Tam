import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/formatters/ride_time_label.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';

/// Trip identity, recorded status, and request time on a branded surface.
class TripDetailsStatusCard extends StatelessWidget {
  const TripDetailsStatusCard({super.key, required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            colors.primary,
            Color.lerp(colors.primary, colors.onSurface, .32)!,
          ],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  color: colors.onPrimary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l.tripsTripNumber(trip.id),
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TripStatusBadge(status: trip.status),
            ),
            const SizedBox(height: AppSpacing.lg),
            Divider(height: 1, color: colors.onPrimary.withValues(alpha: .24)),
            const SizedBox(height: AppSpacing.md),
            _LightMetadata(
              icon: Icons.schedule_outlined,
              label: l.tripsCreatedAt,
              value: tripDateLabel(context, trip.createdAt),
            ),
            if (trip.booking.scheduledAt != null) ...[
              const SizedBox(height: AppSpacing.md),
              _LightMetadata(
                icon: Icons.calendar_month_outlined,
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

class _LightMetadata extends StatelessWidget {
  const _LightMetadata({
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
    final text = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colors.onPrimary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: text.bodySmall?.copyWith(
                  color: colors.onPrimary.withValues(alpha: .85),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: text.bodyMedium?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
