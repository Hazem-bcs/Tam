import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_details_information_card.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_details_route_card.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_details_status_card.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';

class TripDetailsBody extends StatelessWidget {
  const TripDetailsBody({super.key, required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TripDetailsStatusCard(trip: trip),
        const SizedBox(height: AppSpacing.md),
        TripDetailsRouteCard(trip: trip),
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
