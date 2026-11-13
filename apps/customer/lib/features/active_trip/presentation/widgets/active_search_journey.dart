import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/active_trip/presentation/bloc/active_trip_cubit.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_trip_actions.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_journey_backdrop.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';

/// Matching reflects ActiveTripState; this page never schedules driver success.
class ActiveSearchJourney extends StatelessWidget {
  const ActiveSearchJourney({
    super.key,
    required this.state,
    required this.navigation,
  });
  final ActiveTripState state;
  final CustomerNavigation navigation;

  @override
  Widget build(BuildContext context) => Theme(
    data: AppTheme.rideJourney(Theme.of(context)),
    child: Builder(
      builder: (context) {
        final t = AppLocalizations.of(context);
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final trip = state.trip!;
        return LayoutBuilder(
          builder: (context, bounds) {
            final height = bounds.maxHeight;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Text(t.appName, style: theme.textTheme.headlineLarge),
                      const Spacer(),
                      IconButton(
                        tooltip: t.activeTripHome,
                        onPressed: navigation.openHome,
                        icon: const Icon(Icons.home_outlined),
                      ),
                    ],
                  ),
                ),
                if (height > 580)
                  Expanded(
                    child: RideJourneyBackdrop(
                      pickup: trip.booking.pickup,
                      destination: trip.booking.destination,
                      compact: true,
                    ),
                  ),
                Flexible(
                  flex: height > 580 ? 2 : 1,
                  child: Material(
                    color: colors.surfaceContainerLowest,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      children: [
                        Center(
                          child: Container(
                            width: 50,
                            height: 4,
                            decoration: BoxDecoration(
                              color: colors.outline,
                              borderRadius: BorderRadius.circular(AppRadii.sm),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            t.rideRequestFlowSubmitted,
                            style: theme.textTheme.headlineMedium,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          t.activeTripSearchingHint,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppRadii.sheet),
                          ),
                          child: Column(
                            children: [
                              SizedBox.square(
                                dimension: 56,
                                child: MediaQuery.disableAnimationsOf(context)
                                    ? Icon(
                                        Icons.radar_rounded,
                                        color: colors.primary,
                                        size: 48,
                                      )
                                    : CircularProgressIndicator(
                                        strokeWidth: 3,
                                        semanticsLabel:
                                            t.activeTripSearchingHint,
                                      ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                t.rideRequestSimulationNotice,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (state.offline) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(t.activeTripConnectionLost),
                          TamButton.secondary(
                            label: t.activeTripRefresh,
                            onPressed: () =>
                                context.read<ActiveTripCubit>().refresh(),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        ActiveTripActions(state: state, navigation: navigation),
                        const SizedBox(height: AppSpacing.md),
                        TamButton.secondary(
                          label: t.activeTripHome,
                          onPressed: navigation.openHome,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ),
  );
}
