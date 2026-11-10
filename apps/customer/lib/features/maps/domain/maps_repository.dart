import 'package:equatable/equatable.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';

final class MapRoute extends Equatable {
  MapRoute({
    required this.origin,
    required this.destination,
    required List<GeoPoint> points,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.provider,
  }) : points = List.unmodifiable(points);
  final GeoPoint origin, destination;
  final List<GeoPoint> points;
  final int distanceMeters, durationSeconds;
  final String provider;
  @override
  List<Object?> get props => [
    origin,
    destination,
    points,
    distanceMeters,
    durationSeconds,
    provider,
  ];
}

abstract interface class MapsRepository {
  Future<List<TripLocation>> search(String query, {required String language});
  Future<TripLocation> reverse(GeoPoint point, {required String language});

  /// Display-only route. Never authorizes a fare or changes a booking.
  Future<MapRoute> route(GeoPoint origin, GeoPoint destination);
}

abstract interface class DeviceLocation {
  /// A single foreground fix after an explicit user action.
  Future<GeoPoint> locate();
}

final class MapsFailure implements Exception {
  const MapsFailure(this.code);
  final String code;
}
