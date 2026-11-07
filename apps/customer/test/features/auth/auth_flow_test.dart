import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tam_customer/app/app.dart';
import 'package:tam_customer/features/auth/data/memory_auth_session_store.dart';
import 'package:tam_customer/features/auth/presentation/pages/phone_auth_page.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  for (final arabic in [true, false]) {
    testWidgets(
      '${arabic ? 'Arabic' : 'English'} sign-in, wrong OTP and sign-out',
      (tester) async {
        final fake = FakeAuthRepository(latency: Duration.zero);
        final store = MemoryAuthSessionStore();
        await tester.pumpWidget(
          TamApp(
            authRepository: fake,
            sessionStore: store,
            locale: Locale(arabic ? 'ar' : 'en'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('auth-phone')),
          '٠٩١٢٣٤٥٦٧٨',
        );
        final send = find.text(
          arabic ? 'إرسال رمز التحقق' : 'Send verification code',
        );
        await tester.ensureVisible(send);
        await tester.tap(send);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('auth-code')), findsOneWidget);
        final verify = find.text(arabic ? 'تأكيد الرمز' : 'Verify code');
        await tester.enterText(find.byKey(const Key('auth-code')), '000000');
        await tester.ensureVisible(verify);
        await tester.tap(verify);
        await tester.pumpAndSettle();
        expect(
          find.text(
            arabic ? 'رمز التحقق غير صحيح' : 'Invalid verification code',
          ),
          findsOneWidget,
        );
        await tester.enterText(
          find.byKey(const Key('auth-code')),
          fake.debugOtpCode!,
        );
        await tester.ensureVisible(verify);
        await tester.tap(verify);
        await tester.pumpAndSettle();
        expect(
          find.text(arabic ? 'تم تسجيل الدخول' : 'You are signed in'),
          findsOneWidget,
        );
        expect(await store.read(), isNotNull);
        final logout = find.text(arabic ? 'تسجيل الخروج' : 'Sign out');
        await tester.ensureVisible(logout);
        await tester.tap(logout);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('auth-phone')), findsOneWidget);
        expect(await store.read(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets('invalid phone is rejected before requesting an OTP', (
    tester,
  ) async {
    final fake = FakeAuthRepository(latency: Duration.zero);
    await tester.pumpWidget(
      TamApp(authRepository: fake, sessionStore: MemoryAuthSessionStore()),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('auth-phone')), '+936123');
    await tester.ensureVisible(find.text('إرسال رمز التحقق'));
    await tester.tap(find.text('إرسال رمز التحقق'));
    await tester.pumpAndSettle();
    expect(find.text('أدخل رقم هاتف سوريًا صالحًا'), findsOneWidget);
    expect(fake.debugOtpCode, isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'editing the phone preserves the number and discards OTP navigation',
    (tester) async {
      final fake = FakeAuthRepository(latency: Duration.zero);
      await tester.pumpWidget(
        TamApp(authRepository: fake, sessionStore: MemoryAuthSessionStore()),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('auth-phone')), '0912345678');
      await tester.ensureVisible(find.text('إرسال رمز التحقق'));
      await tester.tap(find.text('إرسال رمز التحقق'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('تعديل رقم الهاتف'));
      await tester.tap(find.text('تعديل رقم الهاتف'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('auth-code')), findsNothing);
      expect(find.text('+963'), findsOneWidget);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        '912345678',
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'direct OTP navigation without a challenge redirects to phone entry',
    (tester) async {
      final fake = FakeAuthRepository(latency: Duration.zero);
      await tester.pumpWidget(
        TamApp(authRepository: fake, sessionStore: MemoryAuthSessionStore()),
      );
      await tester.pumpAndSettle();
      GoRouter.of(tester.element(find.byType(PhoneAuthPage))).go('/auth/otp');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('auth-phone')), findsOneWidget);
      expect(find.byKey(const Key('auth-code')), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'a retained demo session restores without asking for another OTP',
    (tester) async {
      final fake = FakeAuthRepository(latency: Duration.zero);
      final store = MemoryAuthSessionStore();
      final challenge = await fake.requestOtp(phoneE164: '+963912345678');
      final result = await fake.verifyOtp(
        challengeId: challenge.id,
        code: fake.debugOtpCode!,
      );
      await store.write(result.session);
      await tester.pumpWidget(
        TamApp(authRepository: fake, sessionStore: store),
      );
      await tester.pumpAndSettle();
      expect(find.text('تم تسجيل الدخول'), findsOneWidget);
      expect(find.byKey(const Key('auth-phone')), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('320px Arabic auth supports large text and keyboard insets', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2.5;
    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.view.resetViewInsets);
    final fake = FakeAuthRepository(latency: Duration.zero);
    await tester.pumpWidget(
      TamApp(authRepository: fake, sessionStore: MemoryAuthSessionStore()),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.enterText(find.byKey(const Key('auth-phone')), '0912345678');
    await tester.ensureVisible(find.text('إرسال رمز التحقق'));
    await tester.tap(find.text('إرسال رمز التحقق'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('auth-code')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
