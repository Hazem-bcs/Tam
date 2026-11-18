import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_places.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_pricing.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_snapshot_store.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/data/trip_wire_codec.dart';

import '../../shared/mock_trip_snapshot_test.dart' show MemorySnapshots;

void main() {
  test(
    'Arabic coupon pricing, confirmation and restart preserve identifier and fare',
    () async {
      final now = DateTime.utc(2026, 11, 18, 12);
      final cache = MemorySnapshots();
      final snapshots = MockTripSnapshotStore(cache);
      final store = MockTripStore(now: () => now, snapshots: snapshots);
      await store.openSession('local:coupon-owner');
      final repository = MockRideRequestRepository(
        trips: store,
        now: () => now,
      );
      Future<RideQuote> quote([String? code]) => repository.requestQuote(
        pickup: mockRidePlaces[0].location,
        destination: mockRidePlaces[1].location,
        vehicleClass: RideVehicleClass.standard,
        couponCode: code,
      );
      final full = await quote();
      final arabic = await quote(' تم١٠ ');
      final latin = await quote('tam10');
      expect(arabic.couponCode, MockRidePricing.arabicCouponCode);
      expect(latin.couponCode, MockRidePricing.couponCode);
      expect(arabic.fare, latin.fare);
      expect(
        arabic.discount!.amountMinor,
        MockRidePricing.discountFor(full.fare.amountMinor),
      );
      expect(
        arabic.fare.amountMinor + arabic.discount!.amountMinor,
        full.fare.amountMinor,
      );
      final booked = await repository.confirm(
        quote: arabic,
        idempotencyKey: 'arabic-booking',
      );
      expect(booked.booking.couponCode, 'تم10');
      expect(TripWireCodec.fromJson(TripWireCodec.toJson(booked)), booked);
      expect(
        (await repository.confirm(
          quote: arabic,
          idempotencyKey: 'arabic-booking',
        )).id,
        booked.id,
      );
      expect(store.trips, hasLength(1));
      await store.flush();
      await store.dispose();
      final reopened = MockTripStore(now: () => now, snapshots: snapshots);
      await reopened.openSession('local:coupon-owner');
      expect(reopened.find(booked.id), booked);
      await reopened.openSession('local:other-owner');
      expect(reopened.trips, isEmpty);
      await reopened.dispose();
    },
  );
}
