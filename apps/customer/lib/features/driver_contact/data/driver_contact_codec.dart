import 'package:tam_customer/shared/data/utc_timestamp.dart';
import '../domain/driver_contact_repository.dart';

abstract final class DriverContactCodec {
  static Map<String, dynamic> _map(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Expected object');
    }
    return value;
  }

  static String _text(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      throw const FormatException('Expected text');
    }
    return value;
  }

  static DriverContact decode(Map<String, dynamic> json) {
    if (json.containsKey('error')) {
      throw const FormatException('Expected success');
    }
    final d = _map(json['data']);
    final phone = _text(d['phone_e164']);
    if (!RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(phone)) {
      throw const FormatException('Invalid phone target');
    }
    return DriverContact(
      tripId: _text(d['trip_id']),
      driverId: _text(d['driver_id']),
      phoneE164: phone,
      expiresAt: UtcTimestamp.parse(d['expires_at']),
    );
  }

  static DriverContactFailure failure(Map<String, dynamic> json) {
    if (json.containsKey('data')) throw const FormatException('Expected error');
    final e = _map(json['error']), m = _map(_map(json['error'])['message']);
    _text(m['ar']);
    _text(m['en']);
    return DriverContactFailure(_text(e['code']));
  }
}
