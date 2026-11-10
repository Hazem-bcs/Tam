import 'package:tam_customer/features/maps/domain/maps_repository.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';

final origin = GeoPoint(latitude: 33.5, longitude: 36.25);
final destination = GeoPoint(latitude: 33.519, longitude: 36.283);
Map<String, dynamic> routeJson() => {
  'data': {
    'origin': {'latitude': 33.5, 'longitude': 36.25},
    'destination': {'latitude': 33.519, 'longitude': 36.283},
    'geometry': {
      'type': 'LineString',
      'coordinates': [
        [36.25, 33.5],
        [36.27, 33.51],
        [36.283, 33.519],
      ],
    },
    'distance_meters': 5019,
    'duration_seconds': 1080,
    'provider': 'osrm',
  },
};
MapRoute routeValue(GeoPoint a, GeoPoint b) => MapRoute(
  origin: a,
  destination: b,
  points: [a, b],
  distanceMeters: 5019,
  durationSeconds: 1080,
  provider: 'osrm',
);

final class MapsProbe implements MapsRepository {
  int routes = 0, searches = 0;
  Future<MapRoute> Function(GeoPoint, GeoPoint)? onRoute;
  Future<TripLocation> Function(GeoPoint)? onReverse;
  Future<List<TripLocation>> Function(String)? onSearch;
  @override
  Future<MapRoute> route(GeoPoint a, GeoPoint b) async {
    routes++;
    return onRoute == null ? routeValue(a, b) : onRoute!(a, b);
  }

  @override
  Future<TripLocation> reverse(GeoPoint p, {required String language}) async =>
      onReverse == null
      ? TripLocation(label: 'المكان', point: p)
      : onReverse!(p);
  @override
  Future<List<TripLocation>> search(
    String q, {
    required String language,
  }) async {
    searches++;
    return onSearch == null ? [] : onSearch!(q);
  }
}

final class LocationProbe implements DeviceLocation {
  int calls = 0;
  Future<GeoPoint> Function()? onLocate;
  @override
  Future<GeoPoint> locate() async {
    calls++;
    return onLocate == null ? origin : onLocate!();
  }
}
