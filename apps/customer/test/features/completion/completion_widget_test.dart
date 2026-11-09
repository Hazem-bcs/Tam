import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/completion/domain/completion_repository.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'completion_test_support.dart';
import 'completion_widget_support.dart';

void main() {
  setUpAll(loadCompletionFonts);
  testWidgets(
    'rating validates, freezes while sending, then renders immutable result',
    (tester) async {
      final repo = ControlledCompletionRepository();
      addTearDown(repo.events.close);
      final sent = Completer<TripCompletion>();
      repo.onSubmit = (_) => sent.future;
      final c = await pumpCompletion(tester, repository: repo, locale: 'en');
      expect(
        tester
            .widget<TamButton>(find.byKey(const Key('completion-submit')))
            .onPressed,
        isNull,
      );
      await showCompletionForm(tester);
      await tester.tap(find.byKey(const Key('completion-stars-4')));
      await tester.enterText(
        find.byKey(const Key('completion-comment')),
        '  رحلة مريحة  ',
      );
      await tester.ensureVisible(find.byKey(const Key('completion-submit')));
      await tester.tap(find.byKey(const Key('completion-submit')));
      await tester.pump();
      expect(c.state.submitting, isTrue);
      expect(repo.calls.single.comment, 'رحلة مريحة');
      expect(
        tester
            .widget<IconButton>(find.byKey(const Key('completion-stars-1')))
            .onPressed,
        isNull,
      );
      sent.complete(
        completionSnapshot(
          revision: 2,
          rating: completionRating(key: 'widget-key'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('completion-comment')), findsNothing);
      expect(find.text('Your rating is saved. Thank you'), findsOneWidget);
      await captureCompletion(tester, 'saved-en-800');
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'optional empty comment, 501-codepoint validation and selected semantics',
    (tester) async {
      final repo = ControlledCompletionRepository();
      addTearDown(repo.events.close);
      final semantics = tester.ensureSemantics();

      await pumpCompletion(tester, repository: repo, locale: 'en');
      await showCompletionForm(tester);
      await tester.tap(find.byKey(const Key('completion-stars-5')));
      expect(find.bySemanticsLabel('5 of 5 stars'), findsWidgets);
      semantics.dispose();
      await tester.enterText(
        find.byKey(const Key('completion-comment')),
        '😀' * 501,
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TamButton>(find.byKey(const Key('completion-submit')))
            .onPressed,
        isNull,
      );
      await tester.enterText(find.byKey(const Key('completion-comment')), '');
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TamButton>(find.byKey(const Key('completion-submit')))
            .onPressed,
        isNotNull,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'uncertain result keeps text readonly and retry reconciles without duplicate',
    (tester) async {
      final repo = ControlledCompletionRepository();
      addTearDown(repo.events.close);
      repo.onSubmit = (_) async =>
          throw const CompletionFailure('NETWORK_ERROR', uncertain: true);
      await pumpCompletion(tester, repository: repo, locale: 'ar');
      await showCompletionForm(tester);
      await tester.tap(find.byKey(const Key('completion-stars-4')));
      await tester.enterText(
        find.byKey(const Key('completion-comment')),
        'رحلة مريحة',
      );
      await tester.ensureVisible(find.byKey(const Key('completion-submit')));
      await tester.tap(find.byKey(const Key('completion-submit')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('completion-retry')));
      await captureCompletion(tester, 'uncertain-ar-800');
      repo.onFetch = () async => completionSnapshot(
        revision: 2,
        rating: completionRating(key: 'widget-key'),
      );
      await tester.tap(find.byKey(const Key('completion-retry')));
      await tester.pumpAndSettle();
      expect(repo.calls.length, 1);
      expect(find.byKey(const Key('completion-comment')), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'loading, offline retry, not completed and reset expose meaningful states',
    (tester) async {
      final repo = ControlledCompletionRepository();
      addTearDown(repo.events.close);
      final result = Completer<TripCompletion>();
      repo.onFetch = () => result.future;
      await pumpCompletion(
        tester,
        repository: repo,
        locale: 'en',
        settle: false,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      result.completeError(const CompletionFailure('NETWORK_ERROR'));
      await tester.pumpAndSettle();
      expect(
        find.text('Could not connect. Check your network and retry.'),
        findsOneWidget,
      );
      await captureCompletion(tester, 'offline-en-800');
      repo.onFetch = () async =>
          throw const CompletionFailure('TRIP_NOT_COMPLETED');
      await tester.tap(find.byKey(const Key('completion-retry')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('completion-submit')), findsNothing);
      repo.events.add(const CompletionChange(sessionReset: true));
      await tester.pumpAndSettle();
      expect(
        find.text('Your session ended. Return home to continue.'),
        findsOneWidget,
      );
      expect(find.text('Contact support for this trip'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('navigation callbacks use explicit destinations', (tester) async {
    final repo = ControlledCompletionRepository();
    addTearDown(repo.events.close);
    var back = 0, support = 0, home = 0;
    await pumpCompletion(
      tester,
      repository: repo,
      locale: 'en',
      onBack: () => back++,
      onSupport: () => support++,
      onHome: () => home++,
    );
    await tester.tap(find.byType(BackButton));
    await tester.ensureVisible(find.text('Contact support for this trip'));
    await tester.tap(find.text('Contact support for this trip'));
    await tester.ensureVisible(find.text('Return home'));
    await tester.tap(find.text('Return home'));
    expect((back, support, home), (1, 1, 1));
    await tester.pumpWidget(const SizedBox());
  });
}
