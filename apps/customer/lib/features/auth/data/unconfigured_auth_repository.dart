import 'package:tam_customer/features/auth/domain/auth_models.dart';
import 'package:tam_customer/features/auth/domain/auth_repository.dart';

/// Fails closed until a real transport is configured; never fakes a login.
final class UnconfiguredAuthRepository implements AuthRepository {
  const UnconfiguredAuthRepository();

  static const _unavailable = AuthFailure(
    code: 'SERVICE_UNAVAILABLE',
    message: BilingualMessage(
      ar: 'خدمة تسجيل الدخول غير متاحة حاليًا. حاول لاحقًا أو تابع كضيف.',
      en: 'Sign-in is currently unavailable. Try again later or continue as a guest.',
    ),
  );

  @override
  Future<OtpChallenge> requestOtp({required String phoneE164}) async =>
      throw _unavailable;

  @override
  Future<OtpChallenge> resendOtp({required String challengeId}) async =>
      throw _unavailable;

  @override
  Future<AuthResult> verifyOtp({
    required String challengeId,
    required String code,
  }) async => throw _unavailable;

  @override
  Future<AuthSession> refreshToken({required String refreshToken}) async =>
      throw _unavailable;

  @override
  Future<AuthUser> currentUser({required String accessToken}) async =>
      throw _unavailable;

  @override
  Future<void> logout({required String refreshToken}) async =>
      throw _unavailable;
}
