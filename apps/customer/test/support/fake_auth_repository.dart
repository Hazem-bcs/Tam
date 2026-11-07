import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:tam_customer/features/auth/domain/auth_models.dart';
import 'package:tam_customer/features/auth/domain/auth_repository.dart';

/// A local simulator, not an SMS service or a security boundary.
/// Release/profile construction fails even if a caller bypasses composition.
final class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    DateTime Function()? clock,
    this.latency = const Duration(milliseconds: 350),
    this.otpLifetime = const Duration(seconds: 120),
    this.resendDelay = const Duration(seconds: 60),
    this.accessLifetime = const Duration(minutes: 15),
    this.refreshLifetime = const Duration(days: 30),
    this.rateWindow = const Duration(minutes: 15),
    this.maxAttempts = 5,
    this.maxSends = 3,
    this.deliveryAvailable = true,
  }) : _clock = clock ?? DateTime.now {
    if (!kDebugMode) {
      throw UnsupportedError(
        'Fake authentication is restricted to debug builds.',
      );
    }
  }

  final DateTime Function() _clock;
  final Duration latency;
  final Duration otpLifetime;
  final Duration resendDelay;
  final Duration accessLifetime;
  final Duration refreshLifetime;
  final Duration rateWindow;
  final int maxAttempts;
  final int maxSends;
  final bool deliveryAvailable;
  final _random = Random.secure();
  final _challenges = <String, _ChallengeRecord>{};
  final _limits = <String, _PhoneLimit>{};
  final _users = <String, AuthUser>{};
  final _refreshTokens = <String, _TokenPair>{};
  final _accessTokens = <String, _TokenPair>{};
  Future<void> _pending = Future.value();
  var _codeSequence = 123455;

  /// Out-of-band developer preview only. Never part of an API response/state.
  String? _debugOtpCode;
  String? get debugOtpCode => _debugOtpCode;

  DateTime get _now => _clock().toUtc();

  Future<T> _run<T>(FutureOr<T> Function() action) {
    final result = _pending.then((_) async {
      if (latency > Duration.zero) await Future<void>.delayed(latency);
      return action();
    });
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  @override
  Future<OtpChallenge> requestOtp({required String phoneE164}) => _run(() {
    if (!RegExp(r'^\+9639\d{8}$').hasMatch(phoneE164)) {
      throw _failure('PHONE_INVALID');
    }
    final limit = _limit(phoneE164);
    _checkSend(limit);
    if (!deliveryAvailable) throw _failure('OTP_DELIVERY_UNAVAILABLE');
    // A fresh request cannot bypass a previous challenge's attempt budget.
    if (limit.attempts >= maxAttempts) {
      throw _failure(
        'OTP_TOO_MANY_ATTEMPTS',
        retry: _seconds(limit.startedAt.add(rateWindow).difference(_now)),
        attempts: 0,
      );
    }
    for (final record in _challenges.values) {
      if (record.phone == phoneE164) record.consumed = true;
    }
    final record = _ChallengeRecord(_id('ch'), phoneE164);
    _challenges[record.id] = record;
    _issue(record, limit);
    return _challenge(record, limit);
  });

  @override
  Future<OtpChallenge> resendOtp({required String challengeId}) => _run(() {
    final record = _validChallenge(challengeId);
    final limit = _limit(record.phone);
    if (limit.attempts >= maxAttempts) {
      throw _failure('OTP_TOO_MANY_ATTEMPTS', attempts: 0);
    }
    if (_now.isBefore(record.resendAt)) {
      throw _failure(
        'OTP_RESEND_TOO_EARLY',
        retry: _seconds(record.resendAt.difference(_now)),
      );
    }
    _checkSend(limit);
    if (!deliveryAvailable) throw _failure('OTP_DELIVERY_UNAVAILABLE');
    _issue(record, limit);
    return _challenge(record, limit);
  });

  @override
  Future<AuthResult> verifyOtp({
    required String challengeId,
    required String code,
  }) => _run(() {
    final record = _validChallenge(challengeId);
    final limit = _limit(record.phone);
    if (limit.attempts >= maxAttempts) {
      throw _failure('OTP_TOO_MANY_ATTEMPTS', attempts: 0);
    }
    if (!RegExp(r'^\d{6}$').hasMatch(code) || code != record.code) {
      limit.attempts++;
      final remaining = max(0, maxAttempts - limit.attempts);
      throw _failure(
        remaining == 0 ? 'OTP_TOO_MANY_ATTEMPTS' : 'OTP_INVALID',
        attempts: remaining,
      );
    }
    record.consumed = true;
    _debugOtpCode = null;
    final isNewUser = !_users.containsKey(record.phone);
    final user = _users.putIfAbsent(
      record.phone,
      () => AuthUser(
        id: _id('user'),
        phoneE164: record.phone,
        phoneVerified: true,
        createdAt: _now,
      ),
    );
    final session = _newSession(_SessionFamily(user));
    return AuthResult(user: user, session: session, isNewUser: isNewUser);
  });

  @override
  Future<AuthSession> refreshToken({required String refreshToken}) => _run(() {
    final pair = _refreshTokens[refreshToken];
    if (pair == null) throw _failure('SESSION_INVALID');
    if (pair.family.revoked || pair.rotated) {
      throw _failure('SESSION_REVOKED');
    }
    if (!_now.isBefore(pair.session.refreshExpiresAt)) {
      throw _failure('SESSION_INVALID');
    }
    pair.rotated = true;
    return _newSession(pair.family);
  });

  @override
  Future<AuthUser> currentUser({required String accessToken}) => _run(() {
    final pair = _accessTokens[accessToken];
    if (pair == null) throw _failure('SESSION_INVALID');
    if (pair.family.revoked || pair.rotated) {
      throw _failure('SESSION_REVOKED');
    }
    if (!_now.isBefore(pair.session.expiresAt)) {
      throw _failure('SESSION_INVALID');
    }
    return pair.family.user;
  });

  @override
  Future<void> logout({required String refreshToken}) => _run(() {
    // No access token is required; already revoked/unknown sessions are a no-op.
    _refreshTokens[refreshToken]?.family.revoked = true;
  });

  _PhoneLimit _limit(String phone) {
    final current = _limits[phone];
    if (current != null && _now.isBefore(current.startedAt.add(rateWindow))) {
      return current;
    }
    return _limits[phone] = _PhoneLimit(_now);
  }

  void _checkSend(_PhoneLimit limit) {
    if (limit.sends >= maxSends) {
      throw _failure(
        'RATE_LIMITED',
        retry: _seconds(limit.startedAt.add(rateWindow).difference(_now)),
      );
    }
    final nextSendAt = limit.lastSendAt?.add(resendDelay);
    if (nextSendAt != null && _now.isBefore(nextSendAt)) {
      throw _failure(
        'RATE_LIMITED',
        retry: _seconds(nextSendAt.difference(_now)),
      );
    }
  }

  _ChallengeRecord _validChallenge(String id) {
    final record = _challenges[id];
    if (record == null || record.consumed) {
      throw _failure('OTP_CHALLENGE_INVALID');
    }
    if (!_now.isBefore(record.expiresAt)) throw _failure('OTP_EXPIRED');
    return record;
  }

  void _issue(_ChallengeRecord record, _PhoneLimit limit) {
    limit.sends++;
    limit.lastSendAt = _now;
    // Deterministic for development. A resend still invalidates the old code.
    record.code = (++_codeSequence % 1000000).toString().padLeft(6, '0');
    record.expiresAt = _now.add(otpLifetime);
    record.resendAt = _now.add(resendDelay);
    _debugOtpCode = record.code;
  }

  OtpChallenge _challenge(_ChallengeRecord record, _PhoneLimit limit) =>
      OtpChallenge(
        id: record.id,
        phoneE164: record.phone,
        expiresAt: record.expiresAt,
        resendAt: record.resendAt,
        attemptsRemaining: max(0, maxAttempts - limit.attempts),
      );

  AuthSession _newSession(_SessionFamily family) {
    final session = AuthSession(
      tokenType: 'Bearer',
      accessToken: _id('access'),
      expiresAt: _now.add(accessLifetime),
      refreshToken: _id('refresh'),
      refreshExpiresAt: _now.add(refreshLifetime),
    );
    final pair = _TokenPair(family, session);
    _refreshTokens[session.refreshToken] = pair;
    _accessTokens[session.accessToken] = pair;
    return session;
  }

  String _id(String kind) =>
      'fake_${kind}_${List.generate(16, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';

  int _seconds(Duration value) => max(0, (value.inMilliseconds / 1000).ceil());

  static AuthFailure _failure(String code, {int? retry, int? attempts}) {
    final messages = <String, (String, String)>{
      'PHONE_INVALID': ('رقم الهاتف غير صالح', 'Invalid phone number'),
      'OTP_INVALID': ('رمز التحقق غير صحيح', 'Invalid verification code'),
      'OTP_CHALLENGE_INVALID': (
        'عملية التحقق غير صالحة',
        'Invalid OTP challenge',
      ),
      'OTP_EXPIRED': ('انتهت صلاحية الرمز', 'Verification code expired'),
      'OTP_TOO_MANY_ATTEMPTS': (
        'تجاوزت محاولات التحقق',
        'Too many verification attempts',
      ),
      'OTP_RESEND_TOO_EARLY': (
        'انتظر قبل إعادة الإرسال',
        'Wait before resending',
      ),
      'RATE_LIMITED': (
        'طلبات كثيرة، يرجى المحاولة لاحقاً',
        'Too many requests. Please try again later.',
      ),
      'OTP_DELIVERY_UNAVAILABLE': (
        'خدمة إرسال الرسائل غير متاحة',
        'SMS delivery is unavailable',
      ),
      'SESSION_INVALID': (
        'الجلسة غير صالحة أو منتهية',
        'Invalid or expired session',
      ),
      'SESSION_REVOKED': ('أُبطلت الجلسة', 'Session revoked'),
    };
    final message = messages[code]!;
    return AuthFailure(
      code: code,
      message: BilingualMessage(ar: message.$1, en: message.$2),
      retryAfterSeconds: retry,
      attemptsRemaining: attempts,
    );
  }
}

final class _PhoneLimit {
  _PhoneLimit(this.startedAt);
  final DateTime startedAt;
  DateTime? lastSendAt;
  int attempts = 0;
  int sends = 0;
}

final class _ChallengeRecord {
  _ChallengeRecord(this.id, this.phone);
  final String id;
  final String phone;
  late String code;
  late DateTime expiresAt;
  late DateTime resendAt;
  bool consumed = false;
}

final class _SessionFamily {
  _SessionFamily(this.user);
  final AuthUser user;
  bool revoked = false;
}

final class _TokenPair {
  _TokenPair(this.family, this.session);
  final _SessionFamily family;
  final AuthSession session;
  bool rotated = false;
}
