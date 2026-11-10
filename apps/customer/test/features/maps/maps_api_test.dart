import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tam_customer/core/config/map_configuration.dart';
import 'package:tam_customer/features/maps/data/api_maps_repository.dart';
import 'package:tam_customer/features/maps/data/maps_codec.dart';
import 'package:tam_customer/features/maps/data/private_tile_provider.dart';
import 'package:tam_customer/features/maps/domain/maps_repository.dart';
import 'package:tam_customer/features/maps/maps_dependencies.dart';
import 'maps_test_support.dart';

class Adapter implements HttpClientAdapter {
  Adapter(this.respond);
  final ResponseBody Function(RequestOptions) respond;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancel,
  ) async => respond(options);
  @override
  void close({bool force = false}) {}
}

void main() {
  test('empty endpoints do not choose a public provider', () async {
    final d = MapsDependencies.configured(const MapConfiguration());
    addTearDown(d.dispose);
    expect(d.client, isNull);
    await expectLater(
      d.repository.route(origin, destination),
      throwsA(
        isA<MapsFailure>().having((e) => e.code, 'code', 'MAP_NOT_CONFIGURED'),
      ),
    );
  });
  test(
    'endpoints require TLS, XYZ, no credentials or query and explicit local HTTP',
    () {
      MapConfiguration.parse(
        tileUrl: 'https://maps.invalid/{z}/{x}/{y}.png',
        apiBaseUrl: 'https://api.invalid/api/v1',
      );
      for (final url in [
        'http://tiles.invalid/{z}/{x}/{y}.png',
        'https://u:p@tiles.invalid/{z}/{x}/{y}.png',
        'https://tiles.invalid/{z}/{x}.png',
        'https://tiles.invalid/{z}/{x}/{y}.png?token=secret',
        'https://tiles.invalid/{z}/{x}/{y}/{secret}',
      ]) {
        expect(
          () => MapConfiguration.parse(tileUrl: url, apiBaseUrl: ''),
          throwsArgumentError,
        );
      }
      expect(
        () => MapConfiguration.parse(
          tileUrl: 'http://10.0.2.2/{z}/{x}/{y}.png',
          apiBaseUrl: '',
        ),
        throwsArgumentError,
      );
      MapConfiguration.parse(
        tileUrl: 'http://10.0.2.2/{z}/{x}/{y}.png',
        apiBaseUrl: '',
        allowLocalHttp: true,
      );
    },
  );
  test('GeoJSON longitude latitude and immutable route', () {
    final r = MapsCodec.route(routeJson(), origin, destination);
    expect(r.points.first, origin);
    expect(r.points.last, destination);
    expect(r.points.length, 3);
    expect(() => r.points.clear(), throwsUnsupportedError);
  });
  for (final mutation in [
    'reverse',
    'unbound',
    'empty',
    'many',
    'metric',
    'provider',
    'envelope',
    'snap',
  ]) {
    test('invalid route $mutation rejected', () {
      final body = routeJson(), data = bodyMap(routeJson());
      body['data'] = data;
      final geo = data['geometry'] as Map<String, dynamic>;
      switch (mutation) {
        case 'reverse':
          geo['coordinates'] = [
            [33.5, 36.25],
            [33.519, 36.283],
          ];
        case 'unbound':
          data['origin'] = {'latitude': 33.6, 'longitude': 36.25};
        case 'empty':
          geo['coordinates'] = [];
        case 'many':
          geo['coordinates'] = List.filled(10001, [36.25, 33.5]);
        case 'metric':
          data['duration_seconds'] = 1.5;
        case 'provider':
          data['provider'] = 'unknown';
        case 'envelope':
          body['error'] = {};
        case 'snap':
          geo['coordinates'] = [
            [0, 0],
            [36.283, 33.519],
          ];
      }
      expect(
        () => MapsCodec.route(body, origin, destination),
        throwsFormatException,
      );
    });
  }
  test(
    'configured HTTP uses backend prefix, no Bearer, no redirects and exact coordinates',
    () async {
      final d = MapsDependencies.configured(
        const MapConfiguration(apiBaseUrl: 'https://tam.invalid/api/v1'),
      );
      addTearDown(d.dispose);
      d.client!.httpClientAdapter = Adapter((o) {
        expect(o.uri.toString(), 'https://tam.invalid/api/v1/map/routes');
        expect(o.method, 'POST');
        expect(o.followRedirects, isFalse);
        expect(
          o.headers.keys.any((h) => h.toLowerCase() == 'authorization'),
          isFalse,
        );
        expect(o.data, {
          'origin': {'latitude': 33.5, 'longitude': 36.25},
          'destination': {'latitude': 33.519, 'longitude': 36.283},
        });
        return ResponseBody.fromString(
          jsonEncode(routeJson()),
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      });
      expect((await d.repository.route(origin, destination)).points.length, 3);
    },
  );
  for (final status in [302, 404, 422, 429, 503]) {
    test('HTTP $status is not a successful route', () async {
      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://tam.invalid/api/v1/',
          followRedirects: false,
        ),
      );
      addTearDown(dio.close);
      dio.httpClientAdapter = Adapter(
        (_) => ResponseBody.fromString('{}', status),
      );
      await expectLater(
        ApiMapsRepository(dio).route(origin, destination),
        throwsA(
          isA<MapsFailure>().having((f) => f.code, 'code', switch (status) {
            404 => 'ROUTE_NOT_FOUND',
            422 => 'VALIDATION_ERROR',
            429 => 'RATE_LIMITED',
            _ => 'SERVICE_UNAVAILABLE',
          }),
        ),
      );
    });
  }
  test('reverse preserves pin and search selects language', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://tam.invalid/api/v1/'));
    addTearDown(dio.close);
    dio.httpClientAdapter = Adapter((o) {
      expect(o.headers['Accept-Language'], 'en');
      final place = {
        'id': 'place-1',
        'label': 'المكان',
        'label_en': 'Place',
        'latitude': 33.5,
        'longitude': 36.25,
      };
      return ResponseBody.fromString(
        jsonEncode({
          'data': o.path == 'places' ? [place] : place,
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    });
    final api = ApiMapsRepository(dio);
    expect((await api.reverse(origin, language: 'en')).point, origin);
    expect((await api.search('p', language: 'en')).single.label, 'Place');
  });
  test(
    'tile origin and credentials are isolated; redirects stay unfollowed',
    () async {
      var calls = 0;
      final c = PrivateTileClient(
        Uri.parse('https://tiles.tam.invalid'),
        client: MockClient((r) async {
          calls++;
          expect(r.followRedirects, isFalse);
          expect(
            r.headers.keys.any(
              (k) => {'authorization', 'cookie'}.contains(k.toLowerCase()),
            ),
            isFalse,
          );
          return http.Response(
            '',
            302,
            headers: {'location': 'https://other.invalid'},
          );
        }),
      );
      addTearDown(c.close);
      final r = http.Request(
        'GET',
        Uri.parse('https://tiles.tam.invalid/0/0/0.png'),
      )..headers.addAll({'Authorization': 'secret', 'Cookie': 'secret'});
      expect((await c.send(r)).statusCode, 302);
      await expectLater(
        c.get(Uri.parse('https://other.invalid/tile.png')),
        throwsA(isA<http.ClientException>()),
      );
      expect(calls, 1);
    },
  );
}

Map<String, dynamic> bodyMap(Map<String, dynamic> body) =>
    body['data'] as Map<String, dynamic>;
