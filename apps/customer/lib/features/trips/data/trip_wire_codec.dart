import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// Proposed HTTP v1 wire format. Strict parsing avoids silent price/status defaults.
abstract final class TripWireCodec {
  static Trip fromJson(Map<String, dynamic> value) {
    final status = switch (value['status']) {
      'requested' => TripStatus.requested,
      'confirmed' => TripStatus.confirmed,
      'in_progress' => TripStatus.inProgress,
      'completed' => TripStatus.completed,
      'cancelled' => TripStatus.cancelled,
      _ => throw const FormatException('Unknown trip status'),
    };
    final timestamp = DateTime.parse(_string(value, 'created_at'));
    if (!timestamp.isUtc || !_string(value, 'created_at').endsWith('Z')) {
      throw const FormatException('created_at must be ISO-8601 UTC');
    }
    return Trip(
      id: _string(value, 'id'),
      createdAt: timestamp,
      status: status,
      booking: TripBookingInput(
        pickup: _location(value['pickup']),
        destination: _location(value['destination']),
        vehicleClassId: _string(value, 'vehicle_class_id'),
        fare: _money(value['fare']),
      ),
    );
  }

  static Map<String, dynamic> toJson(Trip trip) => {
    'id': trip.id,
    'pickup': _locationJson(trip.booking.pickup),
    'destination': _locationJson(trip.booking.destination),
    'vehicle_class_id': trip.booking.vehicleClassId,
    'fare': {
      'amount_minor': trip.booking.fare.amountMinor,
      'currency': trip.booking.fare.currency,
      'minor_unit': trip.booking.fare.minorUnit,
    },
    'status': switch (trip.status) {
      TripStatus.requested => 'requested',
      TripStatus.confirmed => 'confirmed',
      TripStatus.inProgress => 'in_progress',
      TripStatus.completed => 'completed',
      TripStatus.cancelled => 'cancelled',
    },
    'created_at': trip.createdAt.toUtc().toIso8601String(),
  };

  static TripLocation _location(Object? raw) {
    final value = _map(raw);
    final latitude = value['latitude'], longitude = value['longitude'];
    if (latitude is! num || longitude is! num) {
      throw const FormatException('Coordinates must be numbers');
    }
    return TripLocation(
      label: _string(value, 'label'),
      point: GeoPoint(
        latitude: latitude.toDouble(),
        longitude: longitude.toDouble(),
      ),
    );
  }

  static Map<String, dynamic> _locationJson(TripLocation value) => {
    'label': value.label,
    'latitude': value.point.latitude,
    'longitude': value.point.longitude,
  };

  static Money _money(Object? raw) {
    final value = _map(raw);
    if (value['amount_minor'] is! int || value['minor_unit'] is! int) {
      throw const FormatException('Money must use integer minor units');
    }
    return Money(
      amountMinor: value['amount_minor'] as int,
      currency: _string(value, 'currency'),
      minorUnit: value['minor_unit'] as int,
    );
  }

  static Map<String, dynamic> _map(Object? raw) {
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Expected object');
    }
    return raw;
  }

  static String _string(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value is! String || value.isEmpty) {
      throw FormatException('Invalid $field');
    }
    return value;
  }
}
