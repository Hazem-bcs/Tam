import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/active_trip/presentation/bloc/active_trip_cubit.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_driver_card.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_route_map.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_search_journey.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_trip_actions.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_trip_display.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/formatters/ride_time_label.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';
import 'package:tam_customer/shared/widgets/trip_route.dart';

class ActiveTripPage extends StatefulWidget {
  const ActiveTripPage({super.key, required this.navigation});
  final CustomerNavigation navigation;
  @override
  State<ActiveTripPage> createState() => _ActiveTripPageState();
}

class _ActiveTripPageState extends State<ActiveTripPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<ActiveTripCubit>().refresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final searching = context.select<ActiveTripCubit, bool>(
      (cubit) => cubit.state.trip?.status == TripStatus.requested,
    );
    if (searching) {
      return Theme(
        data: AppTheme.rideJourney(Theme.of(context)),
        child: Builder(
          builder: (context) => Scaffold(
            body: SafeArea(
              child: BlocBuilder<ActiveTripCubit, ActiveTripState>(
                builder: (context, state) => ActiveSearchJourney(
                  state: state,
                  navigation: widget.navigation,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l.activeTripTitle),
        actions: [
          IconButton(
            tooltip: l.activeTripHome,
            icon: const Icon(Icons.home_outlined),
            onPressed: widget.navigation.openHome,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: BlocBuilder<ActiveTripCubit, ActiveTripState>(
              builder: (context, state) {
                if (state.phase == ActiveTripPhase.loading) {
                  return Center(
                    child: TamLoadingIndicator(
                      semanticLabel: l.activeTripLoading,
                    ),
                  );
                }
                final trip = state.trip;
                return ListView(
                  padding: AppSpacing.pagePadding,
                  children: [
                    if (trip == null) ...[
                      Text(
                        state.phase == ActiveTripPhase.failed
                            ? activeTripError(l, state.failure)
                            : l.activeTripEmpty,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TamButton.secondary(
                        label: l.activeTripRefresh,
                        isLoading: state.refreshing,
                        loadingLabel: l.activeTripLoading,
                        onPressed: () =>
                            context.read<ActiveTripCubit>().refresh(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TamButton.primary(
                        label: l.activeTripNewBooking,
                        onPressed: () => widget.navigation.openRideRequest(),
                      ),
                    ] else ...[
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          tripStatusLabel(l, trip.status),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(activeTripDescription(l, trip.status)),
                      if (trip.booking.scheduledAt != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(rideTimeLabel(context, trip.booking.scheduledAt!)),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      if (state.offline) ...[
                        TamCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Icon(Icons.cloud_off_outlined),
                              Text(activeTripError(l, state.failure)),
                              Text(l.activeTripCached),
                              TextButton(
                                onPressed: state.refreshing
                                    ? null
                                    : () => context
                                          .read<ActiveTripCubit>()
                                          .refresh(),
                                child: Text(l.activeTripRefresh),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      if (state.refreshing) const LinearProgressIndicator(),
                      ActiveRouteMap(
                        trip: trip,
                        stale: state.offline || state.positionStale,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TripRoute(
                        pickup: trip.booking.pickup,
                        destination: trip.booking.destination,
                      ),
                      if (trip.live?.driver != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        ActiveDriverCard(driver: trip.live!.driver!),
                        const SizedBox(height: AppSpacing.md),
                        TamButton.secondary(
                          key: const Key('active-chat'),
                          label: l.activeTripChat,
                          icon: Icons.chat_bubble_outline,
                          onPressed: () => widget.navigation.openChat(trip.id),
                        ),
                      ],
                      if (!state.offline &&
                          !state.positionStale &&
                          (trip.live?.etaSeconds ?? 0) > 0) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          l.activeTripEta((trip.live!.etaSeconds! / 60).ceil()),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      ActiveTripActions(
                        state: state,
                        navigation: widget.navigation,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l.activeTripSimulationNotice,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
