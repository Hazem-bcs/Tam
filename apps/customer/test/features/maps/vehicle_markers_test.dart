import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/core/config/map_configuration.dart';
import 'package:tam_customer/features/maps/presentation/widgets/raster_map_canvas.dart';
import 'package:tam_customer/features/maps/presentation/widgets/vector/vector_map_scene.dart';
import 'package:tam_customer/features/maps/presentation/widgets/vector/vector_marker_images.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/presentation/vehicle_marker_kind.dart';
import 'package:tam_customer/shared/widgets/tam_vehicle_icon.dart';

import 'maps_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'booking classes select the matching road silhouette, including future car classes',
    () {
      expect(
        VehicleMarkerKind.fromClassId('motorbike'),
        VehicleMarkerKind.motorbike,
      );
      expect(VehicleMarkerKind.fromClassId('van'), VehicleMarkerKind.van);
      for (final id in ['standard', 'comfort', 'luxury', 'unknown', null]) {
        expect(VehicleMarkerKind.fromClassId(id), VehicleMarkerKind.car);
      }
    },
  );
  test(
    'SVG assets rasterize and the device-location update retains the vehicle',
    () async {
      final rendered = <List<int>>[];
      const preview = String.fromEnvironment('VEHICLE_MARKER_PREVIEW_DIR');
      for (final kind in VehicleMarkerKind.values) {
        final bytes = await VectorMarkerImages.load(
          kind.asset,
          AppTheme.light.colorScheme.primary,
        );
        expect(bytes.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
        expect(bytes.length, greaterThan(100));
        rendered.add(bytes);
        if (preview.isNotEmpty) {
          await Directory(preview).create(recursive: true);
          await File('$preview/${kind.name}.png').writeAsBytes(bytes);
        }
        final scene = VectorMapScene(
          driver: origin,
          driverVehicle: kind,
          driverBearing: 270,
        ).withDeviceLocation(destination);
        final feature = (scene.toGeoJson()['features'] as List).first;
        expect(feature['properties']['vehicle_icon'], kind.spriteId);
        expect(feature['properties']['bearing'], 270);
      }
      expect(rendered[0], isNot(rendered[1]));
      expect(rendered[1], isNot(rendered[2]));
    },
  );
  testWidgets(
    'raster marker uses selected vehicle and retains its map on type change',
    (tester) async {
      Future<void> show(VehicleMarkerKind kind) => tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: RasterMapCanvas(
              configuration: const MapConfiguration(),
              driver: origin,
              driverVehicle: kind,
              driverBearing: 90,
            ),
          ),
        ),
      );
      await show(VehicleMarkerKind.motorbike);
      await tester.pumpAndSettle();
      final map = tester.element(find.byType(FlutterMap));
      expect(
        tester.widget<TamVehicleIcon>(find.byType(TamVehicleIcon)).kind,
        VehicleMarkerKind.motorbike,
      );
      await show(VehicleMarkerKind.van);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TamVehicleIcon>(find.byType(TamVehicleIcon)).kind,
        VehicleMarkerKind.van,
      );
      expect(identical(map, tester.element(find.byType(FlutterMap))), isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}
