import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/shared/data/trip_wire_codec.dart';
import 'package:tam_customer/shared/data/utc_timestamp.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// Strict transport mapping seam for the proposed v1 contract; no HTTP here.
abstract final class RideContractParser {
  static List<RidePlace> places(Map<String, dynamic> response) {
    final raw = response['data'];
    final meta = response['meta'];
    if (raw is! List || meta is! Map || !meta.containsKey('next_cursor')) {
      throw const FormatException('Invalid places page');
    }
    return List.unmodifiable(
      raw.map((value) {
        final place = _map(value);
        return RidePlace(
          id: _text(place, 'id'),
          location: TripLocation(
            label: _text(place, 'label'),
            point: _point(place),
          ),
          englishLabel: _text(place, 'label_en'),
        );
      }),
    );
  }

  static RideQuote quote(Map<String, dynamic> response) {
    final data = _map(response['data']);
    final quote = RideQuote(
      id: _text(data, 'quote_id'),
      pickup: _location(data['pickup']),
      destination: _location(data['destination']),
      vehicleClass: _vehicle(_text(data, 'vehicle_class_id')),
      fare: _money(data['fare']),
      paymentMethod: TripWireCodec.paymentMethod(data['payment_method']),
      couponCode: TripWireCodec.couponCode(data['coupon_code']),
      discount: data['discount'] == null ? null : _money(data['discount']),
      distanceMeters: _positiveInt(data, 'distance_meters'),
      durationMinutes: _positiveInt(data, 'duration_minutes'),
      expiresAt: UtcTimestamp.parse(data['expires_at']),
      scheduledAt: data['scheduled_at'] == null
          ? null
          : UtcTimestamp.parse(data['scheduled_at']),
    );
    if ((quote.couponCode == null) != (quote.discount == null) ||
        (quote.discount != null &&
            (quote.discount!.currency != quote.fare.currency ||
                quote.discount!.minorUnit != quote.fare.minorUnit))) {
      throw const FormatException('Invalid quote discount');
    }
    return quote;
  }

  static Trip trip(Map<String, dynamic> response) =>
      TripWireCodec.fromJson(_map(response['data']));

  static RideRequestFailure failure(Map<String, dynamic> response) {
    final error = _map(response['error']);
    final message = _map(error['message']);
    _text(message, 'ar');
    _text(message, 'en');
    return RideRequestFailure(_text(error, 'code'));
  }

  static TripLocation _location(Object? value) {
    final map = _map(value);
    return TripLocation(label: _text(map, 'label'), point: _point(map));
  }

  static GeoPoint _point(Map<String, dynamic> map) {
    final lat = map['latitude'];
    final lon = map['longitude'];
    if (lat is! num || lon is! num) {
      throw const FormatException('Missing coordinates');
    }
    try {
      return GeoPoint(latitude: lat.toDouble(), longitude: lon.toDouble());
    } on ArgumentError {
      throw const FormatException('Out-of-range coordinates');
    }
  }

  static Money _money(Object? value) {
    final map = _map(value);
    try {
      return Money(
        amountMinor: _nonNegativeInt(map, 'amount_minor'),
        currency: _text(map, 'currency'),
        minorUnit: _nonNegativeInt(map, 'minor_unit'),
      );
    } on ArgumentError {
      throw const FormatException('Invalid money');
    }
  }

  static RideVehicleClass _vehicle(String value) {
    for (final vehicle in RideVehicleClass.values) {
      if (vehicle.name == value) return vehicle;
    }
    throw const FormatException('Unknown vehicle class');
  }

  static int _positiveInt(Map<String, dynamic> map, String key) {
    final number = _nonNegativeInt(map, key);
    if (number == 0) throw FormatException('Expected positive $key');
    return number;
  }

  static int _nonNegativeInt(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! int || value < 0) {
      throw FormatException('Expected nonnegative integer $key');
    }
    return value;
  }

  static String _text(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Expected nonempty string $key');
    }
    return value;
  }

  static Map<String, dynamic> _map(Object? value) {
    if (value is Map<String, dynamic>) return value;
    throw const FormatException('Expected JSON object');
  }
}
