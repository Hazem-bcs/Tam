import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/active_trip/presentation/bloc/active_trip_cubit.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_trip_actions.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_journey_backdrop.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_journey_header.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_journey_shell.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';

import 'active_matching_pulse.dart';

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
        return RideJourneyShell(
          stageKey: 'matching',
          preferredExtent: .46,
          collapsedLabel: t.rideRequestProgressMatching,
          header: RideJourneyHeader(
            step: 5,
            label: t.rideRequestProgressMatching,
            onBack: navigation.openHome,
            backLabel: t.activeTripHome,
            backIcon: Icons.home_outlined,
          ),
          mapBuilder: (inset) => RideJourneyBackdrop(
            pickup: trip.booking.pickup,
            destination: trip.booking.destination,
            bottomInset: inset,
          ),
          panel: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadii.sheet),
                    ),
                    child: Column(
                      children: [
                        const ActiveMatchingPulse(),
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
        );
      },
    ),
  );
}
