import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/app/router/route_access_policy.dart';
import 'package:tam_customer/app/router/support_routes.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_legal_footer.dart';
import 'package:tam_customer/features/support/data/mock/mock_support_repository.dart';
import 'package:tam_customer/features/support/domain/support_repository.dart';
import 'package:tam_customer/features/support/presentation/pages/legal_page.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';

void main() {
  for (final language in ['ar', 'en']) {
    testWidgets(
      'Auth links reach distinct public legal pages and return in $language',
      (tester) async {
        final store = MockTripStore();
        final repository = MockSupportRepository(store);
        final router = GoRouter(
          initialLocation: AppRoutes.auth,
          routes: [
            GoRoute(
              path: AppRoutes.auth,
              builder: (_, _) => const Scaffold(body: AuthLegalFooter()),
            ),
            ...buildSupportRoutes(
              repository,
              policy: const SupportPolicy(),
              now: DateTime.now,
            ),
          ],
        );
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.light,
            locale: Locale(language),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          ),
        );
        await tester.pumpAndSettle();
        final t = AppLocalizations.of(
          tester.element(find.byType(AuthLegalFooter)),
        );
        for (final entry in {
          AppRoutes.terms: t.settingsTerms,
          AppRoutes.privacy: t.settingsPrivacy,
        }.entries) {
          expect(RouteAccessPolicy.appRoutes[entry.key], RouteAccess.public);
          await tester.tap(find.text(entry.value));
          await tester.pumpAndSettle();
          expect(
            GoRouterState.of(tester.element(find.byType(LegalPage))).uri.path,
            entry.key,
          );
          expect(find.text(t.supportLegalUnpublished), findsOneWidget);
          await tester.tap(find.byType(BackButton));
          await tester.pumpAndSettle();
          expect(find.byType(AuthLegalFooter), findsOneWidget);
          expect(
            router.routeInformationProvider.value.uri.path,
            AppRoutes.auth,
          );
          expect(tester.takeException(), isNull);
        }
        await tester.pumpWidget(const SizedBox());
        router.dispose();
        await repository.dispose();
        await store.dispose();
      },
    );
  }
}
