import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/features/active_trip/presentation/bloc/active_trip_state.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_journey_panel.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_tracking_geometry.dart';
import 'package:tam_customer/features/maps/presentation/widgets/map_camera_focus.dart';
import 'package:tam_customer/features/ride_request/domain/ride_coupon_offer.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_location_cubit.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';

import 'ride_journey_backdrop.dart';
import 'ride_journey_shell.dart';
import 'ride_journey_stage.dart';
import 'ride_location_access_prompt.dart';
import 'ride_map_point_panel.dart';
import 'ride_route_header.dart';

class RideJourneyBody extends StatelessWidget {
  const RideJourneyBody({
    super.key,
    this.couponOffers = const [],
    this.onActivateCoupon,
    required this.step,
    required this.draft,
    required this.location,
    required this.pickingPickup,
    this.choosingOnMap = false,
    this.onChooseOnMap,
    required this.onBack,
    required this.onPickup,
    required this.onDestination,
    required this.onSelected,
    required this.onContinue,
    required this.onMapPoint,
    required this.onMapPickup,
    required this.onMapDestination,
    required this.onClearPoint,
    this.active,
    this.navigation,
    this.simulated = false,
    this.onLocate,
    this.onSettings,
    this.savedAddressPickerBuilder,
  });
  final ActiveTripState? active;
  final CustomerNavigation? navigation;
  final bool simulated;
  final RideJourneyStep step;
  final RideDraftState draft;
  final RideLocationState location;
  final bool pickingPickup, choosingOnMap;
  final VoidCallback? onChooseOnMap;
  final VoidCallback onBack, onPickup, onDestination, onClearPoint;
  final VoidCallback? onContinue, onLocate, onSettings;
  final ValueChanged<TripLocation> onSelected, onMapPickup, onMapDestination;
  final ValueChanged<GeoPoint> onMapPoint;
  final Widget Function(ValueChanged<TripLocation>)? savedAddressPickerBuilder;

  final List<RideCouponOffer> couponOffers;
  final ValueChanged<String>? onActivateCoupon;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final active = this.active;
    final selecting = location.point != null;
    final liveTrip = active?.trip;
    final tracking =
        liveTrip != null ||
        (active != null && active.phase != ActiveTripPhase.empty);
    return LayoutBuilder(
      builder: (context, bounds) {
        final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final entryHeight =
            210 +
            (scale - 1) * 180 +
            (location.locating
                ? 32
                : location.failure != null
                ? 68
                : 0);
        final extent = tracking
            ? (liveTrip?.status == TripStatus.requested ? .51 : .63)
            : selecting
            ? .64
            : switch (step) {
                RideJourneyStep.entry => (entryHeight / bounds.maxHeight).clamp(
                  .30,
                  .85,
                ),
                RideJourneyStep.places => .70,
                RideJourneyStep.vehicle => .67,
              };
        return RideJourneyShell(
          showPanel: tracking || selecting || step != RideJourneyStep.entry,
          stageKey: tracking
              ? ('active', liveTrip?.id, liveTrip?.status)
              : selecting
              ? 'map-selection'
              : (step, pickingPickup),
          preferredExtent: extent,
          maximumExtent:
              (tracking || (!selecting && step == RideJourneyStep.vehicle))
              ? .67
              : null,
          expandOnChange: location.point,
          collapsedLabel: tracking
              ? t.activeTripTitle
              : selecting
              ? t.rideRequestMapPointTitle
              : draft.destination?.label ?? t.rideRequestFlowStartTitle,
          header: RideRouteHeader(
            backToHome: tracking,
            pickup: liveTrip?.booking.pickup ?? draft.pickup,
            destination: liveTrip?.booking.destination ?? draft.destination,
            onBack: onBack,
            onPickup: tracking || draft.confirmationPending ? null : onPickup,
            onDestination: tracking || draft.confirmationPending
                ? null
                : onDestination,
            onSwap: !tracking && !draft.confirmationPending && draft.hasRoute
                ? () => context.read<RideDraftBloc>().add(
                    const RideEndpointsSwapped(),
                  )
                : null,
          ),
          mapBuilder: (inset) => RideJourneyBackdrop(
            pickup: liveTrip?.booking.pickup ?? draft.pickup,
            destination: liveTrip?.booking.destination ?? draft.destination,
            selection: tracking ? null : location.point,
            driver: active?.offline == true || active?.positionStale == true
                ? null
                : liveTrip?.live?.position?.point,
            driverBearing: liveTrip?.live?.position?.bearing,
            driverRecordedAt: liveTrip?.live?.position?.recordedAt,
            driverIdentity: (liveTrip?.id, liveTrip?.live?.route?.id),
            trackingRoute: liveTrip == null
                ? null
                : activeTrackingGeometry(liveTrip),
            bottomInset: inset,
            onSelected: tracking || draft.confirmationPending || !choosingOnMap
                ? null
                : onMapPoint,
            onLocate: tracking || draft.confirmationPending ? null : onLocate,
            locating: location.locating,
            focus:
                !tracking &&
                    location.focusPoint != null &&
                    location.focusRevision > 0
                ? MapCameraFocus(location.focusPoint!, location.focusRevision)
                : null,
          ),
          panelBuilder: (collapse) => tracking
              ? ActiveJourneyPanel(
                  state: active!,
                  navigation: navigation!,
                  showDemoAvatar: simulated,
                  simulated: simulated,
                )
              : selecting
              ? RideMapPointPanel(
                  point: location.point!,
                  initialPickup:
                      step == RideJourneyStep.places && pickingPickup,
                  address: location.address,
                  resolving: location.resolving,
                  onPickup: onMapPickup,
                  onDestination: onMapDestination,
                  onClose: onClearPoint,
                )
              : RideJourneyStage(
                  couponOffers: couponOffers,
                  onActivateCoupon: onActivateCoupon,
                  step: step,
                  state: draft,
                  pickingPickup: pickingPickup,
                  onPickup: onPickup,
                  onDestination: onDestination,
                  onSelected: onSelected,
                  onPickOnMap: () {
                    onChooseOnMap?.call();
                    collapse();
                  },
                  onContinue: onContinue,
                  locationStatus: location.locating || location.failure != null
                      ? RideLocationStatus(
                          locating: location.locating,
                          failure: location.failure,
                          onRetry: onLocate,
                          onSettings: onSettings,
                        )
                      : null,
                  savedAddressPickerBuilder: savedAddressPickerBuilder,
                ),
        );
      },
    );
  }
}
