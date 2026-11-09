import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/app.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/features/auth/data/memory_auth_session_store.dart';
import 'package:tam_customer/features/completion/presentation/bloc/completion_cubit.dart';
import 'package:tam_customer/features/completion/presentation/pages/completion_page.dart';
import 'package:tam_customer/features/home/presentation/pages/home_page.dart';
import 'package:tam_customer/features/support/presentation/bloc/legal_cubit.dart';
import 'package:tam_customer/features/support/presentation/bloc/support_list_cubit.dart';
import 'package:tam_customer/features/support/presentation/pages/legal_page.dart';
import 'package:tam_customer/features/support/presentation/pages/support_page.dart';

import '../support/fake_auth_repository.dart';
import 'support/customer_app_harness.dart';

const _apiModes = FeatureDataModes(
  overrides: {
    CustomerFeature.completion: FeatureDataMode.api,
    CustomerFeature.support: FeatureDataMode.api,
  },
);

void main() {
  for (final guest in [true, false]) {
    testWidgets(
      'protected after-trip APIs block ${guest ? 'guest' : 'localAccess'} while legal stays public',
      (tester) async {
        await tester.pumpWidget(
          TamApp(
            authRepository: FakeAuthRepository(latency: Duration.zero),
            sessionStore: MemoryAuthSessionStore(),
            temporaryPhoneEntryEnabled: true,
            dataModes: _apiModes,
          ),
        );
        await tester.pumpAndSettle();
        await enterCustomerSession(tester, phone: guest ? null : '0941234567');
        final router = customerRouter(tester), auth = customerAuth(tester);
        final status = auth.state.status;
        for (final path in [
          AppRoutes.completionLocation('mock-history-001'),
          AppRoutes.support,
          AppRoutes.supportNewLocation(tripId: 'mock-history-001'),
          AppRoutes.supportTicketLocation('mock-support-1'),
        ]) {
          router.go(path);
          await tester.pumpAndSettle();
          expect(
            router.routeInformationProvider.value.uri.path,
            AppRoutes.home,
          );
          expect(find.byType(HomePage), findsOneWidget);
          expect(auth.state.status, status);
          expect(auth.state.user, isNull);
        }
        for (final path in [AppRoutes.terms, AppRoutes.privacy]) {
          router.go(path);
          await tester.pumpAndSettle();
          expect(router.routeInformationProvider.value.uri.path, path);
          expect(find.byType(LegalPage), findsOneWidget);
          final legal = tester
              .element(find.byType(LegalPage))
              .read<LegalCubit>();
          expect(legal.state.document, isNull);
          expect(legal.state.failure!.code, 'SERVICE_UNAVAILABLE');
          expect(auth.state.status, status);
        }
        await tester.pumpWidget(const SizedBox.shrink());
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'authenticated API repositories fail explicitly without mock success',
    (tester) async {
      final repository = FakeAuthRepository(latency: Duration.zero);
      final challenge = await repository.requestOtp(phoneE164: '+963941234567');
      final verified = await repository.verifyOtp(
        challengeId: challenge.id,
        code: repository.debugOtpCode!,
      );
      final store = MemoryAuthSessionStore();
      await store.write(verified.session);
      await tester.pumpWidget(
        TamApp(
          authRepository: repository,
          sessionStore: store,
          dataModes: _apiModes,
        ),
      );
      await tester.pumpAndSettle();
      final router = customerRouter(tester);
      router.go(AppRoutes.completionLocation('mock-history-001'));
      await tester.pumpAndSettle();
      final completion = tester
          .element(find.byType(CompletionPage))
          .read<CompletionCubit>()
          .state;
      expect(completion.completion, isNull);
      expect(completion.failure, 'SERVICE_UNAVAILABLE');
      expect(completion.canEdit, isFalse);
      router.go(AppRoutes.support);
      await tester.pumpAndSettle();
      final support = tester
          .element(find.byType(SupportPage))
          .read<SupportListCubit>()
          .state;
      expect(support.tickets, isEmpty);
      expect(support.failure!.code, 'SERVICE_UNAVAILABLE');
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    },
  );
}
