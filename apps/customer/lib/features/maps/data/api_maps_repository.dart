import 'package:dio/dio.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import '../domain/maps_repository.dart';
import 'maps_codec.dart';

final class ApiMapsRepository implements MapsRepository {
  const ApiMapsRepository(this.client);
  final Dio client;
  Future<T> _read<T>(
    Future<Response<dynamic>> Function() request,
    T Function(Object?) decode, {
    String notFoundCode = 'LOCATION_NOT_FOUND',
  }) async {
    try {
      return decode((await request()).data);
    } on DioException catch (error) {
      final code = switch (error.response?.statusCode) {
        404 => notFoundCode,
        422 => 'VALIDATION_ERROR',
        429 => 'RATE_LIMITED',
        _ => 'SERVICE_UNAVAILABLE',
      };
      throw MapsFailure(code);
    } on MapsFailure {
      rethrow;
    } catch (_) {
      throw const MapsFailure('INVALID_RESPONSE');
    }
  }

  @override
  Future<List<TripLocation>> search(String query, {required String language}) {
    final q = query.trim();
    if (q.runes.length > 100 || !{'ar', 'en'}.contains(language)) {
      throw const MapsFailure('VALIDATION_ERROR');
    }
    return _read(
      () => client.get(
        'places',
        queryParameters: {'q': q, 'limit': 20},
        options: Options(headers: {'Accept-Language': language}),
      ),
      (raw) {
        final list = MapsCodec.data(raw);
        if (list is! List || list.length > 20) {
          throw const FormatException('Places');
        }
        return List.unmodifiable(
          list.map((v) => MapsCodec.location(v, language)),
        );
      },
    );
  }

  @override
  Future<TripLocation> reverse(GeoPoint point, {required String language}) =>
      _read(
        () => client.get(
          'map/reverse',
          queryParameters: MapsCodec.point(point),
          options: Options(headers: {'Accept-Language': language}),
        ),
        (raw) {
          final result = MapsCodec.location(MapsCodec.data(raw), language);
          if (MapsCodec.meters(point, result.point) > 200) {
            throw const FormatException('Reverse point');
          }
          // Preserve the user's pin, not the geocoder's snapped point.
          return TripLocation(label: result.label, point: point);
        },
      );
  @override
  Future<MapRoute> route(GeoPoint origin, GeoPoint destination) {
    if (origin == destination) throw const MapsFailure('VALIDATION_ERROR');
    return _read(
      () => client.post(
        'map/routes',
        data: {
          'origin': MapsCodec.point(origin),
          'destination': MapsCodec.point(destination),
        },
      ),
      (raw) => MapsCodec.route(raw, origin, destination),
      notFoundCode: 'ROUTE_NOT_FOUND',
    );
  }
}

final class UnconfiguredMapsRepository implements MapsRepository {
  const UnconfiguredMapsRepository();
  Never _fail() => throw const MapsFailure('MAP_NOT_CONFIGURED');
  @override
  Future<List<TripLocation>> search(
    String query, {
    required String language,
  }) async => _fail();
  @override
  Future<TripLocation> reverse(
    GeoPoint point, {
    required String language,
  }) async => _fail();
  @override
  Future<MapRoute> route(GeoPoint origin, GeoPoint destination) async =>
      _fail();
}
