import 'package:equatable/equatable.dart';

final class GeoPoint extends Equatable {
  GeoPoint({required this.latitude, required this.longitude}) {
    if (!latitude.isFinite || latitude < -90 || latitude > 90) {
      throw ArgumentError.value(latitude, 'latitude');
    }
    if (!longitude.isFinite || longitude < -180 || longitude > 180) {
      throw ArgumentError.value(longitude, 'longitude');
    }
  }

  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}
