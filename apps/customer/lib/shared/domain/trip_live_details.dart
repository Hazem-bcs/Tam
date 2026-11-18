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
  const DriverPosition({required this.point, required this.recordedAt});
  final GeoPoint point;
  final DateTime recordedAt;
  @override
  List<Object?> get props => [point, recordedAt];
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
  });
  final int revision;
  final DateTime updatedAt, statusChangedAt;
  final TripDriver? driver;
  final DriverPosition? position;
  final int? etaSeconds;
  @override
  List<Object?> get props => [
    revision,
    updatedAt,
    statusChangedAt,
    driver,
    position,
    etaSeconds,
  ];
}
