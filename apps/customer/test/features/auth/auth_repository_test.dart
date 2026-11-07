import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/auth/data/auth_api_codec.dart';
import 'package:tam_customer/features/auth/data/unconfigured_auth_repository.dart';
import 'package:tam_customer/features/auth/domain/auth_models.dart';
import 'package:tam_customer/features/auth/domain/phone_number.dart';

import '../../support/fake_auth_repository.dart';

const phone = '+963912345678';

void main() {
  late DateTime now;
  late FakeAuthRepository fake;
  setUp(() {
    now = DateTime.utc(2026, 11, 4, 12);
    fake = FakeAuthRepository(clock: () => now, latency: Duration.zero);
  });

  test('normalizes local, international, Arabic and Persian mobile digits', () {
    for (final value in [
      '0912345678',
      phone,
      '963912345678',
      '963 912 345 678',
      '00963 912 345 678',
      '(0912) 345-678',
      '٠٩١٢٣٤٥٦٧٨',
      '۰۹۱۲۳۴۵۶۷۸',
      '٩٦٣٩١٢٣٤٥٦٧٨',
      '۹۶۳۹۱۲۳۴۵۶۷۸',
    ]) {
      expect(normalizeSyrianPhone(value), phone);
    }
    for (final value in [
      '',
      '912345678',
      '+936912345678',
      '+9630912345678',
      '9630912345678',
      '96391234567',
      '9639123456789',
      '963112345678',
      'abc',
      '09123456789',
    ]) {
      expect(normalizeSyrianPhone(value), isNull);
    }
    expect(normalizeDigits('٠١٢٣٤٥'), '012345');
  });

  test(
    'parses the supplied contract examples without changing field types',
    () {
      final examples =
          jsonDecode(File('test/fixtures/auth_api_v1.json').readAsStringSync())
              as Map<String, dynamic>;
      final challenge = AuthApiCodec.challenge(
        examples['challenge'],
        receivedAt: now,
      );
      expect(challenge.expiresAt, now.add(const Duration(seconds: 120)));
      expect(challenge.resendAt, now.add(const Duration(seconds: 60)));
      final result = AuthApiCodec.verification(
        examples['verification'],
        receivedAt: now,
      );
      expect(result.user.id, 'b8a9c7d1-2e44-4df3-9012-6f8a2b47e921');
      expect(result.user.displayName, isNull);
      expect(result.user.createdAt.isUtc, isTrue);
      expect(result.isNewUser, isTrue);
      expect(result.session.expiresAt, now.add(const Duration(seconds: 900)));
      expect(result.session.toString(), isNot(contains('<access_token>')));
      expect(
        AuthApiCodec.currentUser(examples['current_user']).id,
        result.user.id,
      );
      expect(
        AuthApiCodec.refreshed(
          examples['refreshed'],
          receivedAt: now,
        ).tokenType,
        'Bearer',
      );
      final failure = AuthApiCodec.failure(examples['otp_invalid']);
      expect(failure.code, 'OTP_INVALID');
      expect(failure.attemptsRemaining, 3);
      expect(failure.message.forLanguage('ar'), 'رمز التحقق غير صحيح');
      expect(failure.message.forLanguage('en'), 'Invalid verification code');
      expect(
        AuthApiCodec.failure(examples['rate_limited']).retryAfterSeconds,
        45,
      );
    },
  );

  test('rejects incompatible numeric IDs, string TTLs and plain messages', () {
    final examples =
        jsonDecode(File('test/fixtures/auth_api_v1.json').readAsStringSync())
            as Map<String, dynamic>;
    final invalid =
        jsonDecode(jsonEncode(examples['verification']))
            as Map<String, dynamic>;
    invalid['data']['user']['id'] = 42;
    expect(
      () => AuthApiCodec.verification(invalid, receivedAt: now),
      throwsFormatException,
    );
    final challenge =
        jsonDecode(jsonEncode(examples['challenge'])) as Map<String, dynamic>;
    challenge['data']['expires_in_seconds'] = '120';
    expect(
      () => AuthApiCodec.challenge(challenge, receivedAt: now),
      throwsFormatException,
    );
    expect(
      () => AuthApiCodec.failure({
        'error': {'code': 'OTP_INVALID', 'message': 'wrong'},
      }),
      throwsFormatException,
    );
  });

  test('accepts additive fields and unknown error codes', () {
    final failure = AuthApiCodec.failure({
      'error': {
        'code': 'FUTURE_CODE',
        'message': {'ar': 'خطأ', 'en': 'Error'},
        'extra': true,
      },
    });
    expect(failure.code, 'FUTURE_CODE');
  });

  test('new and existing users share the same OTP flow', () async {
    final challenge = await fake.requestOtp(phoneE164: phone);
    final result = await fake.verifyOtp(
      challengeId: challenge.id,
      code: fake.debugOtpCode!,
    );
    expect(result.isNewUser, isTrue);
    expect(result.user.displayName, isNull);
    now = now.add(const Duration(seconds: 61));
    final next = await fake.requestOtp(phoneE164: phone);
    final returning = await fake.verifyOtp(
      challengeId: next.id,
      code: fake.debugOtpCode!,
    );
    expect(returning.isNewUser, isFalse);
    expect(returning.user.id, result.user.id);
  });

  test('concurrent verification consumes a challenge only once', () async {
    final challenge = await fake.requestOtp(phoneE164: phone);
    final code = fake.debugOtpCode!;
    Future<Object> verify() async {
      try {
        return await fake.verifyOtp(challengeId: challenge.id, code: code);
      } on AuthFailure catch (failure) {
        return failure;
      }
    }

    final results = await Future.wait([verify(), verify()]);
    expect(results.whereType<AuthResult>(), hasLength(1));
    expect(
      results.whereType<AuthFailure>().single.code,
      'OTP_CHALLENGE_INVALID',
    );
  });

  test(
    'resend retains the ID, invalidates the old code and preserves attempts',
    () async {
      final first = await fake.requestOtp(phoneE164: phone);
      final oldCode = fake.debugOtpCode!;
      await expectLater(
        fake.verifyOtp(challengeId: first.id, code: '000000'),
        _fails('OTP_INVALID'),
      );
      await expectLater(
        fake.resendOtp(challengeId: first.id),
        _fails('OTP_RESEND_TOO_EARLY'),
      );
      now = now.add(const Duration(seconds: 61));
      final resent = await fake.resendOtp(challengeId: first.id);
      final newCode = fake.debugOtpCode!;
      expect(resent.id, first.id);
      expect(resent.attemptsRemaining, 4);
      expect(newCode, isNot(oldCode));
      await expectLater(
        fake.verifyOtp(challengeId: first.id, code: oldCode),
        _fails('OTP_INVALID'),
      );
      expect(
        (await fake.verifyOtp(
          challengeId: first.id,
          code: newCode,
        )).user.phoneVerified,
        isTrue,
      );
    },
  );

  test('new requests cannot bypass phone-level attempt limits', () async {
    final challenge = await fake.requestOtp(phoneE164: phone);
    for (var i = 0; i < 5; i++) {
      await expectLater(
        fake.verifyOtp(challengeId: challenge.id, code: '000000'),
        _fails(i == 4 ? 'OTP_TOO_MANY_ATTEMPTS' : 'OTP_INVALID'),
      );
    }
    now = now.add(const Duration(seconds: 61));
    await expectLater(
      fake.requestOtp(phoneE164: phone),
      _fails('OTP_TOO_MANY_ATTEMPTS'),
    );
    await expectLater(
      fake.resendOtp(challengeId: challenge.id),
      _fails('OTP_TOO_MANY_ATTEMPTS'),
    );
  });

  test('expired and invalid challenges do not authenticate', () async {
    await expectLater(
      fake.resendOtp(challengeId: 'missing'),
      _fails('OTP_CHALLENGE_INVALID'),
    );
    final challenge = await fake.requestOtp(phoneE164: phone);
    final code = fake.debugOtpCode!;
    now = now.add(const Duration(seconds: 121));
    await expectLater(
      fake.verifyOtp(challengeId: challenge.id, code: code),
      _fails('OTP_EXPIRED'),
    );
    await expectLater(
      fake.resendOtp(challengeId: challenge.id),
      _fails('OTP_EXPIRED'),
    );
  });

  test('sends are rate limited, including repeated fresh challenges', () async {
    await fake.requestOtp(phoneE164: phone);
    await expectLater(
      fake.requestOtp(phoneE164: phone),
      _fails('RATE_LIMITED'),
    );
    now = now.add(const Duration(seconds: 61));
    await fake.requestOtp(phoneE164: phone);
    now = now.add(const Duration(seconds: 61));
    await fake.requestOtp(phoneE164: phone);
    now = now.add(const Duration(seconds: 61));
    await expectLater(
      fake.requestOtp(phoneE164: phone),
      _fails('RATE_LIMITED'),
    );
  });

  test(
    'rotated tokens cannot be replayed and logout revokes the family',
    () async {
      final challenge = await fake.requestOtp(phoneE164: phone);
      final result = await fake.verifyOtp(
        challengeId: challenge.id,
        code: fake.debugOtpCode!,
      );
      final rotated = await fake.refreshToken(
        refreshToken: result.session.refreshToken,
      );
      expect(rotated.refreshToken, isNot(result.session.refreshToken));
      await expectLater(
        fake.refreshToken(refreshToken: result.session.refreshToken),
        _fails('SESSION_REVOKED'),
      );
      await expectLater(
        fake.currentUser(accessToken: result.session.accessToken),
        _fails('SESSION_REVOKED'),
      );
      expect(
        (await fake.currentUser(accessToken: rotated.accessToken)).id,
        result.user.id,
      );
      now = now.add(const Duration(minutes: 16));
      await fake.logout(refreshToken: rotated.refreshToken);
      await fake.logout(refreshToken: rotated.refreshToken);
      await expectLater(
        fake.refreshToken(refreshToken: rotated.refreshToken),
        _fails('SESSION_REVOKED'),
      );
    },
  );

  test('token expiry is enforced using the configured server TTLs', () async {
    final challenge = await fake.requestOtp(phoneE164: phone);
    final result = await fake.verifyOtp(
      challengeId: challenge.id,
      code: fake.debugOtpCode!,
    );
    now = now.add(const Duration(minutes: 16));
    await expectLater(
      fake.currentUser(accessToken: result.session.accessToken),
      _fails('SESSION_INVALID'),
    );
    now = now.add(const Duration(days: 31));
    await expectLater(
      fake.refreshToken(refreshToken: result.session.refreshToken),
      _fails('SESSION_INVALID'),
    );
  });

  test(
    'delivery failures and unconfigured authentication fail explicitly',
    () async {
      final unavailable = FakeAuthRepository(
        latency: Duration.zero,
        deliveryAvailable: false,
      );
      await expectLater(
        unavailable.requestOtp(phoneE164: phone),
        _fails('OTP_DELIVERY_UNAVAILABLE'),
      );
      await expectLater(
        const UnconfiguredAuthRepository().requestOtp(phoneE164: phone),
        _fails('SERVICE_UNAVAILABLE'),
      );
    },
  );
}

Matcher _fails(String code) =>
    throwsA(isA<AuthFailure>().having((e) => e.code, 'code', code));
