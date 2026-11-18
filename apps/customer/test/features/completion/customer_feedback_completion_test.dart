import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/completion/data/mock/mock_completion_repository.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'completion_test_support.dart';
import 'completion_widget_support.dart';

void main() {
  testWidgets(
    'compact essentials expose home immediately and retain full trip details',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = ControlledCompletionRepository();
      addTearDown(repo.events.close);
      var home = 0;
      await pumpCompletion(
        tester,
        repository: repo,
        locale: 'en',
        onHome: () => home++,
      );
      expect(
        find.byKey(const Key('completion-home-action')).hitTestable(),
        findsOneWidget,
      );
      expect(find.text('Trip ID: mock-history-001'), findsNothing);
      await tester.tap(find.text('Trip details'));
      await tester.pumpAndSettle();
      expect(find.text('Trip ID: mock-history-001'), findsOneWidget);
      await tester.tap(find.byKey(const Key('completion-home')));
      expect(home, 1);
      expect(repo.calls, isEmpty);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'save then home and reopen preserves the trip and one immutable rating',
    (tester) async {
      final store = MockTripStore(
        seed: [completionTrip()],
        now: () => completionNow,
      );
      final repo = MockCompletionRepository(store, now: () => completionNow);
      addTearDown(repo.dispose);
      addTearDown(store.dispose);
      var home = 0;
      await pumpCompletion(
        tester,
        repository: repo,
        locale: 'en',
        onHome: () => home++,
      );
      await tester.ensureVisible(find.byKey(const Key('completion-stars-4')));
      await tester.tap(find.byKey(const Key('completion-stars-4')));
      await tester.enterText(
        find.byKey(const Key('completion-comment')),
        'Comfortable ride',
      );
      await tester.ensureVisible(find.byKey(const Key('completion-submit')));
      await tester.tap(find.byKey(const Key('completion-submit')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('completion-home')));
      expect(home, 1);
      await tester.pumpWidget(const SizedBox());
      await pumpCompletion(tester, repository: repo, locale: 'en');
      expect(find.text('Your rating is saved. Thank you'), findsOneWidget);
      expect(find.byKey(const Key('completion-submit')), findsNothing);
      final saved = await repo.fetch('mock-history-001');
      expect(saved.rating!.stars, 4);
      expect(saved.rating!.comment, 'Comfortable ride');
      expect(store.find('mock-history-001'), completionTrip());
      await tester.pumpWidget(const SizedBox());
    },
  );
}
