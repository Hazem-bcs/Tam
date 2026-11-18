import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_places.dart';
import 'package:tam_customer/features/ride_request/ride_request_entry.dart';
import 'package:tam_customer/features/settings/data/mock/mock_coupon_book.dart';
import 'package:tam_customer/features/settings/presentation/coupon_book_scope.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/trip.dart';

import '../../../../support/page_scroll.dart';
import '../../scheduling/schedule_widget_support.dart';

void main() {
  testWidgets(
    'active saved coupons appear and selecting one updates the quote',
    (tester) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final book = MockCouponBook()..add('TAM10');
      final store = MockTripStore();
      await tester.pumpWidget(
        CouponBookScope(
          book: book,
          child: MaterialApp(
            theme: AppTheme.light,
            locale: const Locale('ar'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Builder(
              builder: (context) => buildRideRequestFeature(
                context,
                navigation: const ScheduleTestNavigation(),
                dataMode: FeatureDataMode.mock,
                mockTrips: store,
                prefill: TripPrefill(
                  pickup: mockRidePlaces[0].location,
                  destination: mockRidePlaces[1].location,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final offer = find.byKey(const ValueKey('ride-offer-TAM10'));
      await revealPageWidget(tester, offer);
      expect(find.byKey(const ValueKey('ride-offer-NOW25')), findsNothing);
      expect(find.byKey(const ValueKey('ride-offer-SAVE15')), findsNothing);
      await tester.tap(offer);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('ride-coupon-applied')), findsOneWidget);
      expect(find.text('TAM10'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      book.dispose();
      await store.dispose();
    },
  );
}
