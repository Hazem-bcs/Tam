import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_colors.dart';
import 'package:tam_customer/core/config/app_config.dart';
import 'package:tam_customer/core/config/map_configuration.dart';
import 'package:tam_customer/features/maps/presentation/widgets/vector/vector_camera.dart';
import 'package:tam_customer/features/maps/presentation/widgets/vector/vector_map_scene.dart';
import 'package:tam_customer/features/maps/presentation/widgets/vector/vector_map_style.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';

import 'maps_test_support.dart';

void main() {
  final template = File('assets/maps/liberty.json').readAsStringSync();
  final original = jsonDecode(template) as Map<String, dynamic>;
  Map<String, dynamic> styled(String language, {bool dark = false}) =>
      jsonDecode(
            VectorMapStyle.build(
              template,
              dark ? AppColors.mapDark : AppColors.mapLight,
              language,
            ),
          )
          as Map<String, dynamic>;

  test(
    'preview selects vector explicitly, offline configuration remains offline',
    () {
      expect(AppConfig.maps.hasVectorStyle, isTrue);
      expect(AppConfig.maps.tileUrl, isEmpty);
      expect(const MapConfiguration().hasVectorStyle, isFalse);
      expect(
        () => MapConfiguration.parse(
          tileUrl: '',
          apiBaseUrl: '',
          vectorStyleAsset: 'assets/maps/../secret.json',
        ),
        throwsArgumentError,
      );
    },
  );

  test(
    'styling preserves live sources, fonts, symbols and attribution metadata',
    () {
      final result = styled('ar');
      for (final key in ['sources', 'glyphs', 'sprite']) {
        expect(result[key], original[key]);
      }
      final layers = result['layers'] as List;
      expect(layers.length, (original['layers'] as List).length);
      expect(layers.any((l) => l['source-layer'] == 'building'), isTrue);
      expect(layers.any((l) => l['source-layer'] == 'poi'), isTrue);
      expect(jsonEncode(layers), isNot(contains('tile.openstreetmap.org')));
    },
  );

  test('localization prefers the chosen language and keeps fallback names', () {
    for (final language in ['ar', 'en']) {
      final layer = (styled(language)['layers'] as List).firstWhere(
        (l) =>
            l['source-layer'] == 'transportation_name' &&
            (l['layout'] as Map?)?['text-field'] is List,
      );
      final text = layer['layout']['text-field'] as List;
      expect(text[1], [
        '!=',
        [
          'coalesce',
          ['get', 'name:$language'],
          '',
        ],
        '',
      ]);
      expect(jsonEncode(text), contains('name'));
    }
  });

  test(
    'light and dark are themed per layer, without recoloring POI sprites',
    () {
      final light = styled('ar');
      final dark = styled('ar', dark: true);
      final l = (light['layers'] as List).firstWhere(
        (v) => v['type'] == 'background',
      );
      final d = (dark['layers'] as List).firstWhere(
        (v) => v['type'] == 'background',
      );
      expect(
        l['paint']['background-color'],
        isNot(d['paint']['background-color']),
      );
      final poi = (light['layers'] as List).firstWhere(
        (v) => v['id'] == 'poi_r20',
      );
      expect(poi['minzoom'], greaterThanOrEqualTo(18));
      expect(poi['layout']['icon-image'], isNotNull);
    },
  );

  test('automatic camera fits the sheet, nearby points and the dateline', () {
    const size = Size(390, 844);
    expect(VectorCamera.position(const VectorMapScene(), size, 0), isNull);
    final nearby = VectorMapScene(
      origin: origin,
      destination: GeoPoint(
        latitude: origin.latitude + .0001,
        longitude: origin.longitude + .0001,
      ),
    );
    expect(VectorCamera.position(nearby, size, 400)!.zoom, 16);
    final wide = VectorMapScene(origin: origin, destination: destination);
    expect(
      VectorCamera.position(wide, size, 400)!.zoom,
      lessThanOrEqualTo(VectorCamera.position(wide, size, 0)!.zoom),
    );
    final dateline = VectorMapScene(
      origin: GeoPoint(latitude: 0, longitude: 179.9),
      destination: GeoPoint(latitude: 0, longitude: -179.9),
    );
    expect(
      VectorCamera.position(dateline, size, 0)!.target.longitude.abs(),
      closeTo(180, .001),
    );
  });

  test('compact map camera keeps endpoints visible at thumbnail size', () {
    const thumbnail = Size(145, 156);
    final scene = VectorMapScene(origin: origin, destination: destination);
    final fullMapPadding = VectorCamera.position(scene, thumbnail, 0)!.zoom;
    final thumbnailPadding = VectorCamera.position(
      scene,
      thumbnail,
      0,
      compactPreview: true,
    )!.zoom;
    expect(thumbnailPadding, greaterThan(fullMapPadding));
    expect(thumbnailPadding, lessThanOrEqualTo(16));
  });

  test('invalid styles fail explicitly', () {
    expect(
      () => VectorMapStyle.build('{}', AppColors.mapLight, 'ar'),
      throwsFormatException,
    );
  });

  test(
    'scene retains longitude latitude order, endpoints and the road geometry',
    () {
      final scene = VectorMapScene(
        origin: origin,
        destination: destination,
        driver: origin,
        selection: destination,
      );
      final features = scene.toGeoJson()['features'] as List;
      expect(features, hasLength(4));
      expect(features.first['geometry']['coordinates'], [
        origin.longitude,
        origin.latitude,
      ]);
      expect(
        VectorMapScene.coordinate(GeoPoint(latitude: 90, longitude: 180)),
        [180, 85.0511],
      );
      expect(scene.bounds, [origin, destination]);
      expect(const VectorMapScene().toGeoJson()['features'], isEmpty);
    },
  );
}
