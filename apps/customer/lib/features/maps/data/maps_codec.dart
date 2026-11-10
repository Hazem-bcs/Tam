import 'dart:math' as math;
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import '../domain/maps_repository.dart';

abstract final class MapsCodec {
  static Map<String, dynamic> object(Object? raw) {
    if (raw is! Map<String, dynamic>) throw const FormatException('Object');
    return raw;
  }

  static Object? data(Object? raw) {
    final body = object(raw);
    if (body.containsKey('error') || !body.containsKey('data')) {
      throw const FormatException('Envelope');
    }
    return body['data'];
  }

  static double number(Object? value) {
    if (value is! num || !value.isFinite) throw const FormatException('Number');
    return value.toDouble();
  }

  static String text(Object? value) {
    if (value is! String || value.trim().isEmpty || value.runes.length > 200) {
      throw const FormatException('Label');
    }
    return value.trim();
  }

  static TripLocation location(Object? raw, String language) {
    final v = object(raw);
    final ar = text(v['label']), en = text(v['label_en']);
    return TripLocation(
      label: language == 'ar' ? ar : en,
      point: GeoPoint(
        latitude: number(v['latitude']),
        longitude: number(v['longitude']),
      ),
    );
  }

  static Map<String, double> point(GeoPoint p) => {
    'latitude': p.latitude,
    'longitude': p.longitude,
  };

  static MapRoute route(Object? raw, GeoPoint origin, GeoPoint destination) {
    final v = object(data(raw));
    GeoPoint endpoint(String key) {
      final p = object(v[key]);
      return GeoPoint(
        latitude: number(p['latitude']),
        longitude: number(p['longitude']),
      );
    }

    final geometry = object(v['geometry']);
    final coordinates = geometry['coordinates'];
    if (endpoint('origin') != origin ||
        endpoint('destination') != destination ||
        geometry['type'] != 'LineString' ||
        coordinates is! List ||
        coordinates.length < 2 ||
        coordinates.length > 10000 ||
        v['distance_meters'] is! int ||
        (v['distance_meters'] as int) <= 0 ||
        v['duration_seconds'] is! int ||
        (v['duration_seconds'] as int) <= 0 ||
        !{'osrm', 'google'}.contains(v['provider'])) {
      throw const FormatException('Route');
    }
    final points = coordinates.map((raw) {
      if (raw is! List || raw.length != 2) {
        throw const FormatException('Coordinate');
      }
      // GeoJSON is longitude,latitude; domain is latitude,longitude.
      return GeoPoint(latitude: number(raw[1]), longitude: number(raw[0]));
    }).toList();
    if (meters(points.first, origin) > 200 ||
        meters(points.last, destination) > 200) {
      throw const FormatException('Route endpoints');
    }
    return MapRoute(
      origin: origin,
      destination: destination,
      points: points,
      distanceMeters: v['distance_meters'] as int,
      durationSeconds: v['duration_seconds'] as int,
      provider: v['provider'] as String,
    );
  }

  static double meters(GeoPoint a, GeoPoint b) {
    final lat = (b.latitude - a.latitude) * math.pi / 180;
    final lon = (b.longitude - a.longitude) * math.pi / 180;
    final h =
        math.pow(math.sin(lat / 2), 2) +
        math.cos(a.latitude * math.pi / 180) *
            math.cos(b.latitude * math.pi / 180) *
            math.pow(math.sin(lon / 2), 2);
    return 12742000 * math.asin(math.sqrt(h.clamp(0, 1)));
  }
}
