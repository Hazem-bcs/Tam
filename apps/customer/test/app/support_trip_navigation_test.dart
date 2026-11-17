import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/app/router/support_routes.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/support/data/mock/mock_support_repository.dart';
import 'package:tam_customer/features/support/domain/support_repository.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

import '../features/support/support_test_support.dart';

void main() {
  testWidgets('support trip selection switches to the existing trips tab', (
    tester,
  ) async {
    final store = supportStore();
    final repo = MockSupportRepository(store, now: () => supportNow);
    addTearDown(repo.dispose);
    addTearDown(store.dispose);
    final router = GoRouter(
      initialLocation: AppRoutes.settings,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => Scaffold(body: shell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.home,
                  pageBuilder: (context, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: const Text('Home tab'),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.trips,
                  pageBuilder: (context, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: const Text('Trips tab'),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.settings,
                  pageBuilder: (context, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: const Text('Account tab'),
                  ),
                ),
              ],
            ),
          ],
        ),
        ...buildSupportRoutes(
          repo,
          policy: const SupportPolicy(),
          now: () => supportNow,
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Account tab'), findsOneWidget);

    unawaited(router.push<void>(AppRoutes.support));
    await tester.pumpAndSettle();
    expect(find.text('اختيار رحلة للإبلاغ عنها'), findsOneWidget);

    await tester.tap(find.text('اختيار رحلة للإبلاغ عنها'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, AppRoutes.trips);
    expect(find.text('Trips tab'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
