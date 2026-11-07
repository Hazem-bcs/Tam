import 'package:tam_customer/features/auth/domain/auth_models.dart';

/// The six Auth API v1 operations. No widgets, HTTP types or storage details.
abstract interface class AuthRepository {
  Future<OtpChallenge> requestOtp({required String phoneE164});
  Future<OtpChallenge> resendOtp({required String challengeId});
  Future<AuthResult> verifyOtp({
    required String challengeId,
    required String code,
  });
  Future<AuthSession> refreshToken({required String refreshToken});
  Future<AuthUser> currentUser({required String accessToken});
  Future<void> logout({required String refreshToken});
}

/// A production implementation must use the OS keystore/keychain.
/// Storage remains independent of the six HTTP operations.
abstract interface class AuthSessionStore {
  Future<AuthSession?> read();
  Future<void> write(AuthSession session);
  Future<void> clear();
}
