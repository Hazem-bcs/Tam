import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/completion/domain/completion_repository.dart';
import 'completion_test_support.dart';
import 'completion_widget_support.dart';

void main() {
  setUpAll(loadCompletionFonts);
  for (final locale in ['ar', 'en']) {
    for (final layout in [
      (name: '320-x2', size: const Size(320, 740), scale: 2.0),
      (name: '390-x1', size: const Size(390, 844), scale: 1.0),
      (name: '800-x1', size: const Size(800, 1000), scale: 1.0),
      (name: '800-x2', size: const Size(800, 1000), scale: 2.0),
      (name: 'landscape', size: const Size(844, 390), scale: 1.0),
    ]) {
      testWidgets(
        '$locale ${layout.name}: scrollable summary, form and actions without overflow',
        (tester) async {
          tester.view.physicalSize = layout.size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final repo = ControlledCompletionRepository();
          addTearDown(repo.events.close);
          await pumpCompletion(
            tester,
            repository: repo,
            locale: locale,
            scale: layout.scale,
          );
          expect(tester.takeException(), isNull);
          await captureCompletion(tester, 'summary-$locale-${layout.name}');
          await showCompletionForm(tester);
          await tester.ensureVisible(
            find.byKey(const Key('completion-stars-3')),
          );
          await tester.tap(find.byKey(const Key('completion-stars-3')));
          await tester.enterText(
            find.byKey(const Key('completion-comment')),
            locale == 'ar'
                ? 'رحلة مريحة وتعليق اختياري طويل لاختبار التمرير'
                : 'A comfortable trip and an optional multiline comment',
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await captureCompletion(tester, 'form-$locale-${layout.name}');
          await tester.ensureVisible(
            find.byKey(const Key('completion-submit')),
          );
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
  }
  for (final locale in ['ar', 'en']) {
    testWidgets(
      '$locale 320 x2 keyboard keeps focused input and submit reachable',
      (tester) async {
        tester.view.physicalSize = const Size(320, 740);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        final repo = ControlledCompletionRepository();
        addTearDown(repo.events.close);
        await pumpCompletion(
          tester,
          repository: repo,
          locale: locale,
          scale: 2,
        );
        await showCompletionForm(tester);
        await tester.ensureVisible(find.byKey(const Key('completion-stars-4')));
        await tester.tap(find.byKey(const Key('completion-stars-4')));
        await tester.tap(find.byKey(const Key('completion-comment')));
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('completion-comment')),
          'تعليق',
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const Key('completion-comment')));
        await captureCompletion(tester, 'keyboard-$locale-320-x2');
        await tester.ensureVisible(find.byKey(const Key('completion-submit')));
        await tester.tap(find.byKey(const Key('completion-submit')));
        await tester.pumpAndSettle();
        expect(repo.calls.single.stars, 4);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
  testWidgets('large text loading remains bounded while response is pending', (
    tester,
  ) async {
    final result = Completer<TripCompletion>();
    final repo = ControlledCompletionRepository()
      ..onFetch = () => result.future;
    addTearDown(repo.events.close);
    await pumpCompletion(tester, repository: repo, scale: 2, settle: false);
    expect(tester.takeException(), isNull);
    result.complete(completionSnapshot());
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
  });
}
