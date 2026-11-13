import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/app.dart';
import 'package:tam_customer/features/auth/data/memory_auth_session_store.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_artwork.dart';

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
    expect(find.byKey(const Key('auth-form-surface')), findsOneWidget);
    expect(find.text('تم'), findsWidgets);
    expect(find.text('مشوار'), findsNothing);

    final illustration = tester.getSize(find.byType(AuthHeaderArtwork));
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
    final illustration = tester.getSize(find.byType(AuthHeaderArtwork));
    expect(illustration.width, greaterThan(170));
    expect(tester.takeException(), isNull);
  });
}
