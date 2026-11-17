import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/active_trip/presentation/bloc/active_trip_cubit.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_search_journey.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_trip_display.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_trip_overview.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';

class ActiveTripPage extends StatefulWidget {
  const ActiveTripPage({
    super.key,
    required this.navigation,
    this.showDemoAvatar = false,
  });

  final CustomerNavigation navigation;
  final bool showDemoAvatar;

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
        centerTitle: true,
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
                  key: const Key('active-trip-scroll'),
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.lg, AppSpacing.sm,
                    AppSpacing.lg, AppSpacing.xl,
                  ),
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
                        onPressed: () => context.read<ActiveTripCubit>().refresh(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TamButton.primary(
                        label: l.activeTripNewBooking,
                        onPressed: widget.navigation.openRideRequest,
                      ),
                    ] else
                      ActiveTripOverview(
                        state: state,
                        navigation: widget.navigation,
                        showDemoAvatar: widget.showDemoAvatar,
                      ),
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
