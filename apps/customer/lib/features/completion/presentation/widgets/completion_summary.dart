import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';
import 'package:tam_customer/shared/widgets/trip_route.dart';

import '../../domain/completion_repository.dart';
import 'completion_surface.dart';

/// Essentials first; the full stored trip remains available on demand.
/// The recorded amount never implies that a payment has been settled.
class CompletionSummary extends StatelessWidget {
  const CompletionSummary({super.key, required this.completion});
  final TripCompletion completion;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final trip = completion.trip;
    final theme = Theme.of(context);
    final driver = trip.live?.driver;
    return CompletionSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.completionThankYou,
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      l.tripsStatusCompleted,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              Text(l.completionRecordedFare, style: theme.textTheme.bodyMedium),
              Text(
                tripMoneyLabel(context, trip.booking.fare),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l.completionFareNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          ExpansionTile(
            key: const PageStorageKey('completion-details'),
            tilePadding: EdgeInsets.zero,
            title: Text(l.completionDetails, style: theme.textTheme.labelLarge),
            childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.completionTripId(trip.id),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                tripDateLabel(context, trip.createdAt),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              TripRoute(
                pickup: trip.booking.pickup,
                destination: trip.booking.destination,
              ),
              if (driver != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l.completionDriver(
                    Localizations.localeOf(context).languageCode == 'ar'
                        ? driver.name
                        : driver.nameEn,
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
