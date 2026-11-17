import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'completion_test_support.dart';
import 'completion_widget_support.dart';

void main() {
  setUpAll(loadCompletionFonts);

  testWidgets(
    'quick feedback appends only selected notes to optional comment',
    (tester) async {
      final repo = ControlledCompletionRepository();
      addTearDown(repo.events.close);
      await pumpCompletion(tester, repository: repo, locale: 'en');

      await tester.ensureVisible(find.byKey(const Key('completion-stars-4')));
      await tester.tap(find.byKey(const Key('completion-stars-4')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('completion-tag-0')));
      await tester.tap(find.byKey(const Key('completion-tag-0')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('completion-comment')),
        'Great ride',
      );
      await tester.ensureVisible(find.byKey(const Key('completion-submit')));
      await tester.tap(find.byKey(const Key('completion-submit')));
      await tester.pumpAndSettle();

      expect(repo.calls.single.stars, 4);
      expect(repo.calls.single.comment, 'Great ride, Respectful driver');
      expect(find.byKey(const Key('completion-comment')), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('switching star sentiment clears previous quick selections', (
    tester,
  ) async {
    final repo = ControlledCompletionRepository();
    addTearDown(repo.events.close);
    await pumpCompletion(tester, repository: repo, locale: 'ar');

    await tester.ensureVisible(find.byKey(const Key('completion-stars-5')));
    await tester.tap(find.byKey(const Key('completion-stars-5')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('completion-tag-2')));
    await tester.tap(find.byKey(const Key('completion-tag-2')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('completion-stars-2')));
    await tester.tap(find.byKey(const Key('completion-stars-2')));
    await tester.pumpAndSettle();
    expect(find.text('تأخر الوصول'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('completion-submit')));
    await tester.tap(find.byKey(const Key('completion-submit')));
    await tester.pumpAndSettle();
    expect(repo.calls.single.comment, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });
}
