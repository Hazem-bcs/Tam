import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_details_driver_card.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_details_information_card.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_details_route_card.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_details_status_card.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';

class TripDetailsBody extends StatelessWidget {
  const TripDetailsBody({super.key, required this.trip, this.onOpenFullMap});
  final Trip trip;
  final VoidCallback? onOpenFullMap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TripDetailsStatusCard(trip: trip),
        const SizedBox(height: AppSpacing.md),
        TripDetailsRouteCard(trip: trip, onOpenFullMap: onOpenFullMap),
        const SizedBox(height: AppSpacing.md),
        TamCard(
          child: Row(
            children: [
              Expanded(
                child: _Metric(
                  icon: Icons.route_outlined,
                  label: l.tripsDistance,
                  value: l.tripsUnavailableValue,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _Metric(
                  icon: Icons.schedule_rounded,
                  label: l.tripsDuration,
                  value: l.tripsUnavailableValue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TripDetailsDriverCard(trip: trip),
        const SizedBox(height: AppSpacing.md),
        TripDetailsInformationCard(trip: trip),
        if (trip.status == TripStatus.inProgress) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            l.tripsNoLiveTracking,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
    ],
  );
}
