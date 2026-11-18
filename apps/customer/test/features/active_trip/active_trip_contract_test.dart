import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/active_trip/data/active_trip_codec.dart';
import 'package:tam_customer/features/active_trip/data/mock/active_trip_scenario.dart';
import 'package:tam_customer/shared/data/trip_live_codec.dart';
import 'package:tam_customer/shared/data/trip_wire_codec.dart';
import 'active_trip_test_support.dart';

Map<String, dynamic> activeExample(String name) =>
    jsonDecode(
          File(
            '../../docs/api/active_trip/examples/$name.json',
          ).readAsStringSync(),
        )
        as Map<String, dynamic>;
void main() {
  test(
    'all lifecycle examples exactly reproduce the data simulation',
    () async {
      final fixture = ActiveTripFixture(durations: const ActiveTripTimings());
      addTearDown(fixture.dispose);
      final id = fixture.book().id;
      for (final stage in [
        (0, 'requested'),
        (12, 'confirmed'),
        (17, 'en-route'),
        (42, 'arrived'),
        (57, 'in-progress'),
        (87, 'completed'),
      ]) {
        fixture.now = DateTime.utc(
          2026,
          11,
          9,
          12,
        ).add(Duration(seconds: stage.$1));
        final trip = (await fixture.repository.fetch(id))!;
        expect(
          ActiveTripCodec.response(activeExample('live-${stage.$2}')),
          trip,
        );
        expect(
          TripWireCodec.toJson(trip),
          activeExample('live-${stage.$2}')['data'],
        );
      }
    },
  );
  test(
    'scheduled, dispatched, no-driver, cancellation and empty examples match',
    () async {
      final scheduled = ActiveTripFixture(durations: const ActiveTripTimings());
      addTearDown(scheduled.dispose);
      final id = scheduled
          .book(scheduledAt: scheduled.now.add(const Duration(minutes: 30)))
          .id;
      expect(
        await scheduled.repository.fetch(id),
        ActiveTripCodec.response(activeExample('live-scheduled')),
      );
      scheduled.advance(1800);
      expect(
        await scheduled.repository.fetch(id),
        ActiveTripCodec.response(activeExample('live-dispatched')),
      );
      final noDriver = ActiveTripFixture(
        scenario: ActiveTripScenario.noDriver,
        durations: const ActiveTripTimings(),
      );
      addTearDown(noDriver.dispose);
      final noId = noDriver.book().id;
      await noDriver.repository.fetch(noId);
      noDriver.advance(12);
      expect(
        await noDriver.repository.fetch(noId),
        ActiveTripCodec.response(activeExample('live-no-driver')),
      );
      final cancelled = ActiveTripFixture(durations: const ActiveTripTimings());
      addTearDown(cancelled.dispose);
      final cancelId = cancelled.book().id;
      await cancelled.repository.fetch(cancelId);
      cancelled.advance(12);
      await cancelled.repository.fetch(cancelId);
      cancelled.advance(5);
      await cancelled.repository.fetch(cancelId);
      expect(
        await cancelled.repository.cancel(cancelId),
        ActiveTripCodec.response(activeExample('live-cancelled')),
      );
      expect(
        ActiveTripCodec.response(
          activeExample('current-empty'),
          allowEmpty: true,
        ),
        isNull,
      );
      expect(
        () => ActiveTripCodec.response(activeExample('current-empty')),
        throwsFormatException,
      );
    },
  );
  test(
    'malformed snapshots cannot invent status, driver, coordinates or revisions',
    () {
      final changes = <void Function(Map<String, dynamic>)>[
        (d) => d['live'] = null,
        (d) => d['live']['revision'] = 0,
        (d) => d['live']['revision'] = 1.5,
        (d) => d['live']['driver'] = null,
        (d) => d['live']['driver']['rating'] = 6,
        (d) => d['live']['position']['latitude'] = 100,
        (d) => d['live']['position']['recorded_at'] = '2026-02-30T12:00:00Z',
        (d) => d['live']['position']['recorded_at'] = '2026-11-09T12:00:18Z',
        (d) => d['live']['updated_at'] = '2026-11-09T12:00:17+03:00',
        (d) => d['live']['status_changed_at'] = '2026-11-09T11:59:00Z',
        (d) => d['live']['eta_seconds'] = -1,
        (d) => d['live'].remove('eta_seconds'),
        (d) => d['status'] = 'completed',
        (d) => d['status'] = 'no_driver',
        (d) => d['status'] = 'unknown',
      ];
      for (final change in changes) {
        final json = activeExample('live-en-route');
        change(json['data']);
        expect(() => ActiveTripCodec.response(json), throwsFormatException);
      }
      expect(
        () => ActiveTripCodec.response(
          activeExample('live-completed'),
          allowEmpty: true,
        ),
        throwsFormatException,
      );
      expect(
        TripLiveCodec.driverFromJson(mockDriverJson).id,
        'mock-driver-001',
      );
    },
  );
  test('vehicle photo URL is optional and survives the driver codec', () {
    final source = {
      ...mockDriverJson,
      'vehicle_image_url': 'https://example.com/car.png',
    };
    final driver = TripLiveCodec.driverFromJson(source);
    expect(driver.vehicleImageUrl, 'https://example.com/car.png');
    expect(
      TripLiveCodec.driverJson(driver)['vehicle_image_url'],
      driver.vehicleImageUrl,
    );
    expect(
      TripLiveCodec.driverFromJson(mockDriverJson).vehicleImageUrl,
      isNull,
    );
    expect(
      TripLiveCodec.driverFromJson({
        ...mockDriverJson,
        'vehicle_image_url': 'not a url',
      }).vehicleImageUrl,
      isNull,
    );
  });
  test(
    'Postman operations, saved states and bilingual errors match examples',
    () {
      final collection =
          jsonDecode(
                File(
                  '../../docs/api/active_trip/active_trip-v1.postman_collection.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      expect(collection['info']['schema'], contains('/v2.1.0/'));
      expect(collection['auth']['type'], 'bearer');
      final items = collection['item'] as List;
      expect(items, hasLength(3));
      expect(items[0]['request']['url'], '{{base_url}}/trips/current');
      expect(items[1]['request']['url'], '{{base_url}}/trips/{{trip_id}}/live');
      expect(
        items[2]['request']['url'],
        '{{base_url}}/trips/{{trip_id}}/cancel',
      );
      expect(items[2]['request'].containsKey('body'), isFalse);
      for (var i = 0; i < items.length; i++) {
        for (final saved in items[i]['response']) {
          final payload = jsonDecode(saved['body']) as Map<String, dynamic>;
          if (saved['code'] >= 400) {
            final failure = ActiveTripCodec.failure(payload);
            expect(
              payload,
              activeExample(
                'error-${failure.code.toLowerCase().replaceAll('_', '-')}',
              ),
            );
          } else {
            final trip = ActiveTripCodec.response(payload, allowEmpty: i == 0);
            if (trip != null) expect(trip.live!.revision, greaterThan(0));
          }
        }
      }
    },
  );
}
