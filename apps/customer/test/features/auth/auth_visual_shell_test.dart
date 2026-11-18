import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/app.dart';
import 'package:tam_customer/features/auth/data/memory_auth_session_store.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:tam_customer/shared/widgets/tam_brand_logo.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  testWidgets('brand scene gives the route artwork real horizontal space', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      TamApp(
        authRepository: FakeAuthRepository(latency: Duration.zero),
        sessionStore: MemoryAuthSessionStore(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('auth-brand-scene')), findsOneWidget);
    expect(find.byKey(const Key('auth-reference-artwork')), findsOneWidget);
    expect(find.byKey(const Key('auth-form-surface')), findsOneWidget);
    expect(find.byType(TamBrandLogo), findsOneWidget);
    expect(find.bySemanticsLabel('تم'), findsOneWidget);
    expect(find.text('مشوار'), findsNothing);

    final illustration = tester.getSize(
      find.byKey(const Key('auth-reference-artwork')),
    );
    expect(illustration.width, greaterThan(200));
    expect(illustration.height, greaterThan(40));
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact auth keeps fields present with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      TamApp(
        authRepository: FakeAuthRepository(latency: Duration.zero),
        sessionStore: MemoryAuthSessionStore(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('auth-phone')), findsOneWidget);
    final illustration = tester.getSize(
      find.byKey(const Key('auth-reference-artwork')),
    );
    expect(illustration.width, greaterThan(170));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'keyboard keeps reference artwork the same size while fields stay scrollable',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);

      await tester.pumpWidget(
        TamApp(
          authRepository: FakeAuthRepository(latency: Duration.zero),
          sessionStore: MemoryAuthSessionStore(),
        ),
      );
      await tester.pumpAndSettle();

      const hero = Key('auth-brand-scene');
      const mascot = Key('auth-reference-artwork');
      final heroBefore = tester.getSize(find.byKey(hero));
      final mascotBefore = tester.getSize(find.byKey(mascot));
      expect(mascotBefore.width, greaterThan(200));

      await tester.tap(find.byType(TextFormField).first);
      tester.view.viewInsets = const FakeViewPadding(bottom: 320);
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byKey(hero)), heroBefore);
      expect(tester.getSize(find.byKey(mascot)), mascotBefore);
      expect(find.byKey(const Key('auth-phone')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('reference scene receives focus and OTP phase changes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      TamApp(
        authRepository: FakeAuthRepository(latency: Duration.zero),
        sessionStore: MemoryAuthSessionStore(),
      ),
    );
    await tester.pumpAndSettle();
    AuthScaffold mascot() =>
        tester.widget<AuthScaffold>(find.byType(AuthScaffold));
    expect(mascot().inputFocused, isFalse);
    expect(mascot().otpStage, isFalse);

    await tester.tap(find.byType(TextFormField).first);
    await tester.pumpAndSettle();
    expect(mascot().inputFocused, isTrue);
    expect(mascot().gazeProgress, 0);

    await tester.enterText(find.byKey(const Key('auth-phone')), '9123');
    await tester.pumpAndSettle();
    expect(mascot().gazeProgress, closeTo(4 / 9, 0.0001));

    await tester.enterText(find.byKey(const Key('auth-phone')), '912345678');
    await tester.pumpAndSettle();
    expect(mascot().gazeProgress, 1);
    // Touching outside the input must release focus and return to living Idle.
    await tester.tap(find.text('أهلًا بعودتك'));
    await tester.pumpAndSettle();
    expect(mascot().inputFocused, isFalse);

    await tester.ensureVisible(find.text('إرسال رمز التحقق'));
    await tester.tap(find.text('إرسال رمز التحقق'));
    await tester.pumpAndSettle();
    expect(mascot().otpStage, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('local invalid phone drives concern and clears when corrected', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      TamApp(
        authRepository: FakeAuthRepository(latency: Duration.zero),
        sessionStore: MemoryAuthSessionStore(),
      ),
    );
    await tester.pumpAndSettle();
    AuthScaffold mascot() =>
        tester.widget<AuthScaffold>(find.byType(AuthScaffold));
    expect(mascot().hasError, isFalse);

    await tester.ensureVisible(find.text('إرسال رمز التحقق'));
    await tester.tap(find.text('إرسال رمز التحقق'));
    await tester.pumpAndSettle();
    expect(mascot().hasError, isTrue);

    await tester.enterText(find.byKey(const Key('auth-phone')), '912345678');
    await tester.pumpAndSettle();
    expect(mascot().hasError, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'happy phone readiness recovers and yields to waiting and error',
    (tester) async {
      final store = MemoryAuthSessionStore();
      await tester.pumpWidget(
        TamApp(
          authRepository: FakeAuthRepository(
            deliveryAvailable: false,
            latency: const Duration(seconds: 1),
          ),
          sessionStore: store,
        ),
      );
      await tester.pumpAndSettle();
      AuthScaffold mascot() =>
          tester.widget<AuthScaffold>(find.byType(AuthScaffold));
      expect(mascot().success, isFalse);
      await tester.enterText(find.byKey(const Key('auth-phone')), '912345678');
      await tester.pump();
      expect(mascot().success, isTrue);
      final auth = tester.element(find.byType(AuthScaffold)).read<AuthCubit>();
      expect(auth.state.status, AuthStatus.signedOut);
      expect(auth.state.user, isNull);
      expect(await store.read(), isNull);

      await tester.enterText(find.byKey(const Key('auth-phone')), '9123');
      await tester.pump();
      expect(mascot().success, isFalse);
      expect(mascot().hasError, isFalse);
      await tester.enterText(find.byKey(const Key('auth-phone')), '912345678');
      await tester.pump();
      await tester.ensureVisible(find.text('إرسال رمز التحقق'));
      await tester.tap(find.text('إرسال رمز التحقق'));
      await tester.pump();
      expect(mascot().busy, isTrue);
      expect(mascot().success, isFalse);
      await tester.pumpAndSettle();
      expect(mascot().hasError, isTrue);
      expect(mascot().success, isFalse);

      await tester.enterText(find.byKey(const Key('auth-phone')), '912345677');
      await tester.pump();
      expect(mascot().hasError, isFalse);
      expect(mascot().success, isTrue);
      expect(auth.state.status, AuthStatus.signedOut);
      expect(await store.read(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
