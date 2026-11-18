import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/maps/presentation/widgets/driver_map_motion.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';

void main() {
  testWidgets(
    'moves along corners, rejects old samples, stops, and clears stale car',
    (tester) async {
      final a = GeoPoint(latitude: 0, longitude: 0),
          b = GeoPoint(latitude: .001, longitude: 0),
          c = GeoPoint(latitude: .001, longitude: .001);
      GeoPoint? drawn;
      final now = DateTime.utc(2026);
      Future<void> show(
        GeoPoint? point,
        int seconds, {
        bool reduced = false,
        String identity = 'trip',
      }) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: reduced),
              child: DriverMapMotion(
                point: point,
                recordedAt: now.add(Duration(seconds: seconds)),
                identity: identity,
                path: [a, b, c],
                builder: (p, h) {
                  drawn = p;
                  return const SizedBox();
                },
              ),
            ),
          ),
        );
      }

      await show(a, 0);
      await show(c, 4);
      await tester.pump(const Duration(seconds: 2));
      expect(drawn!.latitude, closeTo(.001, .00003));
      expect(drawn!.longitude, closeTo(0, .00003));
      await tester.pump(const Duration(seconds: 2));
      expect(drawn, c);
      await show(a, 1);
      expect(drawn, c);
      await tester.pump(const Duration(seconds: 15));
      expect(drawn, c);
      await show(null, 5);
      expect(drawn, isNull);
      await show(a, 6);
      await show(c, 7, reduced: true);
      expect(drawn, c);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
