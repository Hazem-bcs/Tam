import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tam_customer/features/maps/domain/maps_repository.dart';
import 'package:tam_customer/features/maps/presentation/widgets/map_camera_focus.dart';
import 'package:tam_customer/features/maps/presentation/widgets/route_map_view.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// One live map, with controls kept above the movable journey panel.
class RideJourneyBackdrop extends StatelessWidget {
  const RideJourneyBackdrop({
    super.key,
    this.pickup,
    this.destination,
    this.selection,
    this.driver,
    this.driverBearing,
    this.driverRecordedAt,
    this.driverIdentity,
    this.trackingRoute,
    this.bottomInset,
    this.onSelected,
    this.onLocate,
    this.locating = false,
    this.focus,
  });
  final TripLocation? pickup, destination;
  final GeoPoint? selection, driver;
  final ValueListenable<double>? bottomInset;
  final ValueChanged<GeoPoint>? onSelected;
  final VoidCallback? onLocate;
  final bool locating;
  final double? driverBearing;
  final DateTime? driverRecordedAt;
  final Object? driverIdentity;
  final MapRoute? trackingRoute;
  final MapCameraFocus? focus;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) => RouteMapView(
      height: bounds.maxHeight,
      markerIconSize: 28,
      origin: pickup?.point,
      destination: destination?.point,
      selection: selection,
      driver: driver,
      driverBearing: driverBearing,
      driverRecordedAt: driverRecordedAt,
      driverIdentity: driverIdentity,
      trackingRoute: trackingRoute,
      bottomInset: bottomInset,
      onSelected: onSelected,
      onLocate: onLocate,
      locating: locating,
      focus: focus,
    ),
  );
}
