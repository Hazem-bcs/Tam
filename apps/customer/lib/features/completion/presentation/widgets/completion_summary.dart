import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';
import 'package:tam_customer/shared/widgets/trip_route.dart';
import '../../domain/completion_repository.dart';

class CompletionSummary extends StatelessWidget {
  const CompletionSummary({super.key, required this.completion});
  final TripCompletion completion;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), trip = completion.trip;
    final text = Theme.of(context).textTheme;
    final driver = trip.live?.driver;
    return TamCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.completionThankYou, style: text.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          TripStatusBadge(status: trip.status),
          const SizedBox(height: AppSpacing.md),
          Text(l.completionTripId(trip.id), style: text.bodySmall),
          Text(tripDateLabel(context, trip.createdAt), style: text.bodySmall),
          const Divider(height: AppSpacing.xl),
          TripRoute(
            pickup: trip.booking.pickup,
            destination: trip.booking.destination,
          ),
          const Divider(height: AppSpacing.xl),
          Text(l.completionRecordedFare, style: text.labelLarge),
          Text(
            tripMoneyLabel(context, trip.booking.fare),
            style: text.headlineSmall,
          ),
          Text(l.completionFareNote, style: text.bodySmall),
          if (driver != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              l.completionDriver(
                Localizations.localeOf(context).languageCode == 'ar'
                    ? driver.name
                    : driver.nameEn,
              ),
              style: text.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
