import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/support/data/mock/mock_support_repository.dart';
import 'package:tam_customer/features/support/domain/support_repository.dart';
import 'package:tam_customer/features/support/support_entry.dart';
import 'support_test_support.dart';
import 'support_widget_support.dart';

void main() {
  setUpAll(loadSupportFonts);
  for (final locale in ['ar', 'en']) {
    for (final target in [
      (320.0, 640.0, 2.0),
      (390.0, 844.0, 1.0),
      (800.0, 1000.0, 2.0),
      (800.0, 390.0, 1.0),
    ]) {
      testWidgets('$locale editor and hub layout ${target.$1} x${target.$3}', (
        tester,
      ) async {
        tester.view.physicalSize = Size(target.$1, target.$2);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final store = supportStore();
        final repo = MockSupportRepository(store, now: () => supportNow);
        addTearDown(repo.dispose);
        addTearDown(store.dispose);
        await pumpSupport(
          tester,
          buildSupportFeature(
            repository: repo,
            policy: const SupportPolicy(),
            now: () => supportNow,
            onBack: () {},
            onCreate: () {},
            onTicket: (_) {},
            onChooseTrip: () {},
          ),
          locale: locale,
          scale: target.$3,
        );
        expect(tester.takeException(), isNull);
        await captureSupport(
          tester,
          'hub-$locale-${target.$1.toInt()}x${target.$2.toInt()}-x${target.$3.toInt()}',
        );
        await pumpSupport(
          tester,
          buildSupportEditorFeature(
            repository: repo,
            policy: const SupportPolicy(),
            now: () => supportNow,
            tripId: 'trip-1',
            onBack: () {},
            onCreated: (_) {},
          ),
          locale: locale,
          scale: target.$3,
        );
        expect(tester.takeException(), isNull);
        await captureSupport(
          tester,
          'editor-$locale-${target.$1.toInt()}x${target.$2.toInt()}-x${target.$3.toInt()}',
        );
        await tester.ensureVisible(find.byKey(const Key('support-body')));
        await tester.enterText(
          find.byKey(const Key('support-body')),
          'تفاصيل المشكلة / Details of the issue',
        );
        tester.view.viewInsets = FakeViewPadding(
          bottom: target.$2 < 500 ? 120 : 260,
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const Key('support-submit')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          tester.getRect(find.byKey(const Key('support-submit'))).bottom,
          lessThanOrEqualTo(target.$2 - tester.view.viewInsets.bottom),
        );
        await captureSupport(
          tester,
          'keyboard-$locale-${target.$1.toInt()}x${target.$2.toInt()}-x${target.$3.toInt()}',
        );
        tester.view.resetViewInsets();
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
  testWidgets(
    'uncertain send locks details and retry opens the one accepted ticket',
    (tester) async {
      final store = supportStore();
      final repo = MockSupportRepository(
        store,
        now: () => supportNow,
        scenario: SupportMockScenario.lostResponse,
      );
      addTearDown(repo.dispose);
      addTearDown(store.dispose);
      final created = <String>[];
      await pumpSupport(
        tester,
        buildSupportEditorFeature(
          repository: repo,
          policy: const SupportPolicy(),
          now: () => supportNow,
          onBack: () {},
          onCreated: created.add,
        ),
      );
      await tester.enterText(
        find.byKey(const Key('support-body')),
        'Details of the issue',
      );
      await tester.ensureVisible(find.byKey(const Key('support-submit')));
      await tester.tap(find.byKey(const Key('support-submit')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextFormField>(find.byType(TextFormField).last).enabled,
        isFalse,
      );
      expect(created, isEmpty);
      await captureSupport(tester, 'state-uncertain');
      await tester.ensureVisible(find.byKey(const Key('support-retry')));
      await tester.tap(find.byKey(const Key('support-retry')));
      await tester.pumpAndSettle();
      expect(created, hasLength(1));
      expect((await repo.tickets()).tickets, hasLength(1));
      await captureSupport(tester, 'state-success');
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'detail is read only; session reset removes body from mounted widgets',
    (tester) async {
      final store = supportStore();
      final repo = MockSupportRepository(store, now: () => supportNow);
      addTearDown(repo.dispose);
      addTearDown(store.dispose);
      final ticket = await repo.create(
        clientRequestId: 'request-0000000001',
        categoryId: 'trip_issue',
        body: 'Sensitive issue details',
        tripId: 'trip-1',
      );
      await pumpSupport(
        tester,
        buildSupportTicketFeature(
          repository: repo,
          id: ticket.id,
          onBack: () {},
        ),
      );
      expect(find.text('Sensitive issue details'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      await captureSupport(tester, 'ticket-detail-ar');
      repo.resetSession();
      await tester.pumpAndSettle();
      expect(find.text('Sensitive issue details'), findsNothing);
      await captureSupport(tester, 'state-session-ended');
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'legal unpublished, legal failure, options offline and loading remain distinct',
    (tester) async {
      final repo = ControlledSupportRepository();
      addTearDown(repo.events.close);
      await pumpSupport(
        tester,
        buildLegalFeature(
          repository: repo,
          kind: LegalDocumentKind.privacy,
          languageCode: 'ar',
          onBack: () {},
        ),
      );
      expect(find.textContaining('غير منشور'), findsOneWidget);
      await captureSupport(tester, 'legal-unpublished-ar');
      repo.onLegal = (_, _) async =>
          throw const SupportFailure('NETWORK_ERROR');
      await pumpSupport(
        tester,
        buildLegalFeature(
          repository: repo,
          kind: LegalDocumentKind.terms,
          languageCode: 'en',
          onBack: () {},
        ),
        locale: 'en',
      );
      expect(find.byKey(const Key('support-retry')), findsOneWidget);
      await captureSupport(tester, 'legal-offline-en');
      repo.onOptions = (_) async => throw const SupportFailure('NETWORK_ERROR');
      await pumpSupport(
        tester,
        buildSupportEditorFeature(
          repository: repo,
          policy: const SupportPolicy(),
          now: () => supportNow,
          onBack: () {},
          onCreated: (_) {},
        ),
      );
      await captureSupport(tester, 'editor-offline');
      await tester.pumpWidget(const SizedBox());
      final delayed = ControlledSupportRepository();
      addTearDown(delayed.events.close);
      final result = Completer<SupportOptions>();
      delayed.onOptions = (_) => result.future;
      await pumpSupport(
        tester,
        buildSupportEditorFeature(
          repository: delayed,
          policy: const SupportPolicy(),
          now: () => supportNow,
          onBack: () {},
          onCreated: (_) {},
        ),
        settle: false,
      );
      await captureSupport(tester, 'editor-loading');
      await tester.pumpWidget(const SizedBox());
      result.complete(SupportOptions(categories: []));
      await tester.pump();
    },
  );
}
