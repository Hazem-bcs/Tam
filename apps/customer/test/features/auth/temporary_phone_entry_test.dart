import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:tam_customer/app/app.dart';
import 'package:tam_customer/core/config/app_config.dart';
import 'package:tam_customer/features/auth/auth_dependencies.dart';
import 'package:tam_customer/features/auth/data/memory_auth_session_store.dart';
import 'package:tam_customer/features/auth/data/unconfigured_auth_repository.dart';
import 'package:tam_customer/features/auth/domain/auth_models.dart';
import 'package:tam_customer/features/auth/domain/auth_repository.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tam_customer/features/auth/presentation/pages/phone_auth_page.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_otp_input.dart';

void main() {
  test(
    'app composition has no simulated users, OTP service or tokens',
    () async {
      final services = GetIt.asNewInstance();
      registerAuthDependencies(services);
      expect(services<AuthRepository>(), isA<UnconfiguredAuthRepository>());
      expect(
        services<AuthPresentationConfig>().temporaryPhoneEntryEnabled,
        AppConfig.temporaryPhoneEntryEnabled,
      );
      expect(await services<AuthSessionStore>().read(), isNull);
      await services.reset();
    },
  );

  test(
    'local entry accepts different phones without an account or session',
    () async {
      final repository = _NoNetworkRepository();
      final store = MemoryAuthSessionStore();
      final auth = AuthCubit(
        repository,
        store,
        temporaryPhoneEntryEnabled: true,
      );
      addTearDown(auth.close);
      await auth.restoreSession();
      for (final phone in ['0941234567', '963982345678', '٠٩٣١٢٣٤٥٦٧']) {
        await auth.requestOtp(phone);
        expect(auth.state.status, AuthStatus.localAccess);
        expect(auth.state.localPhoneE164, startsWith('+9639'));
        expect(auth.state.user, isNull);
        expect(auth.state.challenge, isNull);
        expect(await store.read(), isNull);
        await auth.restoreSession();
        expect(auth.state.status, AuthStatus.localAccess);
        await auth.logout();
        expect(auth.state.status, AuthStatus.signedOut);
        expect(auth.state.localPhoneE164, isNull);
        expect(auth.state.failure, isNull);
      }
      expect(repository.calls, 0);
    },
  );

  test(
    'invalid phone is rejected and guest access stays independent',
    () async {
      final repository = _NoNetworkRepository();
      final auth = AuthCubit(
        repository,
        MemoryAuthSessionStore(),
        temporaryPhoneEntryEnabled: true,
      );
      addTearDown(auth.close);
      await auth.restoreSession();
      await auth.requestOtp('1234');
      expect(auth.state.status, AuthStatus.signedOut);
      expect(auth.state.failure?.code, 'PHONE_INVALID');
      await auth.continueAsGuest();
      expect(auth.state.status, AuthStatus.guest);
      expect(auth.state.localPhoneE164, isNull);
      await auth.logout();
      expect(repository.calls, 0);
    },
  );

  test(
    'disabling temporary entry preserves the real service boundary',
    () async {
      final auth = AuthCubit(
        const UnconfiguredAuthRepository(),
        MemoryAuthSessionStore(),
      );
      addTearDown(auth.close);
      await auth.restoreSession();
      await auth.requestOtp('0941234567');
      expect(auth.state.status, AuthStatus.signedOut);
      expect(auth.state.failure?.code, 'SERVICE_UNAVAILABLE');
      expect(auth.state.localPhoneE164, isNull);
      expect(auth.state.user, isNull);
    },
  );

  for (final ar in [true, false]) {
    testWidgets('direct entry and clean home / ${ar ? 'ar' : 'en'}', (
      tester,
    ) async {
      final repository = _NoNetworkRepository();
      final store = MemoryAuthSessionStore();
      await tester.pumpWidget(
        TamApp(
          authRepository: repository,
          sessionStore: store,
          temporaryPhoneEntryEnabled: true,
          locale: Locale(ar ? 'ar' : 'en'),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(ar ? 'إرسال رمز التحقق' : 'Send verification code'),
        findsNothing,
      );
      await tester.enterText(
        find.byKey(const Key('auth-phone')),
        '963941234567',
      );
      await tester.tap(find.text(ar ? 'متابعة' : 'Continue'));
      await tester.pumpAndSettle();
      expect(find.byType(AuthOtpInput), findsNothing);
      expect(find.text('+963941234567'), findsOneWidget);
      expect(find.text(ar ? 'رقم هاتفك' : 'Your phone number'), findsOneWidget);
      expect(
        find.text(
          ar
              ? 'خدمة الرحلات غير متاحة حاليًا'
              : 'Rides are currently unavailable',
        ),
        findsOneWidget,
      );
      expect(
        find.text(ar ? 'تم تسجيل الدخول' : 'You are signed in'),
        findsNothing,
      );
      expect(await store.read(), isNull);
      final renderedText = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .join(' ');
      expect(
        renderedText,
        isNot(
          matches(
            RegExp(r'تجريبي|اختبار|وهمي|prototype|demo', caseSensitive: false),
          ),
        ),
      );
      await tester.tap(find.text(ar ? 'تسجيل الخروج' : 'Sign out'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('auth-phone')), findsOneWidget);
      // A direct/deep link must not re-enable the skipped OTP screen.
      GoRouter.of(tester.element(find.byType(PhoneAuthPage))).go('/auth/otp');
      await tester.pumpAndSettle();
      expect(find.byType(AuthOtpInput), findsNothing);
      expect(find.byType(PhoneAuthPage), findsOneWidget);
      expect(repository.calls, 0);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('local entry fits 320px, large text and keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    tester.platformDispatcher.textScaleFactorTestValue = 2.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      TamApp(
        authRepository: _NoNetworkRepository(),
        sessionStore: MemoryAuthSessionStore(),
        temporaryPhoneEntryEnabled: true,
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('auth-phone')), '0941234567');
    await tester.ensureVisible(find.text('متابعة'));
    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('تسجيل الخروج'));
    await tester.tap(find.text('تسجيل الخروج'));
    await tester.pumpAndSettle();
    expect(find.byType(PhoneAuthPage), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _NoNetworkRepository implements AuthRepository {
  int calls = 0;
  Future<Never> _unexpected() async {
    calls++;
    throw StateError('Temporary entry must not call Auth API operations');
  }

  @override
  Future<OtpChallenge> requestOtp({required String phoneE164}) => _unexpected();
  @override
  Future<OtpChallenge> resendOtp({required String challengeId}) =>
      _unexpected();
  @override
  Future<AuthResult> verifyOtp({
    required String challengeId,
    required String code,
  }) => _unexpected();
  @override
  Future<AuthSession> refreshToken({required String refreshToken}) =>
      _unexpected();
  @override
  Future<AuthUser> currentUser({required String accessToken}) => _unexpected();
  @override
  Future<void> logout({required String refreshToken}) => _unexpected();
}
