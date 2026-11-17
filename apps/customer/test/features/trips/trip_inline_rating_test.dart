import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/features/completion/data/mock/mock_completion_repository.dart';
import 'package:tam_customer/features/completion/presentation/widgets/completion_summary.dart';
import 'package:tam_customer/features/trips/trips_entry.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/data/mock/seed_trips.dart';

import 'support/trips_test_support.dart';

void main() {
  testWidgets(
    'inline rating saves once on the same trip without a second summary or rebooking',
    (tester) async {
      tripsViewport(tester, const Size(390, 844));
      final store = MockTripStore(
        seed: seedMockTrips(includeReceiptPreview: true),
      );
      final completion = MockCompletionRepository(
        store,
        now: () => DateTime.utc(2026, 11, 17),
      );
      addTearDown(store.dispose);
      addTearDown(completion.dispose);
      await tester.pumpWidget(
        tripsTestApp(
          Builder(
            builder: (context) => buildTripsFeature(
              context,
              navigation: TripsNavigationSpy(),
              dataMode: FeatureDataMode.mock,
              mockTrips: store,
              completionRepository: completion,
              tripId: 'mock-history-001',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CompletionSummary), findsNothing);
      expect(find.text('اطلب مجددًا'), findsNothing);
      expect(find.text('محمد أحمد'), findsOneWidget);
      expect(find.text('غير متوفر'), findsNothing);
      expect(find.text('مدفوع'), findsOneWidget);
      final star = find.byKey(const Key('completion-stars-5'));
      await tester.ensureVisible(star);
      await tester.pumpAndSettle();
      await tester.tap(star);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('completion-comment')));
      await tester.enterText(
        find.byKey(const Key('completion-comment')),
        'رحلة ممتازة',
      );
      await tester.ensureVisible(find.byKey(const Key('completion-submit')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('completion-submit')));
      await tester.pumpAndSettle();
      final saved = await completion.fetch('mock-history-001');
      expect(saved.rating?.stars, 5);
      expect(saved.rating?.comment, 'رحلة ممتازة');
      expect(saved.canRate, false);
      expect(find.byKey(const Key('completion-submit')), findsNothing);
      expect(find.byType(CompletionSummary), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
