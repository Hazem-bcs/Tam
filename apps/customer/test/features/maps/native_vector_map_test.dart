import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/maps/domain/maps_repository.dart'
    as domain;
import 'package:tam_customer/features/maps/presentation/widgets/map_camera_focus.dart';
import 'package:tam_customer/features/maps/presentation/widgets/vector/native_vector_map.dart';
import 'package:tam_customer/features/maps/presentation/widgets/vector/vector_map_scene.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/presentation/vehicle_marker_kind.dart';

import 'maps_test_support.dart';
import 'support/vector_platform_probe.dart';

void main() {
  final platforms = <VectorPlatformProbe>[];
  setUp(() {
    final previous = MapLibrePlatform.createInstance;
    addTearDown(() => MapLibrePlatform.createInstance = previous);
    platforms.clear();
    MapLibrePlatform.createInstance = () {
      final probe = VectorPlatformProbe();
      platforms.add(probe);
      return probe;
    };
  });
  Future<void> show(
    WidgetTester tester,
    VectorMapScene scene, {
    ValueNotifier<double>? inset,
    ValueChanged<GeoPoint>? select,
    MapCameraFocus? focus,
    bool followDriver = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: NativeVectorMap(
            style: '{"version":8,"sources":{},"layers":[]}',
            initialCenter: origin,
            scene: scene,
            followDriver: followDriver,
            markerImageLoader: (_, _) async => Uint8List(8),
            bottomInset: inset,
            onSelected: select,
            focus: focus,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> load(WidgetTester tester) async {
    await tester.pump();
    tester
        .widget<MapLibreMap>(find.byType(MapLibreMap))
        .onStyleLoadedCallback!();
    await tester.pump();
    expect(platforms.last.installed.isCompleted, isTrue);
    tester.widget<MapLibreMap>(find.byType(MapLibreMap)).onMapIdle!();
    await tester.pump();
  }

  testWidgets(
    'vehicle sprite changes without recreating the map or resetting its camera',
    (tester) async {
      await show(
        tester,
        VectorMapScene(
          origin: origin,
          driver: origin,
          driverVehicle: VehicleMarkerKind.motorbike,
        ),
      );
      await load(tester);
      await tester.pumpAndSettle();
      final map = tester.element(find.byType(MapLibreMap));
      final probe = platforms.single;
      final cameraCount = probe.cameras.length;
      expect(probe.imageNames.toSet(), {
        'tam-car',
        'tam-van',
        'tam-motorbike',
        'tam-pin',
      });
      expect(probe.symbolLayers['tam-driver']!['icon-image'], [
        'get',
        'vehicle_icon',
      ]);
      for (final kind in [
        VehicleMarkerKind.van,
        VehicleMarkerKind.car,
        VehicleMarkerKind.motorbike,
      ]) {
        await show(
          tester,
          VectorMapScene(
            origin: origin,
            driver: origin,
            driverBearing: 135,
            driverVehicle: kind,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          identical(map, tester.element(find.byType(MapLibreMap))),
          isTrue,
        );
        final driver = (probe.scenes.last['features'] as List).single;
        expect(driver['properties']['vehicle_icon'], kind.spriteId);
        expect(driver['properties']['bearing'], 135);
        expect(probe.images, 4);
        expect(probe.cameras.length, cameraCount);
      }
    },
  );

  testWidgets(
    'confirming a selected endpoint preserves viewport through route updates',
    (tester) async {
      final inset = ValueNotifier<double>(280);
      addTearDown(inset.dispose);
      await show(
        tester,
        VectorMapScene(origin: origin, selection: destination),
        inset: inset,
        select: (_) {},
      );
      await load(tester);
      await tester.pumpAndSettle();
      final map = tester.element(find.byType(MapLibreMap));
      final probe = platforms.single;
      final cameras = probe.cameras.length;
      final padding = probe.insets.length;
      await show(
        tester,
        VectorMapScene(origin: origin, destination: destination),
        inset: inset,
        select: (_) {},
      );
      inset.value = 210;
      await tester.pumpAndSettle();
      await show(
        tester,
        VectorMapScene(
          origin: origin,
          destination: destination,
          route: domain.MapRoute(
            origin: origin,
            destination: destination,
            points: [origin, destination],
            distanceMeters: 1200,
            durationSeconds: 240,
            provider: 'test',
          ),
        ),
        inset: inset,
        select: (_) {},
      );
      await tester.pumpAndSettle();
      expect(tester.element(find.byType(MapLibreMap)), same(map));
      expect(probe.cameras.length, cameras);
      expect(probe.insets.length, padding);
      expect(probe.scenes.last['features'], hasLength(3));
      await show(
        tester,
        VectorMapScene(origin: origin, destination: destination),
        inset: inset,
        focus: MapCameraFocus(origin, 1),
      );
      await tester.pumpAndSettle();
      expect(probe.cameras.length, greaterThan(cameras));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'follows driver automatically, pauses on drag and resumes explicitly',
    (tester) async {
      final inset = ValueNotifier<double>(200);
      addTearDown(inset.dispose);
      await show(
        tester,
        VectorMapScene(
          origin: origin,
          destination: destination,
          driver: origin,
        ),
        inset: inset,
        followDriver: true,
      );
      await load(tester);
      await tester.pumpAndSettle();
      final initial = platforms.single.cameras.length;
      expect(initial, greaterThan(0));
      final surface = find.byType(MapLibreMap);
      final start = tester.getCenter(surface);
      await tester.dragFrom(start, const Offset(60, 20));
      await tester.pump();
      final paused = platforms.single.cameras.length;
      await show(
        tester,
        VectorMapScene(
          origin: origin,
          destination: destination,
          driver: destination,
        ),
        inset: inset,
        followDriver: true,
      );
      await tester.pump(const Duration(milliseconds: 250));
      expect(platforms.single.cameras.length, paused);
      await tester.tap(find.byKey(const Key('map-follow-driver')));
      await tester.pumpAndSettle();
      expect(platforms.single.cameras.length, greaterThan(paused));
      expect(platforms, hasLength(1));
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('selection and driver updates preserve map, sprites and camera', (
    tester,
  ) async {
    GeoPoint? chosen;
    final inset = ValueNotifier<double>(200);
    addTearDown(inset.dispose);
    await show(
      tester,
      VectorMapScene(origin: origin, destination: destination),
      inset: inset,
      select: (p) => chosen = p,
    );
    await load(tester);
    final firstMap = tester.element(find.byType(MapLibreMap));
    final native = tester.widget<MapLibreMap>(find.byType(MapLibreMap));
    expect(native.myLocationEnabled, isFalse);
    expect(native.attributionButtonPosition, isNotNull);
    native.onMapClick!(const Point(20, 40), const LatLng(33.5, 36.3));
    expect(chosen?.latitude, closeTo(33.5, 1e-10));
    expect(chosen?.longitude, closeTo(36.3, 1e-10));
    final cameraCalls = platforms.single.cameras.length;
    await show(
      tester,
      VectorMapScene(
        origin: origin,
        destination: destination,
        driver: origin,
        driverBearing: 90,
      ),
      inset: inset,
    );
    await tester.pump();
    expect(
      identical(firstMap, tester.element(find.byType(MapLibreMap))),
      isTrue,
    );
    expect(platforms, hasLength(1));
    expect(platforms.single.images, 4);
    expect(platforms.single.cameras.length, cameraCalls);
    expect((platforms.single.scenes.last['features'] as List).length, 1);
    expect(
      (platforms.single.scenes.last['features'] as List)
          .single['properties']['bearing'],
      90,
    );
    final paddingCalls = platforms.single.insets.length;
    for (var i = 0; i < 30; i++) {
      inset.value = 200 + i.toDouble();
    }
    await tester.pump(const Duration(milliseconds: 100));
    expect(platforms.single.insets.length - paddingCalls, lessThanOrEqualTo(2));
    await tester.pumpWidget(const SizedBox.shrink());
    expect(platforms.single.disposed, 1);
    await tester.pump(const Duration(seconds: 30));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'panning a selected point updates once at idle and never recenters the next scene',
    (tester) async {
      final chosen = <GeoPoint>[];
      await show(
        tester,
        VectorMapScene(origin: origin, selection: destination),
        select: chosen.add,
      );
      await load(tester);
      final native = tester.widget<MapLibreMap>(find.byType(MapLibreMap));
      final gesture = await tester.startGesture(const Offset(300, 300));
      await gesture.moveBy(const Offset(50, 20));
      const position = CameraPosition(target: LatLng(33.52, 36.31), zoom: 15);
      native.onCameraMove!(position);
      expect(chosen, isEmpty);
      await gesture.up();
      native.onMapIdle!();
      await tester.pump();
      expect(chosen, hasLength(1));
      expect(chosen.single.latitude, closeTo(33.63, 1e-10));
      expect(chosen.single.longitude, closeTo(36.4, 1e-10));
      expect(platforms.single.lastInverseProjection, const Point(400.0, 300.0));
      final cameraCount = platforms.single.cameras.length;
      await show(
        tester,
        VectorMapScene(origin: origin, selection: chosen.single),
        select: chosen.add,
      );
      expect(platforms.single.cameras.length, cameraCount);
      native.onMapIdle!();
      expect(chosen, hasLength(1));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'tap and card folding keep the building and clicked point stationary',
    (tester) async {
      final inset = ValueNotifier<double>(200);
      addTearDown(inset.dispose);
      GeoPoint? chosen;
      await show(
        tester,
        VectorMapScene(origin: origin),
        inset: inset,
        select: (p) => chosen = p,
      );
      await load(tester);
      final probe = platforms.single;
      final cameras = probe.cameras.length, padding = probe.insets.length;
      final native = tester.widget<MapLibreMap>(find.byType(MapLibreMap));
      native.onMapClick!(const Point(200.0, 300.0), const LatLng(33.52, 36.31));
      await show(
        tester,
        VectorMapScene(origin: origin, selection: chosen),
        inset: inset,
        select: (p) => chosen = p,
      );
      for (var i = 0; i < 20; i++) {
        inset.value = 220 + i.toDouble();
      }
      await tester.pump(const Duration(milliseconds: 500));
      expect(chosen, GeoPoint(latitude: 33.52, longitude: 36.31));
      expect(probe.cameras.length, cameras);
      expect(probe.insets.length, padding);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'drag reads the geographic point under the tapped pin at Android density 3',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      GeoPoint? chosen;
      await show(
        tester,
        VectorMapScene(origin: origin),
        select: (p) => chosen = p,
      );
      await load(tester);
      final native = tester.widget<MapLibreMap>(find.byType(MapLibreMap));
      native.onMapClick!(
        const Point(900.0, 1200.0),
        const LatLng(33.52, 36.31),
      );
      await show(
        tester,
        VectorMapScene(origin: origin, selection: chosen),
        select: (p) => chosen = p,
      );
      final gesture = await tester.startGesture(const Offset(150, 200));
      await gesture.moveBy(const Offset(50, 20));
      await gesture.up();
      tester.widget<MapLibreMap>(find.byType(MapLibreMap)).onMapIdle!();
      await tester.pump();
      expect(
        platforms.single.lastInverseProjection,
        const Point(900.0, 1200.0),
      );
      expect(chosen?.latitude, closeTo(33.63, 1e-10));
      expect(chosen?.longitude, closeTo(36.4, 1e-10));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'My Location centers the same fix again without changing route endpoints',
    (tester) async {
      final scene = VectorMapScene(origin: origin, destination: destination);
      await show(tester, scene);
      await load(tester);
      final first = tester.element(find.byType(MapLibreMap));
      final probe = platforms.single;
      final initial = probe.cameras.length;
      await show(tester, scene, focus: MapCameraFocus(origin, 1));
      expect(probe.cameras.length, initial + 1);
      await show(tester, scene, focus: MapCameraFocus(origin, 1));
      expect(probe.cameras.length, initial + 1);
      await show(tester, scene, focus: MapCameraFocus(origin, 2));
      expect(probe.cameras.length, initial + 2);
      expect(tester.element(find.byType(MapLibreMap)), same(first));
      final features = probe.scenes.last['features'] as List;
      expect(
        features.where((f) => f['properties']['kind'] == 'device'),
        hasLength(1),
      );
      expect(
        features
            .where((f) => f['properties']['kind'] == 'destination')
            .single['geometry']['coordinates'],
        VectorMapScene.coordinate(destination),
      );
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('native failure is visible and retry recreates the failed view', (
    tester,
  ) async {
    await show(tester, VectorMapScene(origin: origin));
    await load(tester);
    platforms.single.failUpdates = true;
    await show(tester, VectorMapScene(origin: origin, driver: origin));
    await tester.pump();
    expect(
      find.text('تعذر تحميل الخريطة. تحقق من الاتصال وحاول مجددًا.'),
      findsOneWidget,
    );
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pump();
    expect(platforms, hasLength(2));
    expect(platforms.first.disposed, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(platforms.last.disposed, 1);
    expect(tester.takeException(), isNull);
  });
}
