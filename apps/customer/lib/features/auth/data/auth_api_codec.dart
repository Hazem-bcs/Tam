import 'package:tam_customer/features/auth/domain/auth_models.dart';

/// Maps the supplied API contract without leaking JSON concerns into the UI.
/// A future HTTP repository can use this codec unchanged.
abstract final class AuthApiCodec {
  static OtpChallenge challenge(
    Object? payload, {
    required DateTime receivedAt,
  }) {
    final data = _data(payload);
    return OtpChallenge(
      id: _string(data, 'challenge_id'),
      phoneE164: _string(data, 'phone_e164'),
      expiresAt: receivedAt.toUtc().add(
        Duration(seconds: _integer(data, 'expires_in_seconds')),
      ),
      resendAt: receivedAt.toUtc().add(
        Duration(seconds: _integer(data, 'resend_after_seconds')),
      ),
      attemptsRemaining: _integer(data, 'attempts_remaining'),
    );
  }

  static AuthResult verification(
    Object? payload, {
    required DateTime receivedAt,
  }) {
    final data = _data(payload);
    return AuthResult(
      user: _user(_object(data['user'])),
      session: _session(_object(data['session']), receivedAt),
      isNewUser: _boolean(data, 'is_new_user'),
    );
  }

  static AuthSession refreshed(
    Object? payload, {
    required DateTime receivedAt,
  }) => _session(_object(_data(payload)['session']), receivedAt);

  static AuthUser currentUser(Object? payload) =>
      _user(_object(_data(payload)['user']));

  static AuthFailure failure(Object? payload) {
    final error = _object(_object(payload)['error']);
    final message = _object(error['message']);
    return AuthFailure(
      code: _string(error, 'code'),
      message: BilingualMessage(
        ar: _string(message, 'ar'),
        en: _string(message, 'en'),
      ),
      retryAfterSeconds: error['retry_after_seconds'] == null
          ? null
          : _integer(error, 'retry_after_seconds'),
      attemptsRemaining: error['attempts_remaining'] == null
          ? null
          : _integer(error, 'attempts_remaining'),
    );
  }

  static AuthUser _user(Map<String, dynamic> json) {
    final name = json['display_name'];
    if (name != null && name is! String) {
      throw const FormatException('User name');
    }
    final createdAt = DateTime.tryParse(_string(json, 'created_at'));
    if (createdAt == null || !createdAt.isUtc) {
      throw const FormatException('Expected a UTC creation timestamp');
    }
    return AuthUser(
      id: _string(json, 'id'),
      phoneE164: _string(json, 'phone_e164'),
      phoneVerified: _boolean(json, 'phone_verified'),
      displayName: name as String?,
      createdAt: createdAt,
    );
  }

  static AuthSession _session(Map<String, dynamic> json, DateTime receivedAt) {
    final tokenType = _string(json, 'token_type');
    if (tokenType != 'Bearer') throw const FormatException('Expected Bearer');
    return AuthSession(
      tokenType: tokenType,
      accessToken: _string(json, 'access_token'),
      expiresAt: receivedAt.toUtc().add(
        Duration(seconds: _integer(json, 'expires_in_seconds')),
      ),
      refreshToken: _string(json, 'refresh_token'),
      refreshExpiresAt: receivedAt.toUtc().add(
        Duration(seconds: _integer(json, 'refresh_expires_in_seconds')),
      ),
    );
  }

  static Map<String, dynamic> _data(Object? payload) =>
      _object(_object(payload)['data']);

  static Map<String, dynamic> _object(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object');
    }
    return value;
  }

  static String _string(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.isEmpty) {
      throw FormatException('Expected $key');
    }
    return value;
  }

  static int _integer(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! int || value < 0) throw FormatException('Expected $key');
    return value;
  }

  static bool _boolean(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! bool) throw FormatException('Expected $key');
    return value;
  }
}
