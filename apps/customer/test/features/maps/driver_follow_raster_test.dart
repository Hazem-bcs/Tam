import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/core/config/map_configuration.dart';
import 'package:tam_customer/features/maps/domain/maps_repository.dart';
import 'package:tam_customer/features/maps/presentation/widgets/raster_map_canvas.dart';
import 'package:tam_customer/features/maps/presentation/widgets/tam_map_canvas.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';

void main() {
  final a = GeoPoint(latitude: 33.5, longitude: 36.3);
  final b = GeoPoint(latitude: 33.501, longitude: 36.301);
  Future<void> show(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('raster driver follow yields to gestures and can be resumed', (
    tester,
  ) async {
    Widget map(GeoPoint driver) => RasterMapCanvas(
      configuration: const MapConfiguration(),
      origin: a,
      destination: b,
      driver: driver,
      followDriver: true,
    );
    await show(tester, map(a));
    final surface = tester.widget<FlutterMap>(find.byType(FlutterMap));
    surface.options.onPositionChanged!(surface.mapController!.camera, true);
    await tester.pumpAndSettle();
    final paused = surface.mapController!.camera.center;
    await show(tester, map(b));
    expect(
      tester
          .widget<FlutterMap>(find.byType(FlutterMap))
          .mapController!
          .camera
          .center,
      paused,
    );
    await tester.tap(find.byKey(const Key('map-follow-driver')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FlutterMap>(find.byType(FlutterMap))
          .mapController!
          .camera
          .center,
      isNot(paused),
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('synthetic geometry is not rendered as a road route', (
    tester,
  ) async {
    MapRoute route(bool roadAligned) => MapRoute(
      origin: a,
      destination: b,
      points: [a, b],
      distanceMeters: 100,
      durationSeconds: 10,
      provider: 'fixture',
      roadAligned: roadAligned,
    );
    Widget map(bool aligned) => TamMapCanvas(
      configuration: const MapConfiguration(),
      route: route(aligned),
    );
    await show(tester, map(false));
    expect(find.byType(PolylineLayer), findsNothing);
    await show(tester, map(true));
    expect(find.byType(PolylineLayer), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
