import 'package:tam_customer/shared/data/utc_timestamp.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';

abstract final class TripLiveCodec {
  static TripLiveDetails parse(Object? raw) {
    final map = object(raw);
    final revision = map['revision'];
    final eta = map['eta_seconds'];
    if (revision is! int ||
        revision < 1 ||
        (eta != null && (eta is! int || eta < 0))) {
      throw const FormatException('Invalid live revision/ETA');
    }
    for (final key in ['driver', 'position', 'eta_seconds']) {
      if (!map.containsKey(key)) throw FormatException('Missing $key');
    }
    final updatedAt = UtcTimestamp.parse(map['updated_at']);
    final changedAt = UtcTimestamp.parse(map['status_changed_at']);
    if (changedAt.isAfter(updatedAt)) {
      throw const FormatException('Invalid phase time');
    }
    final driver = map['driver'] == null ? null : driverFromJson(map['driver']);
    final position = map['position'] == null
        ? null
        : positionFromJson(map['position']);
    if (position != null &&
        (driver == null || position.recordedAt.isAfter(updatedAt))) {
      throw const FormatException('Invalid driver position');
    }
    return TripLiveDetails(
      revision: revision,
      updatedAt: updatedAt,
      statusChangedAt: changedAt,
      driver: driver,
      position: position,
      etaSeconds: eta as int?,
      route: map['route'] == null ? null : routeFromJson(map['route']),
    );
  }

  static TripDriver driverFromJson(Object? raw) {
    final map = object(raw);
    final rating = map['rating'];
    if (rating is! num || !rating.isFinite || rating < 0 || rating > 5) {
      throw const FormatException('Invalid rating');
    }
    return TripDriver(
      id: text(map, 'id'),
      name: text(map, 'name'),
      nameEn: text(map, 'name_en'),
      vehicle: text(map, 'vehicle'),
      vehicleEn: text(map, 'vehicle_en'),
      plate: text(map, 'plate'),
      rating: rating.toDouble(),
      vehicleImageUrl: _vehicleImageUrl(map['vehicle_image_url']),
    );
  }

  static DriverPosition positionFromJson(Object? raw) {
    final map = object(raw);
    final lat = map['latitude'], lng = map['longitude'];
    if (lat is! num || lng is! num) {
      throw const FormatException('Invalid coordinates');
    }
    try {
      final bearing = map['bearing'];
      if (bearing != null &&
          (bearing is! num ||
              !bearing.isFinite ||
              bearing < 0 ||
              bearing >= 360)) {
        throw const FormatException('Invalid bearing');
      }
      return DriverPosition(
        point: GeoPoint(latitude: lat.toDouble(), longitude: lng.toDouble()),
        recordedAt: UtcTimestamp.parse(map['recorded_at']),
        bearing: (bearing as num?)?.toDouble(),
      );
    } on ArgumentError {
      throw const FormatException('Invalid coordinates');
    }
  }

  static TripTrackingRoute routeFromJson(Object? raw) {
    final map = object(raw);
    final points = map['coordinates'];
    if (points is! List || points.length < 2 || points.length > 10000) {
      throw const FormatException('Invalid tracking geometry');
    }
    return TripTrackingRoute(
      id: text(map, 'id'),
      leg: switch (map['leg']) {
        'to_pickup' => TrackingRouteLeg.toPickup,
        'to_destination' => TrackingRouteLeg.toDestination,
        _ => throw const FormatException('Invalid route leg'),
      },
      points: points.map((value) {
        if (value is! List ||
            value.length != 2 ||
            value[0] is! num ||
            value[1] is! num) {
          throw const FormatException('Invalid route coordinate');
        }
        try {
          return GeoPoint(
            latitude: (value[1] as num).toDouble(),
            longitude: (value[0] as num).toDouble(),
          );
        } on ArgumentError {
          throw const FormatException('Invalid route coordinate');
        }
      }).toList(),
    );
  }

  static Map<String, dynamic> encode(TripLiveDetails live) => {
    'revision': live.revision,
    'updated_at': live.updatedAt.toUtc().toIso8601String(),
    'status_changed_at': live.statusChangedAt.toUtc().toIso8601String(),
    'driver': live.driver == null ? null : driverJson(live.driver!),
    'position': live.position == null
        ? null
        : {
            'latitude': live.position!.point.latitude,
            'longitude': live.position!.point.longitude,
            'recorded_at': live.position!.recordedAt.toUtc().toIso8601String(),
            if (live.position!.bearing != null)
              'bearing': live.position!.bearing,
          },
    'eta_seconds': live.etaSeconds,
    if (live.route != null)
      'route': {
        'id': live.route!.id,
        'leg': live.route!.leg == TrackingRouteLeg.toPickup
            ? 'to_pickup'
            : 'to_destination',
        'coordinates': live.route!.points
            .map((p) => [p.longitude, p.latitude])
            .toList(),
      },
  };
  static Map<String, dynamic> driverJson(TripDriver driver) => {
    'id': driver.id,
    'name': driver.name,
    'name_en': driver.nameEn,
    'vehicle': driver.vehicle,
    'vehicle_en': driver.vehicleEn,
    'plate': driver.plate,
    'rating': driver.rating,
    if (driver.vehicleImageUrl != null)
      'vehicle_image_url': driver.vehicleImageUrl,
  };
  static String? _vehicleImageUrl(Object? value) {
    if (value is! String) return null;
    final url = value.trim();
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      return null;
    }
    return url;
  }

  static Map<String, dynamic> object(Object? value) {
    if (value is Map<String, dynamic>) return value;
    throw const FormatException('Expected object');
  }

  static String text(Map<String, dynamic> map, String field) {
    final value = map[field];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Invalid $field');
    }
    return value;
  }
}
