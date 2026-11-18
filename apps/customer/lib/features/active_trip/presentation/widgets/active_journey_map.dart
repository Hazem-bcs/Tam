import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tam_customer/features/active_trip/presentation/bloc/active_trip_state.dart';
import 'package:tam_customer/features/maps/domain/maps_repository.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_journey_backdrop.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';
import 'package:tam_customer/shared/presentation/vehicle_marker_kind.dart';

import 'active_tracking_geometry.dart';

/// Keeps immutable road geometry out of the per-position conversion path.
/// State belongs to this mounted map and is discarded with the journey.
class ActiveJourneyMap extends StatefulWidget {
  const ActiveJourneyMap({
    super.key,
    required this.state,
    required this.bottomInset,
  });
  final ActiveTripState state;
  final ValueListenable<double> bottomInset;

  @override
  State<ActiveJourneyMap> createState() => _ActiveJourneyMapState();
}

class _ActiveJourneyMapState extends State<ActiveJourneyMap> {
  Object? _identity;
  TripTrackingRoute? _tracking;
  MapRoute? _geometry;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final trip = state.trip;
    final identity = (
      trip?.id,
      trip?.status,
      trip?.booking.pickup.point,
      trip?.booking.destination.point,
    );
    final tracking = trip?.live?.route;
    if (_identity != identity || _tracking != tracking) {
      _identity = identity;
      _tracking = tracking;
      _geometry = trip == null ? null : activeTrackingGeometry(trip);
    }
    return RideJourneyBackdrop(
      pickup: trip?.booking.pickup,
      destination: trip?.booking.destination,
      bottomInset: widget.bottomInset,
      driverVehicle: VehicleMarkerKind.fromClassId(
        trip?.booking.vehicleClassId,
      ),
      driverBearing: trip?.live?.position?.bearing,
      driverRecordedAt: trip?.live?.position?.recordedAt,
      driverIdentity: (trip?.id, tracking?.id),
      trackingRoute: _geometry,
      followDriver:
          !state.offline &&
          !state.positionStale &&
          trip?.live?.position != null,
      driver: state.offline || state.positionStale
          ? null
          : trip?.live?.position?.point,
    );
  }
}

/// A driver fix must update the map without rebuilding the receipt/actions.
/// Include every panel input, including accessibility-visible failure states.
bool activeJourneyPanelChanged(ActiveTripState before, ActiveTripState after) =>
    _panelSnapshot(before) != _panelSnapshot(after);

Object _panelSnapshot(ActiveTripState state) => (
  state.phase,
  state.trip?.id,
  state.trip?.booking,
  state.trip?.status,
  state.trip?.live?.driver,
  ((state.trip?.live?.etaSeconds ?? 0) / 60).ceil(),
  state.refreshing,
  state.cancelling,
  state.cancelUncertain,
  state.offline,
  state.positionStale,
  state.failure,
  state.actionFailure,
);
