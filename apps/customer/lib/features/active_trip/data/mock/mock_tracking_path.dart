import 'package:tam_customer/shared/domain/geo_path.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';

/// Synthetic display geometry for simulation. Does not claim street routing.
abstract final class MockTrackingPath {
  static TripTrackingRoute route(
    GeoPoint pickup,
    GeoPoint destination, {
    required bool approaching,
  }) {
    final start = approaching ? GeoPath.mix(pickup, destination, .5) : pickup;
    final end = approaching ? pickup : destination;
    // Alternating segments demonstrate turns instead of cutting straight across
    // the entire journey. Production geometry comes from the routing service.
    final points = <GeoPoint>[start];
    for (final fraction in [.25, .55, .8]) {
      final point = GeoPath.mix(start, end, fraction);
      points.add(
        GeoPoint(latitude: point.latitude, longitude: points.last.longitude),
      );
      points.add(point);
    }
    points.add(
      GeoPoint(latitude: end.latitude, longitude: points.last.longitude),
    );
    points.add(end);
    final clean = <GeoPoint>[];
    for (final point in points) {
      if (clean.isEmpty || GeoPath.meters(clean.last, point) > .1) {
        clean.add(point);
      }
    }
    if (clean.length < 2) clean.add(end);
    return TripTrackingRoute(
      id: 'mock-${approaching ? 'pickup' : 'destination'}-${pickup.latitude}-${pickup.longitude}-${destination.latitude}-${destination.longitude}',
      leg: approaching
          ? TrackingRouteLeg.toPickup
          : TrackingRouteLeg.toDestination,
      points: clean,
    );
  }
}
