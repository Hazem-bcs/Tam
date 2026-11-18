import 'package:tam_customer/shared/domain/geo_path.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';

import '../domain/maps_repository.dart';

abstract final class OsrmRouteCodec {
  static MapRoute decode(Object? raw, GeoPoint origin, GeoPoint destination) {
    if (raw is! Map) throw const FormatException('OSRM response');
    if (raw['code'] == 'NoRoute' || raw['code'] == 'NoSegment') {
      throw const MapsFailure('ROUTE_NOT_FOUND');
    }
    if (raw['code'] != 'Ok') throw const FormatException('OSRM status');
    final routes = raw['routes'];
    if (routes is! List || routes.isEmpty || routes.first is! Map) {
      throw const FormatException('OSRM route');
    }
    final route = routes.first as Map;
    final geometry = route['geometry'];
    if (geometry is! Map || geometry['type'] != 'LineString') {
      throw const FormatException('OSRM geometry');
    }
    final coordinates = geometry['coordinates'];
    if (coordinates is! List ||
        coordinates.length < 2 ||
        coordinates.length > 10000) {
      throw const FormatException('OSRM coordinates');
    }
    final points = coordinates.map((value) {
      if (value is! List ||
          value.length != 2 ||
          value[0] is! num ||
          value[1] is! num) {
        throw const FormatException('OSRM point');
      }
      return GeoPoint(
        latitude: (value[1] as num).toDouble(),
        longitude: (value[0] as num).toDouble(),
      );
    }).toList();
    if (GeoPath.meters(origin, points.first) > 100 ||
        GeoPath.meters(destination, points.last) > 100) {
      throw const FormatException('OSRM snap too far');
    }
    int metric(String key, num max) {
      final value = route[key];
      if (value is! num || !value.isFinite || value < 0 || value > max) {
        throw const FormatException('OSRM metric');
      }
      return value.round();
    }

    return MapRoute(
      origin: origin,
      destination: destination,
      points: points,
      distanceMeters: metric('distance', 5000000),
      durationSeconds: metric('duration', 604800),
      provider: 'osrm',
    );
  }
}
