import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/features/completion/presentation/bloc/completion_cubit.dart';
import 'package:tam_customer/features/completion/presentation/pages/completion_page.dart';
import 'package:tam_customer/features/support/presentation/bloc/legal_cubit.dart';
import 'package:tam_customer/features/support/presentation/bloc/support_detail_cubit.dart';
import 'package:tam_customer/features/support/presentation/bloc/support_list_cubit.dart';
import 'package:tam_customer/features/support/presentation/pages/legal_page.dart';
import 'package:tam_customer/features/support/presentation/pages/support_page.dart';
import 'package:tam_customer/features/support/presentation/pages/support_ticket_page.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

import 'support/customer_app_harness.dart';

void main() {
  testWidgets('Settings opens general help and unpublished legal pages', (
    tester,
  ) async {
    await launchCustomerApp(tester);
    await enterCustomerSession(tester);
    final router = customerRouter(tester);
    router.push(AppRoutes.settings);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-support')),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('settings-support')));
    await tester.pumpAndSettle();
    expect(find.byType(SupportPage), findsOneWidget);
    await tester.tap(find.byKey(const Key('support-new-ticket')));
    await tester.pumpAndSettle();
    const body = 'أحتاج إلى مساعدة عامة في استخدام التطبيق';
    await tester.enterText(find.byKey(const Key('support-body')), body);
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('support-submit')));
    await tester.tap(find.byKey(const Key('support-submit')));
    await tester.pumpAndSettle();
    final ticket = tester
        .element(find.byType(SupportTicketDetailsPage))
        .read<SupportDetailCubit>()
        .state
        .ticket!;
    expect(ticket.tripId, isNull);
    expect(ticket.body, body);
    await showCustomerHome(tester, router);
    router.push(AppRoutes.support);
    await tester.pumpAndSettle();
    expect(
      tester
          .element(find.byType(SupportPage))
          .read<SupportListCubit>()
          .state
          .tickets
          .map((t) => t.id),
      contains(ticket.id),
    );
    await showCustomerHome(tester, router);
    router.push(AppRoutes.settings);
    await tester.pumpAndSettle();
    for (final key in ['settings-terms', 'settings-privacy']) {
      await tester.scrollUntilVisible(
        find.byKey(Key(key)),
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.byKey(Key(key)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle();
      final state = tester
          .element(find.byType(LegalPage))
          .read<LegalCubit>()
          .state;
      expect(state.document, isNull);
      expect(state.failure, isNull);
      final l = AppLocalizations.of(tester.element(find.byType(LegalPage)));
      expect(find.text(l.supportLegalUnpublished), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
    }
    await showCustomerHome(tester, router);
    await customerAuth(tester).logout();
    await tester.pumpAndSettle();
    await enterCustomerSession(tester, phone: null);
    router.go(AppRoutes.support);
    await tester.pumpAndSettle();
    expect(
      tester
          .element(find.byType(SupportPage))
          .read<SupportListCubit>()
          .state
          .tickets,
      isEmpty,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'legacy completed trip ratings are cleared when the session ends',
    (tester) async {
      await launchCustomerApp(tester);
      await enterCustomerSession(tester);
      final router = customerRouter(tester);
      router.push(AppRoutes.completionLocation('mock-history-001'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('completion-stars-4')));
      await tester.tap(find.byKey(const Key('completion-stars-4')));
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('completion-submit')));
      await tester.tap(find.byKey(const Key('completion-submit')));
      await tester.pumpAndSettle();
      expect(
        tester
            .element(find.byType(CompletionPage))
            .read<CompletionCubit>()
            .state
            .completion!
            .rating!
            .stars,
        4,
      );
      await showCustomerHome(tester, router);
      await customerAuth(tester).logout();
      await tester.pumpAndSettle();
      await enterCustomerSession(tester, phone: null);
      router.go(AppRoutes.completionLocation('mock-history-001'));
      await tester.pumpAndSettle();
      final state = tester
          .element(find.byType(CompletionPage))
          .read<CompletionCubit>()
          .state;
      expect(state.completion!.rating, isNull);
      expect(state.canEdit, isTrue);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    },
  );
}
