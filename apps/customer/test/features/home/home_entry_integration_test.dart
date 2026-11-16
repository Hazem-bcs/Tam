import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tam_customer/app/app.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/auth/data/memory_auth_session_store.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tam_customer/features/auth/presentation/pages/phone_auth_page.dart';
import 'package:tam_customer/features/home/presentation/pages/home_page.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  testWidgets(
    'real Home entry opens registered routes and retains local Auth',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final store = MemoryAuthSessionStore();
      await tester.pumpWidget(
        TamApp(
          authRepository: FakeAuthRepository(latency: Duration.zero),
          sessionStore: store,
          temporaryPhoneEntryEnabled: true,
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('auth-phone')), '0941234567');
      await tester.tap(find.text('متابعة'));
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel('الإشعارات، غير المقروء: 4'),
        findsOneWidget,
        reason: 'The badge count must not replace the notification action name',
      );
      semantics.dispose();
      final home = tester.element(find.byType(HomePage));
      final homeScaffold = find.descendant(
        of: find.byType(HomePage),
        matching: find.byType(Scaffold),
      );
      expect(
        Theme.of(tester.element(homeScaffold.first)).colorScheme.primary,
        isNot(AppTheme.light.colorScheme.primary),
      );
      final auth = home.read<AuthCubit>();
      final router = GoRouter.of(home);
      expect(auth.state.status, AuthStatus.localAccess);
      expect(auth.state.user, isNull);
      expect(await store.read(), isNull);

      final destinations = [
        (find.byKey(const Key('home-notifications')), AppRoutes.notifications),
        (find.byKey(const Key('home-ride-entry')), AppRoutes.rideRequest),
        (find.text('طلباتي'), AppRoutes.trips),
        (find.text('الإعدادات'), AppRoutes.settings),
      ];
      for (final (target, path) in destinations) {
        await tester.ensureVisible(target);
        await tester.tap(target);
        await tester.pumpAndSettle();
        expect(
          router.routerDelegate.currentConfiguration.last.matchedLocation,
          path,
        );
        expect(
          Theme.of(
            tester.element(find.byType(Scaffold).last),
          ).colorScheme.primary,
          path == AppRoutes.rideRequest
              ? AppTheme.rideJourney(AppTheme.light).colorScheme.primary
              : AppTheme.light.colorScheme.primary,
          reason: 'Each route installs only its own central theme',
        );
        expect(tester.takeException(), isNull);
        router.pop();
        await tester.pumpAndSettle();
        expect(router.routeInformationProvider.value.uri.path, AppRoutes.home);
        expect(find.byType(HomePage), findsOneWidget);
        expect(auth.state.status, AuthStatus.localAccess);
      }
      await tester.ensureVisible(find.text('تسجيل الخروج'));
      await tester.tap(find.text('تسجيل الخروج'));
      await tester.pumpAndSettle();
      expect(find.byType(PhoneAuthPage), findsOneWidget);
      expect(auth.state.status, AuthStatus.signedOut);
      expect(await store.read(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
