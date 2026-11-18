import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/active_trip/data/mock/mock_active_trip_repository.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_places.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/data/ride_contract_parser.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/data/trip_wire_codec.dart';
import 'package:tam_customer/shared/domain/trip.dart';

Map<String, dynamic> schedulingExample(String name) =>
    jsonDecode(
          File(
            '../../docs/api/scheduling/examples/$name.json',
          ).readAsStringSync(),
        )
        as Map<String, dynamic>;

void main() {
  test(
    'quote and trip examples exactly match deterministic mock output',
    () async {
      final now = DateTime.utc(2026, 11, 9, 12);
      final store = MockTripStore(now: () => now);
      addTearDown(store.dispose);
      final repository = MockRideRequestRepository(
        trips: store,
        now: () => now,
      );
      final quote = await repository.requestQuote(
        pickup: mockRidePlaces[0].location,
        destination: mockRidePlaces[1].location,
        vehicleClass: RideVehicleClass.standard,
        scheduledAt: DateTime.utc(2026, 11, 9, 15),
      );
      expect(
        RideContractParser.quote(schedulingExample('quote-success')),
        quote,
      );
      final trip = await repository.confirm(
        quote: quote,
        idempotencyKey: 'example',
      );
      expect(
        RideContractParser.trip(schedulingExample('trip-scheduled')),
        trip,
      );
      expect(
        TripWireCodec.toJson(trip),
        schedulingExample('trip-scheduled')['data'],
      );
      expect(
        RideContractParser.trip(schedulingExample('trip-cancelled')),
        store.cancel(trip.id),
      );
      final request = schedulingExample('confirm-request');
      expect(
        request['scheduled_at'],
        schedulingExample('quote-request')['scheduled_at'],
      );
      expect(
        request['scheduled_at'],
        trip.booking.scheduledAt!.toIso8601String(),
      );
    },
  );

  test(
    'upcoming examples match ordered mock reservations and targeted cancellation',
    () async {
      final now = DateTime.utc(2026, 11, 9, 12);
      final store = MockTripStore(now: () => now);
      final live = MockActiveTripRepository(
        store,
        now: () => now,
        autoStart: false,
      );
      addTearDown(() async {
        await live.dispose();
        await store.dispose();
      });
      final repository = MockRideRequestRepository(
        trips: store,
        now: () => now,
      );
      for (final day in [9, 10]) {
        final quote = await repository.requestQuote(
          pickup: mockRidePlaces[0].location,
          destination: mockRidePlaces[1].location,
          vehicleClass: RideVehicleClass.standard,
          scheduledAt: DateTime.utc(2026, 11, day, 15),
        );
        await repository.confirm(quote: quote, idempotencyKey: 'schedule-$day');
      }
      expect(await live.current(), isNull);
      expect(
        (await live.upcoming()).map(TripWireCodec.toJson).toList(),
        schedulingExample('trips-upcoming')['data'],
      );
      await live.cancel('mock-trip-1');
      expect(
        (await live.upcoming()).map(TripWireCodec.toJson).toList(),
        schedulingExample('trips-upcoming-after-cancel')['data'],
      );
    },
  );

  test(
    'scheduled parsing rejects absent, local, impossible and inconsistent times',
    () {
      for (final value in [
        null,
        '2026-11-09T15:00:00+03:00',
        '2026-02-30T15:00:00Z',
        '2026-11-09T25:00:00Z',
        '2026-11-09T11:59:00Z',
        7,
      ]) {
        final json = schedulingExample('trip-scheduled');
        (json['data'] as Map<String, dynamic>)['scheduled_at'] = value;
        expect(() => RideContractParser.trip(json), throwsFormatException);
        expect(
          () => TripWireCodec.fromJson(json['data']),
          throwsFormatException,
        );
      }
      final quote = schedulingExample('quote-success');
      (quote['data'] as Map<String, dynamic>)['scheduled_at'] =
          '2026-02-30T12:00:00Z';
      expect(() => RideContractParser.quote(quote), throwsFormatException);
    },
  );

  test(
    'Postman saved responses, request identity and error fixtures stay aligned',
    () {
      final collection =
          jsonDecode(
                File(
                  '../../docs/api/scheduling/scheduling-v1.postman_collection.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      expect(collection['info']['schema'], contains('/v2.1.0/'));
      final items = collection['item'] as List;
      expect(items, hasLength(6));
      expect(
        items.last['request']['url'],
        '{{base_url}}/trips?filter=scheduled&sort=scheduled_at_asc&limit=20',
      );
      expect(collection['auth']['type'], 'bearer');
      final confirm = items[1]['request'];
      expect(
        jsonDecode(confirm['body']['raw']),
        schedulingExample('confirm-request'),
      );
      expect(
        (confirm['header'] as List)
            .where((h) => h['key'] == 'Idempotency-Key')
            .single['value'],
        '{{operation_id}}',
      );
      for (final item in items) {
        for (final saved in item['response']) {
          final payload = jsonDecode(saved['body']) as Map<String, dynamic>;
          if (saved['code'] >= 400) {
            final failure = RideContractParser.failure(payload);
            expect(
              payload,
              schedulingExample(
                'error-${failure.code.toLowerCase().replaceAll('_', '-')}',
              ),
            );
          } else if (payload['data'] is List) {
            for (final trip in payload['data']) {
              expect(TripWireCodec.fromJson(trip).status, TripStatus.scheduled);
            }
          } else if (payload['data'].containsKey('quote_id')) {
            expect(RideContractParser.quote(payload).scheduledAt, isNotNull);
          } else {
            expect(
              RideContractParser.trip(payload).booking.scheduledAt,
              isNotNull,
            );
          }
        }
      }
    },
  );
}
