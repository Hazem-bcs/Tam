import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_details_driver_card.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_details_information_card.dart';
import 'package:tam_customer/shared/data/mock/seed_trips.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';

import 'support/trips_test_support.dart';

void main() {
  testWidgets(
    'wallet and coupon use stored data without inventing a discount or settlement',
    (tester) async {
      final original = seedMockTrips().first;
      final trip = Trip(
        id: original.id,
        createdAt: original.createdAt,
        status: TripStatus.completed,
        booking: TripBookingInput(
          pickup: original.booking.pickup,
          destination: original.booking.destination,
          vehicleClassId: 'standard',
          fare: original.booking.fare,
          paymentMethod: TripPaymentMethod.wallet,
          couponCode: 'TEST20',
        ),
      );
      tripsViewport(tester, const Size(320, 780));
      await tester.pumpWidget(
        tripsTestApp(
          Scaffold(
            body: SingleChildScrollView(
              child: TripDetailsInformationCard(trip: trip),
            ),
          ),
          scale: 2,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('TEST20'), findsOneWidget);
      expect(find.text('المحفظة'), findsOneWidget);
      expect(find.text('قيمة الخصم غير محفوظة'), findsOneWidget);
      expect(find.text('غير مؤكدة في بيانات الرحلة'), findsOneWidget);
      expect(find.text('مدفوع'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('driver details use assigned identity and localized vehicle', (
    tester,
  ) async {
    final original = seedMockTrips().first;
    final trip = original.withLive(
      TripStatus.completed,
      TripLiveDetails(
        revision: 1,
        updatedAt: original.createdAt,
        statusChangedAt: original.createdAt,
        driver: const TripDriver(
          id: 'test-driver',
          name: 'سائق الاختبار',
          nameEn: 'Test Driver',
          vehicle: 'مركبة اختبار',
          vehicleEn: 'Test Vehicle',
          plate: 'TEST 123',
          rating: 4.9,
        ),
      ),
    );
    tripsViewport(tester, const Size(320, 780));
    await tester.pumpWidget(
      tripsTestApp(
        Scaffold(
          body: SingleChildScrollView(child: TripDetailsDriverCard(trip: trip)),
        ),
        language: 'en',
        scale: 2,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Test Driver'), findsOneWidget);
    expect(find.text('Test Vehicle · TEST 123'), findsOneWidget);
    expect(find.text('4.9'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
