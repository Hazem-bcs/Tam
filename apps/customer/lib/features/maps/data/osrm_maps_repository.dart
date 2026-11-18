import 'dart:async';

import 'package:dio/dio.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';

import '../domain/maps_repository.dart';
import 'osrm_route_codec.dart';

/// Explicit OSRM routing only; search/reverse retain their configured provider.
/// One application-owned queue respects the public demo's 1 request/s policy.
final class OsrmMapsRepository implements MapsRepository {
  OsrmMapsRepository(this.client, {required this.places});
  final Dio client;
  final MapsRepository places;
  final _clock = Stopwatch()..start();
  final _cache = <(GeoPoint, GeoPoint), (int, MapRoute)>{};
  final _pending = <(GeoPoint, GeoPoint), Future<MapRoute>>{};
  Future<void> _tail = Future.value();
  CancelToken _cancel = CancelToken();
  int _nextSlot = 0, _epoch = 0;
  bool _disposed = false;

  @override
  Future<List<TripLocation>> search(String query, {required String language}) =>
      places.search(query, language: language);
  @override
  Future<TripLocation> reverse(GeoPoint point, {required String language}) =>
      places.reverse(point, language: language);

  @override
  Future<MapRoute> route(GeoPoint origin, GeoPoint destination) {
    if (_disposed) {
      return Future.error(const MapsFailure('SERVICE_UNAVAILABLE'));
    }
    if (origin == destination) {
      return Future.error(const MapsFailure('VALIDATION_ERROR'));
    }
    final key = (origin, destination);
    final cached = _cache[key];
    if (cached != null && _clock.elapsedMilliseconds - cached.$1 < 300000) {
      return Future.value(cached.$2);
    }
    final pending = _pending[key];
    if (pending != null) return pending;
    final epoch = _epoch;
    final result = _tail.then((_) => _request(origin, destination, epoch));
    final tracked = result
        .then((route) {
          if (epoch == _epoch && !_disposed) {
            if (_cache.length >= 32) _cache.remove(_cache.keys.first);
            _cache[key] = (_clock.elapsedMilliseconds, route);
          }
          return route;
        })
        .whenComplete(() {
          if (epoch == _epoch) _pending.remove(key);
        });
    _pending[key] = tracked;
    // Errors belong to the caller; they must not poison the serialized queue.
    _tail = tracked.then<void>((_) {}, onError: (Object _) {});
    return tracked;
  }

  Future<MapRoute> _request(GeoPoint a, GeoPoint b, int epoch) async {
    void checkSession() {
      if (_disposed || epoch != _epoch) {
        throw const MapsFailure('SERVICE_UNAVAILABLE');
      }
    }

    checkSession();
    final wait = _nextSlot - _clock.elapsedMilliseconds;
    if (wait > 0) await Future<void>.delayed(Duration(milliseconds: wait));
    checkSession();
    _nextSlot = _clock.elapsedMilliseconds + 1100;
    try {
      final response = await client.get<Object?>(
        'route/v1/driving/${a.longitude},${a.latitude};${b.longitude},${b.latitude}',
        queryParameters: const {
          'overview': 'full',
          'geometries': 'geojson',
          'steps': 'false',
          'alternatives': 'false',
          'generate_hints': 'false',
          'radiuses': '100;100',
        },
        cancelToken: _cancel,
      );
      checkSession();
      return OsrmRouteCodec.decode(response.data, a, b);
    } on DioException catch (error) {
      if (error.response?.data case final Map data
          when data['code'] == 'NoRoute' || data['code'] == 'NoSegment') {
        throw const MapsFailure('ROUTE_NOT_FOUND');
      }
      throw MapsFailure(
        error.response?.statusCode == 429
            ? 'RATE_LIMITED'
            : 'SERVICE_UNAVAILABLE',
      );
    } on MapsFailure {
      rethrow;
    } catch (_) {
      throw const MapsFailure('INVALID_RESPONSE');
    }
  }

  void clearSession() {
    _epoch++;
    _cancel.cancel();
    _cancel = CancelToken();
    _cache.clear();
    _pending.clear();
  }

  void dispose() {
    _disposed = true;
    clearSession();
    client.close(force: true);
  }
}
