import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/core/config/map_configuration.dart';
import 'package:tam_customer/features/maps/data/osrm_maps_repository.dart';
import 'package:tam_customer/features/maps/data/osrm_route_codec.dart';
import 'package:tam_customer/features/maps/domain/maps_repository.dart';
import 'package:tam_customer/features/maps/maps_dependencies.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';

import 'maps_api_test.dart' show Adapter;
import 'maps_test_support.dart';

Map<String, Object> osrmBody() => {
  'code': 'Ok',
  'routes': [
    {
      'distance': 5019.4,
      'duration': 1080.6,
      'geometry': {
        'type': 'LineString',
        'coordinates': [
          [36.25, 33.5],
          [36.27, 33.51],
          [36.283, 33.519],
        ],
      },
    },
  ],
};
void main() {
  late MapsDependencies deps;
  setUp(() {
    deps = MapsDependencies.configured(
      const MapConfiguration(osrmBaseUrl: 'https://osrm.invalid'),
    );
  });
  tearDown(() => deps.dispose());

  test(
    'isolated OSRM GET, GeoJSON order, snap preserved, shared cache and no place fallback',
    () async {
      var calls = 0;
      deps.osrm!.client.httpClientAdapter = Adapter((request) {
        calls++;
        expect(request.method, 'GET');
        expect(request.path, 'route/v1/driving/36.25,33.5;36.283,33.519');
        expect(request.queryParameters['overview'], 'full');
        expect(request.queryParameters['geometries'], 'geojson');
        expect(request.queryParameters['radiuses'], '100;100');
        expect(
          request.headers.keys.any((k) => k.toLowerCase() == 'authorization'),
          isFalse,
        );
        expect(request.followRedirects, isFalse);
        final body = osrmBody();
        final route = (body['routes'] as List).first as Map;
        ((route['geometry'] as Map)['coordinates'] as List)[0] = [
          36.2501,
          33.5,
        ];
        return ResponseBody.fromString(
          jsonEncode(body),
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      });
      final routes = await Future.wait([
        deps.repository.route(origin, destination),
        deps.repository.route(origin, destination),
      ]);
      final route = routes.first;
      expect(calls, 1);
      expect(route.origin, origin);
      expect(route.points.first.longitude, 36.2501); // No off-road connector.
      expect(route.points.last, destination);
      expect(route.roadAligned, isTrue);
      expect(route.durationSeconds, 1081);
      expect(
        identical(await deps.repository.route(origin, destination), route),
        isTrue,
      );
      await expectLater(
        deps.repository.search('x', language: 'ar'),
        throwsA(isA<MapsFailure>()),
      );
      expect(calls, 1);
    },
  );

  for (final code in ['NoRoute', 'NoSegment']) {
    test('$code remains an explicit route failure', () async {
      deps.osrm!.client.httpClientAdapter = Adapter(
        (_) => ResponseBody.fromString(
          jsonEncode({'code': code}),
          400,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        ),
      );
      await expectLater(
        deps.repository.route(origin, destination),
        throwsA(
          isA<MapsFailure>().having((f) => f.code, 'code', 'ROUTE_NOT_FOUND'),
        ),
      );
    });
  }
  test(
    'malformed/far snapped geometry rejected without fake success',
    () async {
      final body = osrmBody();
      final route = (body['routes'] as List).first as Map;
      (route['geometry'] as Map)['coordinates'] = [
        [0, 0],
        [36.283, 33.519],
      ];
      deps.osrm!.client.httpClientAdapter = Adapter(
        (_) => ResponseBody.fromString(
          jsonEncode(body),
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        ),
      );
      await expectLater(
        deps.repository.route(origin, destination),
        throwsA(
          isA<MapsFailure>().having((f) => f.code, 'code', 'INVALID_RESPONSE'),
        ),
      );
    },
  );
  test(
    'serialized distinct requests respect demo rate and session clear invalidates cache',
    () async {
      final times = <DateTime>[];
      deps.osrm!.client.httpClientAdapter = Adapter((request) {
        times.add(DateTime.now());
        final coordinates = request.path
            .split('/')
            .last
            .split(';')
            .map((c) => c.split(',').map(double.parse).toList())
            .toList();
        return ResponseBody.fromString(
          jsonEncode({
            'code': 'Ok',
            'routes': [
              {
                'distance': 10,
                'duration': 2,
                'geometry': {'type': 'LineString', 'coordinates': coordinates},
              },
            ],
          }),
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      });
      await Future.wait([
        deps.repository.route(origin, destination),
        deps.repository.route(destination, origin),
      ]);
      expect(
        times[1].difference(times[0]).inMilliseconds,
        greaterThanOrEqualTo(1000),
      );
      deps.clearRoutingSession();
      await deps.repository.route(origin, destination);
      expect(times, hasLength(3));
    },
  );
  test('OSRM endpoint has the same TLS and credential restrictions', () {
    expect(
      () => MapConfiguration.parse(
        tileUrl: '',
        apiBaseUrl: '',
        osrmBaseUrl: 'https://u:p@osrm.invalid',
      ),
      throwsArgumentError,
    );
    expect(
      () => MapConfiguration.parse(
        tileUrl: '',
        apiBaseUrl: '',
        osrmBaseUrl: 'http://osrm.invalid',
      ),
      throwsArgumentError,
    );
  });
  test('in-flight result cannot survive session reset', () async {
    final places = MapsProbe();
    final client = Dio(BaseOptions(baseUrl: 'https://osrm.invalid/'));
    final repo = OsrmMapsRepository(client, places: places);
    addTearDown(repo.dispose);
    client.httpClientAdapter = Adapter((_) {
      repo.clearSession();
      return ResponseBody.fromString(
        jsonEncode(osrmBody()),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    });
    await expectLater(
      repo.route(origin, destination),
      throwsA(isA<MapsFailure>()),
    );
    expect(places.routes, 0);
  });
  test(
    'nonfinite coordinates and expired route failure are not cached',
    () async {
      var calls = 0;
      deps.osrm!.client.httpClientAdapter = Adapter((_) {
        calls++;
        return ResponseBody.fromString(
          calls == 1 ? '{}' : jsonEncode(osrmBody()),
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      });
      await expectLater(
        deps.repository.route(origin, destination),
        throwsA(isA<MapsFailure>()),
      );
      expect(
        (await deps.repository.route(origin, destination)).provider,
        'osrm',
      );
      expect(calls, 2);
      expect(
        () => GeoPoint(latitude: double.nan, longitude: 0),
        throwsArgumentError,
      );
    },
  );
  test(
    'saved Damascus fixture and importable Postman response describe the same road route',
    () {
      final raw = jsonDecode(
        File(
          '../../docs/api/maps/osrm/examples/route-damascus.json',
        ).readAsStringSync(),
      );
      final route = OsrmRouteCodec.decode(
        raw,
        GeoPoint(latitude: 33.5138, longitude: 36.2765),
        GeoPoint(latitude: 33.516, longitude: 36.288),
      );
      expect(route.points.length, greaterThan(2));
      expect(route.distanceMeters, greaterThan(1000));
      final postman = jsonDecode(
        File(
          '../../docs/api/maps/osrm/osrm-v1.postman_collection.json',
        ).readAsStringSync(),
      );
      expect(postman['info']['schema'], contains('/v2.1.0/'));
      expect(postman['auth']['type'], 'noauth');
      expect(jsonDecode(postman['item'][0]['response'][0]['body']), raw);
    },
  );
}
