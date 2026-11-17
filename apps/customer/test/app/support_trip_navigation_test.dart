import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/app/router/support_routes.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/support/data/mock/mock_support_repository.dart';
import 'package:tam_customer/features/support/domain/support_repository.dart';
import 'package:tam_customer/features/support/presentation/bloc/support_editor_cubit.dart';
import 'package:tam_customer/features/support/presentation/pages/support_editor_page.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

import '../features/support/support_test_support.dart';

void main() {
  testWidgets('legacy support route goes directly to the request editor', (
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
    // Pushed routes can retain the underlying route-information URI.
    expect(find.byType(SupportEditorPage), findsOneWidget);
    expect(find.byKey(const Key('support-body')), findsOneWidget);
    expect(find.text('اختيار رحلة للإبلاغ عنها'), findsNothing);

    // Back returns to the account tab, not the discarded intermediate page.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      AppRoutes.settings,
    );
    expect(find.text('Account tab'), findsOneWidget);

    // Context from a previous deep link is preserved when redirected.
    router.go('${AppRoutes.support}?trip_id=trip-1');
    await tester.pumpAndSettle();
    expect(find.byType(SupportEditorPage), findsOneWidget);
    expect(
      tester
          .element(find.byType(SupportEditorPage))
          .read<SupportEditorCubit>()
          .tripId,
      'trip-1',
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
