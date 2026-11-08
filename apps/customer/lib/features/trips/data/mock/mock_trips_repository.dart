import 'dart:convert';

import 'package:tam_customer/features/trips/domain/trips_repository.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// Read-only projections over the shared, injected booking store.
/// This class owns no independent runtime trip list.
final class MockTripsRepository implements TripsRepository {
  const MockTripsRepository(this._store);

  final MockTripStore _store;

  @override
  Stream<void> get changes => _store.changes.map((_) {});

  @override
  Future<TripsPage> list({
    TripsFilter filter = TripsFilter.all,
    String? cursor,
    int limit = 20,
  }) async {
    if (limit < 1 || limit > 50) throw const TripsFailure('VALIDATION_ERROR');
    final anchor = cursor == null ? null : _decodeCursor(cursor);
    final matches = _store.trips
        .where((trip) {
          if (!filter.includes(trip)) return false;
          if (anchor == null) return true;
          final compared = trip.createdAt
              .toUtc()
              .microsecondsSinceEpoch
              .compareTo(anchor.$1);
          return compared < 0 ||
              (compared == 0 && trip.id.compareTo(anchor.$2) > 0);
        })
        .toList(growable: false);
    final takeCount = matches.length < limit ? matches.length : limit;
    final items = List<Trip>.unmodifiable(matches.take(takeCount));
    return TripsPage(
      items: items,
      nextCursor: matches.length > takeCount && items.isNotEmpty
          ? _encodeCursor(items.last)
          : null,
    );
  }

  @override
  Future<Trip?> find(String tripId) async => _store.find(tripId);

  @override
  Future<Trip> cancel(String tripId) async {
    try {
      return _store.cancel(tripId);
    } on MockTripStoreFailure catch (failure) {
      throw TripsFailure(failure.code);
    }
  }

  static String _encodeCursor(Trip trip) => base64Url.encode(
    utf8.encode(
      jsonEncode([trip.createdAt.toUtc().microsecondsSinceEpoch, trip.id]),
    ),
  );

  static (int, String) _decodeCursor(String encoded) {
    try {
      final parsed = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(encoded))),
      );
      if (parsed is! List ||
          parsed.length != 2 ||
          parsed[0] is! int ||
          parsed[1] is! String ||
          (parsed[1] as String).isEmpty) {
        throw const FormatException('Invalid cursor');
      }
      return (parsed[0] as int, parsed[1] as String);
    } catch (_) {
      throw const TripsFailure('VALIDATION_ERROR');
    }
  }
}
