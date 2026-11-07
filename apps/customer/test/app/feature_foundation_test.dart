import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tam_customer/app/app.dart';
import 'package:tam_customer/app/locale/app_locale_controller.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/app/router/route_access_policy.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/features/auth/data/memory_auth_session_store.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tam_customer/features/home/presentation/pages/home_page.dart';

import '../support/fake_auth_repository.dart';

void main() {
  test(
    'per-feature mode inherits and validates configuration without fallback',
    () {
      final modes = FeatureDataModes.parse(
        defaultValue: 'mock',
        overrides: {CustomerFeature.trips: 'api', CustomerFeature.home: ''},
      );
      expect(modes.forFeature(CustomerFeature.trips), FeatureDataMode.api);
      expect(modes.forFeature(CustomerFeature.home), FeatureDataMode.mock);
      expect(
        () => FeatureDataModes.parse(defaultValue: 'typo'),
        throwsArgumentError,
      );
      expect(
        () => FeatureDataModes.parse(
          defaultValue: 'api',
          overrides: {CustomerFeature.trips: 'MOCK'},
        ),
        throwsArgumentError,
      );
    },
  );

  test('mock pages never promote local/guest entry into API authorization', () {
    final modes = FeatureDataModes.parse(
      defaultValue: 'api',
      overrides: {CustomerFeature.notifications: 'mock'},
    );
    final policy = RouteAccessPolicy.forFeatures(modes);
    for (final status in [AuthStatus.guest, AuthStatus.localAccess]) {
      final auth = AuthState(status: status);
      expect(policy.redirect(auth, Uri.parse(AppRoutes.notifications)), isNull);
      for (final path in [
        AppRoutes.rideRequest,
        AppRoutes.trips,
        AppRoutes.settings,
      ]) {
        expect(policy.redirect(auth, Uri.parse(path)), AppRoutes.home);
      }
      expect(
        policy.redirect(
          auth,
          Uri.parse('/trips/mock-history-001'),
          matchedPath: AppRoutes.tripDetails,
        ),
        AppRoutes.home,
      );
    }
  });

  test('locale accepts only the supported scripts', () {
    final locale = AppLocaleController();
    locale.setLocale(const Locale('en'));
    expect(locale.value, const Locale('en'));
    expect(() => locale.setLocale(const Locale('fr')), throwsArgumentError);
    expect(locale.value, const Locale('en'));
    locale.dispose();
  });

  for (final mode in FeatureDataMode.values) {
    testWidgets('actual routing respects $mode during local phone entry', (
      tester,
    ) async {
      await tester.pumpWidget(
        TamApp(
          authRepository: FakeAuthRepository(latency: Duration.zero),
          sessionStore: MemoryAuthSessionStore(),
          temporaryPhoneEntryEnabled: true,
          dataModes: FeatureDataModes(defaultMode: mode),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('auth-phone')), '0941234567');
      await tester.tap(find.text('متابعة'));
      await tester.pumpAndSettle();
      final router = GoRouter.of(tester.element(find.byType(HomePage)));
      router.go(AppRoutes.trips);
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        mode == FeatureDataMode.mock ? AppRoutes.trips : AppRoutes.home,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('changing app locale preserves the route and local phone state', (
    tester,
  ) async {
    final repository = FakeAuthRepository(latency: Duration.zero);
    final store = MemoryAuthSessionStore();
    TamApp app(Locale locale) => TamApp(
      authRepository: repository,
      sessionStore: store,
      temporaryPhoneEntryEnabled: true,
      locale: locale,
    );
    await tester.pumpWidget(app(const Locale('ar')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('auth-phone')), '0941234567');
    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();
    final router = GoRouter.of(tester.element(find.byType(HomePage)));
    await tester.pumpWidget(app(const Locale('en')));
    await tester.pumpAndSettle();
    expect(GoRouter.of(tester.element(find.byType(HomePage))), same(router));
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
      const Locale('en'),
    );
    expect(
      tester
          .element(find.byType(HomePage))
          .read<AuthCubit>()
          .state
          .localPhoneE164,
      '+963941234567',
    );
    expect(find.text('+963941234567'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
