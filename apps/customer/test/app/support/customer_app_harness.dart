import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tam_customer/app/app.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/features/auth/data/memory_auth_session_store.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tam_customer/features/home/presentation/pages/home_page.dart';

import '../../support/fake_auth_repository.dart';

Future<void> launchCustomerApp(WidgetTester tester) async {
  await tester.pumpWidget(
    TamApp(
      authRepository: FakeAuthRepository(latency: Duration.zero),
      sessionStore: MemoryAuthSessionStore(),
      temporaryPhoneEntryEnabled: true,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> enterCustomerSession(
  WidgetTester tester, {
  String? phone = '0941234567',
}) async {
  if (phone == null) {
    await tester.tap(find.text('المتابعة كضيف'));
  } else {
    await tester.enterText(find.byKey(const Key('auth-phone')), phone);
    await tester.tap(find.text('متابعة'));
  }
  await tester.pumpAndSettle();
}

GoRouter customerRouter(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(HomePage)));

AuthCubit customerAuth(WidgetTester tester) =>
    tester.element(find.byType(HomePage)).read<AuthCubit>();

Future<void> showCustomerHome(WidgetTester tester, GoRouter router) async {
  router.go(AppRoutes.home);
  await tester.pumpAndSettle();
}

Future<void> dismissCustomerMessages(WidgetTester tester) async {
  for (var i = 0; i < 3 && find.byType(SnackBar).evaluate().isNotEmpty; i++) {
    await tester.fling(find.byType(SnackBar), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();
  }
}
