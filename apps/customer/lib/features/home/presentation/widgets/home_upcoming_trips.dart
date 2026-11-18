import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/home/presentation/bloc/home_upcoming_trips_cubit.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/ride_schedule_policy.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';

class HomeUpcomingTrips extends StatelessWidget {
  const HomeUpcomingTrips({
    super.key,
    required this.onOpen,
    required this.schedulePolicy,
  });
  final ValueChanged<String> onOpen;
  final RideSchedulePolicy schedulePolicy;

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<HomeUpcomingTripsCubit, HomeUpcomingTripsState>(
    builder: (context, state) {
      if (!state.loading && !state.failed && state.trips.isEmpty) {
        return const SizedBox.shrink();
      }
      final t = AppLocalizations.of(context);
      final theme = Theme.of(context);
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                t.homeUpcomingTrips,
                style: theme.textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (state.loading)
              TamLoadingIndicator(semanticLabel: t.homeUpcomingLoading),
            if (state.failed)
              TamCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(t.homeUpcomingError),
                    TextButton.icon(
                      onPressed: () => context
                          .read<HomeUpcomingTripsCubit>()
                          .load(showLoading: true),
                      icon: const Icon(Icons.refresh),
                      label: Text(t.homeUpcomingRetry),
                    ),
                  ],
                ),
              ),
            for (final trip in state.trips) ...[
              TamCard(
                key: ValueKey('home-upcoming-${trip.id}'),
                onTap: () => onOpen(trip.id),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _format(context, trip.booking.scheduledAt!),
                            style: theme.textTheme.titleSmall,
                          ),
                          Text(
                            t.homeUpcomingRoute(
                              '\u2068${trip.booking.pickup.label}\u2069',
                              '\u2068${trip.booking.destination.label}\u2069',
                            ),
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            t.homeUpcomingOpen,
                            style: theme.textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      );
    },
  );

  String _format(BuildContext context, DateTime scheduledAt) {
    final localizations = MaterialLocalizations.of(context);
    final date = schedulePolicy.wallTime(scheduledAt);
    return '${localizations.formatMediumDate(date)} · ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(date), alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context))}';
  }
}
