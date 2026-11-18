import 'package:flutter/material.dart';
import 'package:tam_customer/features/maps/presentation/widgets/route_map_view.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/presentation/vehicle_marker_kind.dart';

import 'active_tracking_geometry.dart';

class ActiveRouteMap extends StatelessWidget {
  const ActiveRouteMap({super.key, required this.trip, required this.stale});
  final Trip trip;
  final bool stale;
  @override
  Widget build(BuildContext context) => Semantics(
    label: AppLocalizations.of(context).activeTripRouteSemantics(
      trip.booking.pickup.label,
      trip.booking.destination.label,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RouteMapView(
          origin: trip.booking.pickup.point,
          destination: trip.booking.destination.point,
          driver: stale ? null : trip.live?.position?.point,
          followDriver: !stale && trip.live?.position != null,
          driverVehicle: VehicleMarkerKind.fromClassId(
            trip.booking.vehicleClassId,
          ),
          driverBearing: trip.live?.position?.bearing,
          driverRecordedAt: trip.live?.position?.recordedAt,
          driverIdentity: (trip.id, trip.live?.route?.id),
          trackingRoute: activeTrackingGeometry(trip),
        ),
        if (stale)
          Text(
            AppLocalizations.of(context).activeTripPositionStale,
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    ),
  );
}
