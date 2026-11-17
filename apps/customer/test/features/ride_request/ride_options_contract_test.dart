import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_places.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/data/repositories/unavailable_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/data/ride_contract_parser.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/trip.dart';

Map<String, dynamic> fixture(String name) =>
    jsonDecode(
          File(
            '../../docs/api/ride_request/examples/$name.json',
          ).readAsStringSync(),
        )
        as Map<String, dynamic>;
void main() {
  test(
    'v2 wallet/coupon example exactly matches the issued mock quote',
    () async {
      var now = DateTime.utc(2026, 11, 7, 12);
      final store = MockTripStore(now: () => now);
      addTearDown(store.dispose);
      final repository = MockRideRequestRepository(
        trips: store,
        now: () => now,
      );
      final actual = await repository.requestQuote(
        pickup: mockRidePlaces[0].location,
        destination: mockRidePlaces[1].location,
        vehicleClass: RideVehicleClass.standard,
        paymentMethod: TripPaymentMethod.wallet,
        couponCode: 'TAM10',
      );
      expect(
        actual,
        RideContractParser.quote(fixture('quote_wallet_coupon_success')),
      );
      now = now.add(const Duration(seconds: 30));
      final trip = await repository.confirm(
        quote: actual,
        idempotencyKey: 'wallet-coupon-example',
      );
      expect(
        trip,
        RideContractParser.trip(fixture('trip_wallet_coupon_success')),
      );
    },
  );
  test('legacy v1 means cash, without a coupon or implicit discount', () {
    final old = RideContractParser.quote(fixture('quote_success'));
    expect(old.paymentMethod, TripPaymentMethod.cash);
    expect(old.couponCode, isNull);
    expect(old.discount, isNull);
  });
  test(
    'wire parser rejects unknown methods, malformed codes and inconsistent discount money',
    () {
      for (final patch in [
        {'payment_method': 'card'},
        {'coupon_code': ' '},
        {'discount': null},
        {
          'discount': {
            'amount_minor': 2700,
            'currency': 'USD',
            'minor_unit': 0,
          },
        },
      ]) {
        final json = fixture('quote_wallet_coupon_success');
        (json['data'] as Map<String, dynamic>).addAll(patch);
        expect(() => RideContractParser.quote(json), throwsFormatException);
      }
    },
  );
  test(
    'api mode never accepts a mock coupon or simulates a wallet payment',
    () async {
      await expectLater(
        const UnavailableRideRequestRepository().requestQuote(
          pickup: mockRidePlaces[0].location,
          destination: mockRidePlaces[1].location,
          vehicleClass: RideVehicleClass.standard,
          paymentMethod: TripPaymentMethod.wallet,
          couponCode: 'TAM10',
        ),
        throwsA(
          isA<RideRequestFailure>().having(
            (e) => e.code,
            'code',
            'SERVICE_UNAVAILABLE',
          ),
        ),
      );
    },
  );
}
