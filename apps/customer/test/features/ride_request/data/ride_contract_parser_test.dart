import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/ride_request/data/ride_contract_parser.dart';
import 'package:tam_customer/shared/domain/trip.dart';

Map<String, dynamic> example(String name) =>
    jsonDecode(
          File(
            '../../docs/api/ride_request/examples/$name.json',
          ).readAsStringSync(),
        )
        as Map<String, dynamic>;

void main() {
  test('places success and empty page parse as fixture locations', () {
    final places = RideContractParser.places(example('places_success'));
    expect(places.single.id, 'place-mezzeh');
    expect(places.single.location.point.latitude, 33.5);
    expect(places.single.englishLabel, 'Mezzeh, Al-Jalaa Street');
    expect(RideContractParser.places(example('places_empty')), isEmpty);
  });

  test(
    'quote response maps money, expiry, vehicle and canonical locations',
    () {
      final quote = RideContractParser.quote(example('quote_success'));
      expect(quote.id, 'mock-quote-1');
      expect(quote.fare, Money(amountMinor: 27000));
      expect(quote.distanceMeters, 5019);
      expect(quote.durationMinutes, 18);
      expect(quote.expiresAt, DateTime.utc(2026, 11, 7, 12, 1, 30));
    },
  );

  test('confirmed trip response is parsed as the shared Trip model', () {
    final trip = RideContractParser.trip(example('trip_success'));
    expect(trip.id, 'mock-trip-1');
    expect(trip.status, TripStatus.requested);
    expect(trip.booking.vehicleClassId, 'standard');
    expect(trip.booking.fare, Money(amountMinor: 27000));
    expect(trip.createdAt.isUtc, isTrue);
  });

  test('contract errors retain machine-readable codes', () {
    for (final code in ['expired', 'conflict', 'unavailable', 'validation']) {
      final failure = RideContractParser.failure(example('error_$code'));
      expect(failure.code, isNotEmpty);
    }
  });

  test('reject malformed unknown statuses, dates and money', () {
    final badTrip = example('trip_success');
    (badTrip['data'] as Map<String, dynamic>)['status'] = 'unknown';
    expect(() => RideContractParser.trip(badTrip), throwsFormatException);
    final badQuote = example('quote_success');
    (badQuote['data'] as Map<String, dynamic>)['expires_at'] =
        '2026-11-07T12:01:30+03:00';
    expect(() => RideContractParser.quote(badQuote), throwsFormatException);
    final badMoney = example('quote_success');
    ((badMoney['data'] as Map<String, dynamic>)['fare']
            as Map<String, dynamic>)['amount_minor'] =
        -5;
    expect(() => RideContractParser.quote(badMoney), throwsFormatException);
  });
}
