import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/features/active_trip/presentation/bloc/active_trip_cubit.dart';
import 'package:tam_customer/features/active_trip/presentation/pages/active_trip_page.dart';
import 'package:tam_customer/features/completion/presentation/bloc/completion_cubit.dart';
import 'package:tam_customer/features/completion/presentation/pages/completion_page.dart';
import 'package:tam_customer/features/support/presentation/bloc/support_detail_cubit.dart';
import 'package:tam_customer/features/support/presentation/bloc/support_editor_cubit.dart';
import 'package:tam_customer/features/support/presentation/pages/support_editor_page.dart';
import 'package:tam_customer/features/support/presentation/pages/support_ticket_page.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';

import 'support/customer_app_harness.dart';

void main() {
  testWidgets(
    'completed booking can be rated and reported using the same trip',
    (tester) async {
      var now = DateTime.now().toUtc();
      await launchCustomerApp(tester, clock: () => now);
      await enterCustomerSession(tester);
      final router = customerRouter(tester);
      router.push(AppRoutes.rideRequest);
      await tester.pumpAndSettle();
      for (final place in [
        ('حدد مكان الانطلاق', 'المزة، شارع الجلاء'),
        ('إلى أين تريد الذهاب؟', 'أبو رمانة، شارع الحمراء'),
      ]) {
        await tester.tap(find.text(place.$1));
        await tester.pumpAndSettle();
        await tester.tap(find.text(place.$2).last);
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('تأكيد طلب الرحلة'));
      await tester.pumpAndSettle();
      final tracker = tester
          .element(find.byType(ActiveTripPage))
          .read<ActiveTripCubit>();
      final id = tracker.state.trip!.id;
      expect(find.byKey(const Key('active-completion')), findsNothing);
      now = now.add(const Duration(seconds: 90));
      await tester.pump(const Duration(seconds: 90));
      await tester.pumpAndSettle();
      expect(tracker.state.trip!.status, TripStatus.completed);
      await tester.scrollUntilVisible(
        find.byKey(const Key('active-completion')),
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('active-completion')));
      await tester.pumpAndSettle();
      final completion = tester
          .element(find.byType(CompletionPage))
          .read<CompletionCubit>();
      expect(completion.state.completion!.trip.id, id);
      await tester.ensureVisible(find.byKey(const Key('completion-stars-5')));
      await tester.tap(find.byKey(const Key('completion-stars-5')));
      const comment = 'تجربة رحلة جيدة ومريحة';
      await tester.enterText(
        find.byKey(const Key('completion-comment')),
        comment,
      );
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('completion-submit')));
      await tester.tap(find.byKey(const Key('completion-submit')));
      await tester.pumpAndSettle();
      expect(completion.state.completion!.rating!.stars, 5);
      expect(completion.state.completion!.rating!.comment, comment);
      expect(completion.state.canEdit, isFalse);
      await showCustomerHome(tester, router);
      router.push(AppRoutes.tripLocation(id));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('trips-completion')));
      await tester.tap(find.byKey(const Key('trips-completion')));
      await tester.pumpAndSettle();
      final restored = tester
          .element(find.byType(CompletionPage))
          .read<CompletionCubit>();
      expect(restored.state.completion!.rating!.comment, comment);
      final l = AppLocalizations.of(
        tester.element(find.byType(CompletionPage)),
      );
      await tester.ensureVisible(find.text(l.completionSupport));
      await tester.tap(find.text(l.completionSupport));
      await tester.pumpAndSettle();
      final editor = tester
          .element(find.byType(SupportEditorPage))
          .read<SupportEditorCubit>();
      expect(editor.state.options!.tripId, id);
      const body = 'لدي ملاحظة مهمة عن تفاصيل هذه الرحلة';
      await tester.enterText(find.byKey(const Key('support-body')), body);
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('support-submit')));
      await tester.tap(find.byKey(const Key('support-submit')));
      await tester.pumpAndSettle();
      final details = tester
          .element(find.byType(SupportTicketDetailsPage))
          .read<SupportDetailCubit>();
      final ticket = details.state.ticket!;
      expect(ticket.tripId, id);
      expect(ticket.body, body);
      await showCustomerHome(tester, router);
      router.push(AppRoutes.supportTicketLocation(ticket.id));
      await tester.pumpAndSettle();
      expect(
        tester
            .element(find.byType(SupportTicketDetailsPage))
            .read<SupportDetailCubit>()
            .state
            .ticket!
            .body,
        body,
      );
      await showCustomerHome(tester, router);
      await customerAuth(tester).logout();
      await tester.pumpAndSettle();
      await enterCustomerSession(tester, phone: null);
      router.go(AppRoutes.supportTicketLocation(ticket.id));
      await tester.pumpAndSettle();
      expect(
        tester
            .element(find.byType(SupportTicketDetailsPage))
            .read<SupportDetailCubit>()
            .state
            .ticket,
        isNull,
      );
      expect(find.text(body), findsNothing);
      router.go(AppRoutes.completionLocation(id));
      await tester.pumpAndSettle();
      expect(
        tester
            .element(find.byType(CompletionPage))
            .read<CompletionCubit>()
            .state
            .completion,
        isNull,
      );
      expect(find.text(comment), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    },
  );
}
