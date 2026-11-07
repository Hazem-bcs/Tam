/// Immutable domain values. Transport parsing belongs to the data layer.
final class AuthUser {
  const AuthUser({
    required this.id,
    required this.phoneE164,
    required this.phoneVerified,
    required this.createdAt,
    this.displayName,
  });

  final String id;
  final String phoneE164;
  final bool phoneVerified;
  final String? displayName;
  final DateTime createdAt;
}

final class OtpChallenge {
  const OtpChallenge({
    required this.id,
    required this.phoneE164,
    required this.expiresAt,
    required this.resendAt,
    required this.attemptsRemaining,
  });

  final String id;
  final String phoneE164;
  final DateTime expiresAt;
  final DateTime resendAt;
  final int attemptsRemaining;

  OtpChallenge withAttempts(int attempts) => OtpChallenge(
    id: id,
    phoneE164: phoneE164,
    expiresAt: expiresAt,
    resendAt: resendAt,
    attemptsRemaining: attempts,
  );
}

/// Never put credentials in BLoC states, logs, SQLite or preferences.
final class AuthSession {
  const AuthSession({
    required this.tokenType,
    required this.accessToken,
    required this.expiresAt,
    required this.refreshToken,
    required this.refreshExpiresAt,
  });

  final String tokenType;
  final String accessToken;
  final DateTime expiresAt;
  final String refreshToken;
  final DateTime refreshExpiresAt;

  @override
  String toString() => 'AuthSession(redacted)';
}

final class AuthResult {
  const AuthResult({
    required this.user,
    required this.session,
    required this.isNewUser,
  });

  final AuthUser user;
  final AuthSession session;
  final bool isNewUser;
}

final class BilingualMessage {
  const BilingualMessage({required this.ar, required this.en});

  final String ar;
  final String en;

  String forLanguage(String languageCode) => languageCode == 'ar' ? ar : en;
}

/// Codes remain strings so additive server codes do not break the UI model.
final class AuthFailure implements Exception {
  const AuthFailure({
    required this.code,
    required this.message,
    this.retryAfterSeconds,
    this.attemptsRemaining,
  });

  final String code;
  final BilingualMessage message;
  final int? retryAfterSeconds;
  final int? attemptsRemaining;

  bool get invalidatesSession =>
      code == 'SESSION_INVALID' ||
      code == 'SESSION_REVOKED' ||
      code == 'ACCOUNT_DISABLED';

  @override
  String toString() => 'AuthFailure($code)';
}
