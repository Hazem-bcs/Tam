import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/features/trips/presentation/pages/trip_details_page.dart';
import 'package:tam_customer/features/trips/trips_entry.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/data/mock/seed_trips.dart';

import 'support/trips_test_support.dart';

const _capture = bool.fromEnvironment('CAPTURE_TRIP_DETAILS_PREVIEW');

void main() {
  setUpAll(() async {
    if (!_capture) return;
    for (final font in {
      'TamSansArabic': 'assets/fonts/NotoSansArabic-Regular.ttf',
      'TamSansLatin': 'assets/fonts/NotoSans-Regular.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    }.entries) {
      await (FontLoader(font.key)..addFont(rootBundle.load(font.value))).load();
    }
  });

  testWidgets('premium details show a light app bar and recorded trip data', (
    tester,
  ) async {
    tripsViewport(tester, const Size(390, 844));
    final store = MockTripStore(seed: seedMockTrips());
    addTearDown(store.dispose);
    await tester.pumpWidget(
      tripsTestApp(
        RepaintBoundary(
          key: const Key('trip-details-premium-preview'),
          child: Builder(
            builder: (context) => buildTripsFeature(
              context,
              navigation: TripsNavigationSpy(),
              dataMode: FeatureDataMode.mock,
              mockTrips: store,
              tripId: 'mock-history-001',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.byType(TripDetailsPage), findsOneWidget);
    expect(find.text('تفاصيل الرحلة'), findsOneWidget);
    expect(find.text('مسار الرحلة'), findsOneWidget);
    expect(find.text('معلومات الرحلة'), findsOneWidget);
    expect(find.textContaining('mock-history-001'), findsOneWidget);
    expect(tester.takeException(), isNull);

    if (_capture) {
      // Ensure the user-supplied bitmap has decoded before capturing a golden.
      await tester.runAsync(() async {
        await precacheImage(
          const AssetImage('assets/maps/vehicle-sedan-user.png'),
          tester.element(find.byType(TripDetailsPage)),
        );
      });
      await tester.pumpAndSettle();
      await expectLater(
        find.byKey(const Key('trip-details-premium-preview')),
        matchesGoldenFile('goldens/trip-details-premium-ar-390.png'),
      );
      // A tall review capture includes the action section without scrolling;
      // this is a Flutter test rendering, not an Android device screenshot.
      tester.view.physicalSize = const Size(390, 1320);
      await tester.pump();
      await tester.pumpAndSettle();
      await expectLater(
        find.byKey(const Key('trip-details-premium-preview')),
        matchesGoldenFile('goldens/trip-details-premium-ar-full.png'),
      );
    }
  });
}
