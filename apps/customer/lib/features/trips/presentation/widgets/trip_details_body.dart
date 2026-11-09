import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/formatters/ride_time_label.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';
import 'package:tam_customer/shared/widgets/trip_route.dart';

class TripDetailsBody extends StatelessWidget {
  const TripDetailsBody({super.key, required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        TamCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                runSpacing: AppSpacing.sm,
                spacing: AppSpacing.md,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    l.tripsTripNumber(trip.id),
                    style: theme.textTheme.titleMedium,
                  ),
                  TripStatusBadge(status: trip.status),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _InfoRow(
                label: l.tripsCreatedAt,
                value: tripDateLabel(context, trip.createdAt),
                icon: Icons.schedule_outlined,
              ),
              if (trip.booking.scheduledAt != null) ...[
                const SizedBox(height: AppSpacing.md),
                _InfoRow(
                  label: l.tripsScheduledTime,
                  value: rideTimeLabel(context, trip.booking.scheduledAt!),
                  icon: Icons.calendar_month_outlined,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        TamCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.tripsRoute, style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.lg),
              TripRoute(
                pickup: trip.booking.pickup,
                destination: trip.booking.destination,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        TamCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.tripsInformation, style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              _InfoRow(
                label: l.tripsVehicleClass,
                value: tripVehicleLabel(l, trip.booking.vehicleClassId),
                icon: Icons.directions_car_outlined,
              ),
              const SizedBox(height: AppSpacing.md),
              Divider(color: theme.colorScheme.outlineVariant),
              const SizedBox(height: AppSpacing.sm),
              _InfoRow(
                label: l.tripsFare,
                value: tripMoneyLabel(context, trip.booking.fare),
                icon: Icons.payments_outlined,
                prominent: true,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l.tripsFareNote,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (trip.status == TripStatus.inProgress) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            l.tripsNoLiveTracking,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.prominent = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style:
                (prominent
                        ? theme.textTheme.titleMedium
                        : theme.textTheme.bodyMedium)
                    ?.copyWith(
                      color: prominent
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
          ),
        ),
      ],
    );
  }
}
