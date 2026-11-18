import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/active_trip/data/active_trip_codec.dart';
import 'package:tam_customer/shared/data/trip_live_codec.dart';
import 'package:tam_customer/shared/data/trip_wire_codec.dart';
import 'package:tam_customer/shared/domain/geo_path.dart';

import 'active_trip_contract_test.dart' show activeExample;
import 'active_trip_test_support.dart';

void main() {
  test(
    'tracking geometry/bearing roundtrip with optional legacy compatibility',
    () {
      final raw = activeExample('live-en-route');
      final trip = ActiveTripCodec.response(raw)!;
      expect(trip.live!.route!.points.length, greaterThan(2));
      expect(trip.live!.position!.bearing, isNotNull);
      expect(TripWireCodec.fromJson(TripWireCodec.toJson(trip)), trip);
      final legacy = activeExample('live-en-route');
      legacy['data']['live'].remove('route');
      legacy['data']['live']['position'].remove('bearing');
      expect(ActiveTripCodec.response(legacy)!.live!.route, isNull);
    },
  );
  test(
    'malformed coordinates, heading, and wrong leg cannot enter tracking',
    () {
      for (final mutate in <void Function(Map<String, dynamic>)>[
        (raw) => raw['data']['live']['position']['bearing'] = 360,
        (raw) => raw['data']['live']['route']['leg'] = 'to_destination',
        (raw) => raw['data']['live']['route']['coordinates'] = [
          [999, 33],
          [36, 34],
        ],
        (raw) => raw['data']['live']['route']['coordinates'] = [],
      ]) {
        final raw = activeExample('live-en-route');
        mutate(raw);
        expect(() => ActiveTripCodec.response(raw), throwsFormatException);
      }
      expect(
        () => TripLiveCodec.routeFromJson({
          'id': 'bad',
          'leg': 'x',
          'coordinates': [
            [36, 33],
            [36, 34],
          ],
        }),
        throwsFormatException,
      );
    },
  );
  test(
    'mock packets pass the same codec and phase checks as server snapshots',
    () async {
      final fixture = ActiveTripFixture();
      addTearDown(fixture.dispose);
      final id = fixture.book().id;
      for (final seconds in [0, 2, 3, 4, 5, 7, 9]) {
        fixture.now = DateTime.utc(
          2026,
          11,
          9,
          12,
        ).add(Duration(seconds: seconds));
        final snapshot = (await fixture.repository.fetch(id))!;
        final received = ActiveTripCodec.response({
          'data': TripWireCodec.toJson(snapshot),
        })!;
        final live = received.live!;
        if (live.position != null) {
          expect(live.position!.bearing, inInclusiveRange(0, 360));
          expect(
            GeoPath(live.route!.points).project(live.position!.point).error,
            lessThan(.1),
          );
        }
      }
    },
  );
}
