import 'dart:convert';

import 'package:tam_customer/core/cache/local_cache_store.dart';
import 'package:tam_customer/shared/data/trip_wire_codec.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// Local development snapshots, never credentials or an offline booking queue.
/// One owner per installation; changing owner discards the previous snapshot.
final class MockTripSnapshotStore {
  MockTripSnapshotStore(this._cache);
  final LocalCacheStore _cache;
  static const _key = 'mock-trip-snapshot-v1';
  Future<void> _pending = Future.value();

  Future<T> _serial<T>(Future<T> Function() operation) {
    final result = _pending.then((_) => operation());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<List<Trip>> restore(String owner) => _serial(() async {
    final cached = await _cache.read(_key);
    if (cached == null) return const [];
    try {
      final json = jsonDecode(cached.value) as Map<String, dynamic>;
      if (json['version'] != 1 || json['owner'] != owner) {
        await _cache.remove(_key);
        return const [];
      }
      final trips = (json['trips'] as List)
          .map((value) => TripWireCodec.fromJson(value as Map<String, dynamic>))
          .toList();
      if (trips.map((trip) => trip.id).toSet().length != trips.length) {
        throw const FormatException('Duplicate trip');
      }
      return trips;
    } on FormatException {
      await _cache.remove(_key);
      return const [];
    } on TypeError {
      await _cache.remove(_key);
      return const [];
    }
  });

  Future<bool> save(String owner, Iterable<Trip> trips, DateTime now) {
    final payload = jsonEncode({
      'version': 1,
      'owner': owner,
      'trips': trips.map(TripWireCodec.toJson).toList(),
    });
    return _serial(() async {
      try {
        await _cache.write(_key, payload, now);
        return true;
      } catch (_) {
        return false;
      }
    });
  }

  Future<void> clear() => _serial(() => _cache.remove(_key));
}
