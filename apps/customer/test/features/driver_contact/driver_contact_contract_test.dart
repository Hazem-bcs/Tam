import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/active_trip/data/mock/mock_active_trip_repository.dart';
import 'package:tam_customer/features/driver_contact/data/driver_contact_codec.dart';
import 'package:tam_customer/features/driver_contact/data/mock/mock_driver_contact_repository.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/data/mock/seed_trips.dart';

Map<String, dynamic> example(String name) =>
    jsonDecode(
          File(
            '../../docs/api/driver_contact/examples/$name.json',
          ).readAsStringSync(),
        )
        as Map<String, dynamic>;
void main() {
  test('example equals contact from the shared assigned trip', () async {
    var now = DateTime.utc(2026, 11, 9, 12);
    final trips = MockTripStore(now: () => now);
    final engine = MockActiveTripRepository(trips, now: () => now);
    final repo = MockDriverContactRepository(trips, now: () => now);
    addTearDown(engine.dispose);
    addTearDown(trips.dispose);
    addTearDown(repo.dispose);
    final trip = trips.create(
      seedMockTrips().first.booking,
      idempotencyKey: 'book',
    );
    now = now.add(const Duration(seconds: 17));
    engine.advance();
    final actual = await repo.fetch(
      tripId: trip.id,
      driverId: trips.find(trip.id)!.live!.driver!.id,
    );
    expect(DriverContactCodec.decode(example('contact')), actual);
  });
  test('strict decoder rejects unsafe target and timestamps', () {
    for (final phone in [
      'tel:+963900000000',
      '+9639;12345678',
      'javascript:bad',
      '0039',
    ]) {
      final value = example('contact');
      value['data']['phone_e164'] = phone;
      expect(() => DriverContactCodec.decode(value), throwsFormatException);
    }
    final value = example('contact');
    value['data']['expires_at'] = '2026-02-31T00:00:00Z';
    expect(() => DriverContactCodec.decode(value), throwsFormatException);
  });
  test(
    'saved Postman successes and errors decode; ownership and driver guard documented',
    () {
      final collection = jsonDecode(
        File(
          '../../docs/api/driver_contact/driver_contact-v1.postman_collection.json',
        ).readAsStringSync(),
      );
      expect(collection['auth']['type'], 'bearer');
      final item = collection['item'][0];
      expect(
        item['request']['url']['raw'],
        contains('driver_id={{driver_id}}'),
      );
      final codes = <String>{};
      for (final r in item['response'] as List) {
        final body = jsonDecode(r['body'] as String) as Map<String, dynamic>;
        if (r['code'] == 200) {
          DriverContactCodec.decode(body);
        } else {
          codes.add(DriverContactCodec.failure(body).code);
        }
      }
      expect(
        codes,
        containsAll([
          'FORBIDDEN',
          'DRIVER_CHANGED',
          'CONTACT_UNAVAILABLE',
          'UNAUTHENTICATED',
        ]),
      );
    },
  );
}
