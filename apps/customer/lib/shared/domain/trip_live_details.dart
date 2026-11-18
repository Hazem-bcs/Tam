import 'package:equatable/equatable.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';

final class TripDriver extends Equatable {
  const TripDriver({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.vehicle,
    required this.vehicleEn,
    required this.plate,
    required this.rating,
    this.vehicleImageUrl,
  });
  final String id, name, nameEn, vehicle, vehicleEn, plate;
  final double rating;
  final String? vehicleImageUrl;
  @override
  List<Object?> get props => [
    id,
    name,
    nameEn,
    vehicle,
    vehicleEn,
    plate,
    rating,
    vehicleImageUrl,
  ];
}

final class DriverPosition extends Equatable {
  const DriverPosition({
    required this.point,
    required this.recordedAt,
    this.bearing,
  });
  final GeoPoint point;
  final DateTime recordedAt;
  final double? bearing;
  @override
  List<Object?> get props => [point, recordedAt, bearing];
}

/// Revision covers the status and all live fields as one atomic resource.
final class TripLiveDetails extends Equatable {
  const TripLiveDetails({
    required this.revision,
    required this.updatedAt,
    required this.statusChangedAt,
    this.driver,
    this.position,
    this.etaSeconds,
    this.route,
  });
  final int revision;
  final DateTime updatedAt, statusChangedAt;
  final TripDriver? driver;
  final DriverPosition? position;
  final int? etaSeconds;
  final TripTrackingRoute? route;
  @override
  List<Object?> get props => [
    revision,
    updatedAt,
    statusChangedAt,
    driver,
    position,
    etaSeconds,
    route,
  ];
}

enum TrackingRouteLeg { toPickup, toDestination }

/// Server-planned geometry for the current phase, not a fare authority.
final class TripTrackingRoute extends Equatable {
  TripTrackingRoute({
    required this.id,
    required this.leg,
    required List<GeoPoint> points,
  }) : points = List.unmodifiable(points);
  final String id;
  final TrackingRouteLeg leg;
  final List<GeoPoint> points;
  @override
  List<Object?> get props => [id, leg, points];
}
