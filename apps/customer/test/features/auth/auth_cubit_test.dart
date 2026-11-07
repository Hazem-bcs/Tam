import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/auth/data/memory_auth_session_store.dart';
import 'package:tam_customer/features/auth/domain/auth_models.dart';
import 'package:tam_customer/features/auth/domain/auth_repository.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  late DateTime now;
  late FakeAuthRepository fake;
  late _RecordingRepository repository;
  late MemoryAuthSessionStore store;
  late AuthCubit auth;
  setUp(() {
    now = DateTime.utc(2026, 11, 4, 12);
    fake = FakeAuthRepository(clock: () => now, latency: Duration.zero);
    repository = _RecordingRepository(fake);
    store = MemoryAuthSessionStore();
    auth = AuthCubit(repository, store, clock: () => now);
  });
  tearDown(() => auth.close());

  Future<void> login() async {
    await auth.restoreSession();
    await auth.requestOtp('٠٩١٢٣٤٥٦٧٨');
    await auth.verifyOtp(fake.debugOtpCode!);
  }

  test('guest mode creates no backend user, token or session', () async {
    await auth.restoreSession();
    await auth.continueAsGuest();
    expect(auth.state.status, AuthStatus.guest);
    expect(auth.state.user, isNull);
    expect(await store.read(), isNull);
    expect(repository.requests, 0);
    expect(repository.verifications, 0);
  });

  test(
    'a double submit sends one challenge and credentials never enter state',
    () async {
      await auth.restoreSession();
      await Future.wait([
        auth.requestOtp('0912345678'),
        auth.requestOtp('0912345678'),
      ]);
      expect(repository.requests, 1);
      await auth.verifyOtp(fake.debugOtpCode!);
      final session = (await store.read())!;
      expect(auth.state.status, AuthStatus.authenticated);
      expect(auth.state.toString(), isNot(contains(session.accessToken)));
      expect(auth.state.props, isNot(contains(session)));
    },
  );

  test(
    'incorrect OTP updates attempts without discarding the challenge',
    () async {
      await auth.restoreSession();
      await auth.requestOtp('0912345678');
      final id = auth.state.challenge!.id;
      await auth.verifyOtp('000000');
      expect(auth.state.status, AuthStatus.awaitingOtp);
      expect(auth.state.challenge!.id, id);
      expect(auth.state.challenge!.attemptsRemaining, 4);
      expect(auth.state.failure!.code, 'OTP_INVALID');
      auth.clearFailure();
      expect(auth.state.failure, isNull);
      expect(auth.state.challenge!.attemptsRemaining, 4);
    },
  );

  test(
    'restoration coalesces concurrent refreshes and persists rotated tokens',
    () async {
      await login();
      final old = (await store.read())!;
      now = now.add(const Duration(minutes: 16));
      await Future.wait([auth.restoreSession(), auth.restoreSession()]);
      expect(repository.refreshes, 1);
      expect(auth.state.status, AuthStatus.authenticated);
      expect((await store.read())!.refreshToken, isNot(old.refreshToken));
    },
  );

  test('startup network failures retain credentials and allow retry', () async {
    await login();
    final saved = await store.read();
    final restored = AuthCubit(repository, store, clock: () => now);
    addTearDown(restored.close);
    repository.offline = true;
    await restored.restoreSession();
    expect(restored.state.status, AuthStatus.sessionUnavailable);
    expect(await store.read(), same(saved));
    repository.offline = false;
    await restored.restoreSession();
    expect(restored.state.status, AuthStatus.authenticated);
  });

  test(
    'transient refresh failures do not sign out an authenticated user',
    () async {
      await login();
      final saved = await store.read();
      now = now.add(const Duration(minutes: 16));
      repository.offline = true;
      await auth.restoreSession();
      expect(auth.state.status, AuthStatus.authenticated);
      expect(auth.state.failure!.code, 'NETWORK_UNAVAILABLE');
      expect(await store.read(), same(saved));
    },
  );

  test('revoked and refresh-expired sessions are cleared', () async {
    await login();
    await fake.logout(refreshToken: (await store.read())!.refreshToken);
    await auth.restoreSession();
    expect(auth.state.status, AuthStatus.signedOut);
    expect(await store.read(), isNull);
    expect(auth.state.failure!.code, 'SESSION_REVOKED');
  });

  test(
    'a rotated session can be restored by a new controller in the same process',
    () async {
      await login();
      now = now.add(const Duration(minutes: 16));
      final restored = AuthCubit(repository, store, clock: () => now);
      addTearDown(restored.close);
      await restored.restoreSession();
      expect(restored.state.status, AuthStatus.authenticated);
      expect(restored.state.user!.phoneE164, '+963912345678');
      now = now.add(const Duration(days: 31));
      await restored.restoreSession();
      expect(restored.state.status, AuthStatus.signedOut);
      expect(await store.read(), isNull);
    },
  );

  test('explicit offline sign-out clears local credentials', () async {
    await login();
    repository.offline = true;
    await auth.logout();
    expect(auth.state.status, AuthStatus.signedOut);
    expect(await store.read(), isNull);
    expect(auth.state.failure!.code, 'LOGOUT_REMOTE_UNCONFIRMED');
  });
}

final class _RecordingRepository implements AuthRepository {
  _RecordingRepository(this.inner);
  final AuthRepository inner;
  bool offline = false;
  int requests = 0;
  int verifications = 0;
  int refreshes = 0;

  void _online() {
    if (offline) {
      throw const AuthFailure(
        code: 'NETWORK_UNAVAILABLE',
        message: BilingualMessage(ar: 'تعذر الاتصال', en: 'Unable to connect'),
      );
    }
  }

  @override
  Future<OtpChallenge> requestOtp({required String phoneE164}) {
    requests++;
    _online();
    return inner.requestOtp(phoneE164: phoneE164);
  }

  @override
  Future<OtpChallenge> resendOtp({required String challengeId}) =>
      inner.resendOtp(challengeId: challengeId);

  @override
  Future<AuthResult> verifyOtp({
    required String challengeId,
    required String code,
  }) {
    verifications++;
    _online();
    return inner.verifyOtp(challengeId: challengeId, code: code);
  }

  @override
  Future<AuthSession> refreshToken({required String refreshToken}) {
    refreshes++;
    _online();
    return inner.refreshToken(refreshToken: refreshToken);
  }

  @override
  Future<AuthUser> currentUser({required String accessToken}) {
    _online();
    return inner.currentUser(accessToken: accessToken);
  }

  @override
  Future<void> logout({required String refreshToken}) {
    _online();
    return inner.logout(refreshToken: refreshToken);
  }
}
