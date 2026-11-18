import 'package:tam_customer/features/maps/domain/maps_repository.dart';
import 'package:tam_customer/shared/domain/geo_path.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';

/// Use only geometry matching the active phase. Never replace missing geometry
/// with an invented road line in production.
MapRoute? activeTrackingGeometry(Trip trip) {
  final route = trip.live?.route;
  if (route == null || route.points.length < 2 || !trip.status.isActive) {
    return null;
  }
  final toDestination = trip.status == TripStatus.inProgress;
  if (route.leg !=
      (toDestination
          ? TrackingRouteLeg.toDestination
          : TrackingRouteLeg.toPickup)) {
    return null;
  }
  final target = toDestination
      ? trip.booking.destination.point
      : trip.booking.pickup.point;
  if (GeoPath.meters(route.points.last, target) > 100) return null;
  return MapRoute(
    origin: route.points.first,
    destination: route.points.last,
    points: route.points,
    distanceMeters: GeoPath(route.points).length.round(),
    durationSeconds: 0,
    provider: 'trip-tracking',
  );
}
