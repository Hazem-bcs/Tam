import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/active_trip/presentation/bloc/active_trip_cubit.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_journey_panel.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_journey_backdrop.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_journey_shell.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_route_header.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// Deep-linked live trips use the same map-led surface as inline bookings.
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
  Widget build(BuildContext context) => Theme(
    data: AppTheme.rideJourney(Theme.of(context)),
    child: Scaffold(
      body: SafeArea(
        child: BlocBuilder<ActiveTripCubit, ActiveTripState>(
          builder: (context, state) {
            final trip = state.trip;
            return RideJourneyShell(
              stageKey: ('active', trip?.id, trip?.status),
              collapsedLabel: AppLocalizations.of(context).activeTripTitle,
              preferredExtent: trip?.status == TripStatus.requested ? .51 : .63,
              maximumExtent: .67,
              header: RideRouteHeader(
                backToHome: true,
                pickup: trip?.booking.pickup,
                destination: trip?.booking.destination,
                onBack: widget.navigation.openHome,
              ),
              mapBuilder: (inset) => RideJourneyBackdrop(
                pickup: trip?.booking.pickup,
                destination: trip?.booking.destination,
                bottomInset: inset,
                driver: state.offline || state.positionStale
                    ? null
                    : trip?.live?.position?.point,
              ),
              panel: ActiveJourneyPanel(
                state: state,
                navigation: widget.navigation,
                showDemoAvatar: widget.showDemoAvatar,
                simulated: widget.showDemoAvatar,
              ),
            );
          },
        ),
      ),
    ),
  );
}
