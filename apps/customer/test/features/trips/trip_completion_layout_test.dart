import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/features/trips/trips_entry.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/data/mock/seed_trips.dart';
import '../../support/preview_fonts.dart';
import 'support/trips_test_support.dart';

const _capture = bool.fromEnvironment('CAPTURE_TRIP_COMPLETION_UI');

final class _Navigation extends TripsNavigationSpy {
  String? completion, support;
  @override
  void openCompletion(String tripId) => completion = tripId;
  @override
  void openSupport({String? tripId}) => support = tripId;
}

void main() {
  setUpAll(() => loadPreviewFonts(enabled: _capture));
  for (final language in ['ar', 'en']) {
    for (final target in [
      (name: 'phone', size: const Size(320, 640), scale: 2.0),
      (name: 'tablet', size: const Size(800, 1000), scale: 1.0),
      (name: 'landscape', size: const Size(844, 390), scale: 2.0),
    ]) {
      testWidgets(
        '$language ${target.name}: completed trip actions remain reachable',
        (tester) async {
          tripsViewport(tester, target.size);
          final store = MockTripStore(seed: seedMockTrips());
          addTearDown(store.dispose);
          final nav = _Navigation();
          await tester.pumpWidget(
            RepaintBoundary(
              key: const Key('trip-completion-preview'),
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: _capture ? previewTheme() : AppTheme.light,
                locale: Locale(language),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(target.scale)),
                  child: child!,
                ),
                home: Builder(
                  builder: (context) => buildTripsFeature(
                    context,
                    navigation: nav,
                    dataMode: FeatureDataMode.mock,
                    mockTrips: store,
                    tripId: 'mock-history-001',
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          for (final key in ['trips-completion', 'trips-support']) {
            final target = find.byKey(Key(key));
            await tester.ensureVisible(target);
            await tester.pumpAndSettle();
            expect(target.hitTestable(), findsOneWidget);
            await tester.tap(target);
            await tester.pumpAndSettle();
          }
          expect(nav.completion, 'mock-history-001');
          expect(nav.support, 'mock-history-001');
          if (_capture) {
            await expectLater(
              find.byKey(const Key('trip-completion-preview')),
              matchesGoldenFile(
                '../../../../../docs/engineering/deliveries/W2-COMPLETION/screenshots/trip-$language-${target.name}.png',
              ),
            );
          }
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
  }
}
