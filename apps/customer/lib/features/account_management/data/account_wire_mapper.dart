import 'package:tam_customer/features/auth/domain/phone_number.dart';
import 'package:tam_customer/shared/data/utc_timestamp.dart';
import '../domain/account_management_repository.dart';

abstract final class AccountWireMapper {
  static Map<String, dynamic> _map(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Expected object');
    }
    return value;
  }

  static Map<String, dynamic> _data(Map<String, dynamic> value) {
    if (value.containsKey('error')) {
      throw const FormatException('Expected success');
    }
    return _map(value['data']);
  }

  static String _text(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      throw const FormatException('Expected text');
    }
    return value;
  }

  static AccountAction _action(Object? value) => switch (value) {
    'change_phone' => AccountAction.changePhone,
    'delete_account' => AccountAction.deleteAccount,
    _ => throw const FormatException('Invalid action'),
  };
  static String _phone(Object? value) {
    final text = _text(value);
    if (normalizeSyrianPhone(text) != text) {
      throw const FormatException('Expected canonical phone');
    }
    return text;
  }

  static String _id(Object? value) {
    final text = _text(value);
    if (!RegExp(r'^[A-Za-z0-9_-]{16,128}$').hasMatch(text)) {
      throw const FormatException('Invalid operation ID');
    }
    return text;
  }

  static AccountEligibility eligibility(Map<String, dynamic> json) {
    final d = _data(json);
    final ids = d['active_trip_ids'];
    if (!d.containsKey('phone_e164') || ids is! List) {
      throw const FormatException('Invalid eligibility');
    }
    final values = ids.map(_text).toList();
    if (values.toSet().length != values.length) {
      throw const FormatException('Duplicate trip');
    }
    return AccountEligibility(
      phoneE164: d['phone_e164'] == null ? null : _phone(d['phone_e164']),
      activeTripIds: values,
    );
  }

  static AccountChallenge challenge(Map<String, dynamic> json) {
    final d = _data(json),
        expires = UtcTimestamp.parse(_data(json)['expires_at']),
        resend = UtcTimestamp.parse(_data(json)['resend_at']);
    final attempts = d['attempts_remaining'], revision = d['revision'];
    if (attempts is! int ||
        attempts < 0 ||
        attempts > 5 ||
        revision is! int ||
        revision < 1 ||
        !expires.isAfter(resend)) {
      throw const FormatException('Invalid challenge');
    }
    return AccountChallenge(
      id: _text(d['challenge_id']),
      operationId: _id(d['operation_id']),
      action: _action(d['purpose']),
      phoneE164: _phone(d['phone_e164']),
      expiresAt: expires,
      resendAt: resend,
      attemptsRemaining: attempts,
      revision: revision,
    );
  }

  /// A future transport stores this privately in data, never observable state.
  static String recoveryToken(Map<String, dynamic> json) {
    final token = _text(_data(json)['recovery_token']);
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(token)) {
      throw const FormatException('Invalid recovery credential');
    }
    return token;
  }

  static AccountReceipt? receipt(Map<String, dynamic> json) {
    if (json['data'] == null &&
        json.containsKey('data') &&
        !json.containsKey('error')) {
      return null;
    }
    final d = _data(json);
    if (d['status'] != 'completed') {
      throw const FormatException('Invalid receipt status');
    }
    return AccountReceipt(
      operationId: _id(d['operation_id']),
      challengeId: _text(d['challenge_id']),
      action: _action(d['purpose']),
      completedAt: UtcTimestamp.parse(d['completed_at']),
    );
  }

  static AccountFailure failure(Map<String, dynamic> json) {
    if (json.containsKey('data')) {
      throw const FormatException('Expected failure');
    }
    final e = _map(json['error']), m = _map(_map(json['error'])['message']);
    _text(m['ar']);
    _text(m['en']);
    return AccountFailure(_text(e['code']));
  }
}
