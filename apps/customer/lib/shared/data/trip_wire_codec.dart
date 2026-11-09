import 'package:tam_customer/shared/data/utc_timestamp.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// Proposed HTTP v1 wire format. Strict parsing avoids silent price/status defaults.
abstract final class TripWireCodec {
  static Trip fromJson(Map<String, dynamic> value) {
    final status = switch (value['status']) {
      'scheduled' => TripStatus.scheduled,
      'requested' => TripStatus.requested,
      'confirmed' => TripStatus.confirmed,
      'in_progress' => TripStatus.inProgress,
      'completed' => TripStatus.completed,
      'cancelled' => TripStatus.cancelled,
      _ => throw const FormatException('Unknown trip status'),
    };
    final timestamp = UtcTimestamp.parse(value['created_at']);
    final scheduledAt = value['scheduled_at'] == null
        ? null
        : UtcTimestamp.parse(value['scheduled_at']);
    if ((status == TripStatus.scheduled && scheduledAt == null) ||
        (scheduledAt != null && !scheduledAt.isAfter(timestamp))) {
      throw const FormatException('Invalid scheduled trip time');
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
        scheduledAt: scheduledAt,
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
      TripStatus.scheduled => 'scheduled',
      TripStatus.requested => 'requested',
      TripStatus.confirmed => 'confirmed',
      TripStatus.inProgress => 'in_progress',
      TripStatus.completed => 'completed',
      TripStatus.cancelled => 'cancelled',
    },
    'created_at': trip.createdAt.toUtc().toIso8601String(),
    if (trip.booking.scheduledAt != null)
      'scheduled_at': trip.booking.scheduledAt!.toUtc().toIso8601String(),
  };

  static TripLocation _location(Object? raw) {
    final value = _map(raw);
    final latitude = value['latitude'], longitude = value['longitude'];
    if (latitude is! num ||
        longitude is! num ||
        !latitude.isFinite ||
        !longitude.isFinite ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
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
    final amount = value['amount_minor'];
    final unit = value['minor_unit'];
    final currency = _string(value, 'currency');
    if (amount is! int ||
        unit is! int ||
        amount < 0 ||
        unit < 0 ||
        unit > 3 ||
        !RegExp(r'^[A-Z]{3}$').hasMatch(currency)) {
      throw const FormatException('Money must use integer minor units');
    }
    return Money(amountMinor: amount, currency: currency, minorUnit: unit);
  }

  static Map<String, dynamic> _map(Object? raw) {
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Expected object');
    }
    return raw;
  }

  static String _string(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Invalid $field');
    }
    return value;
  }
}
