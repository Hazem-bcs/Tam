import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/core/cache/local_cache_store.dart';
import 'package:tam_customer/features/active_trip/data/mock/mock_active_trip_repository.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_snapshot_store.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/trip.dart';

import 'mock_trip_store_test.dart' show booking;

class MemorySnapshots implements LocalCacheStore {
  final values = <String, CachedPayload>{};
  bool readFails = false, writeFails = false;
  Completer<void>? delay;
  @override
  Future<CachedPayload?> read(String key) async {
    await delay?.future;
    if (readFails) throw StateError('disk unavailable');
    return values[key];
  }

  @override
  Future<void> write(String key, String value, DateTime fetchedAt) async {
    if (writeFails) throw StateError('disk unavailable');
    values[key] = CachedPayload(value: value, fetchedAt: fetchedAt);
  }

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }

  @override
  Future<void> clear() async => values.clear();
}

void main() {
  test(
    'process restart restores same live booking, payment, coupon and driver',
    () async {
      final cache = MemorySnapshots();
      var now = DateTime.utc(2026, 11, 18, 12);
      MockTripStore store() => MockTripStore(
        now: () => now,
        snapshots: MockTripSnapshotStore(cache),
      );
      final first = store();
      await first.openSession('local:one');
      final input = booking();
      final trip = first.create(
        TripBookingInput(
          pickup: input.pickup,
          destination: input.destination,
          vehicleClassId: 'comfort',
          fare: input.fare,
          paymentMethod: TripPaymentMethod.wallet,
          couponCode: 'TAM10',
        ),
        idempotencyKey: 'one',
      );
      final engine = MockActiveTripRepository(
        first,
        now: () => now,
        autoStart: false,
      );
      now = now.add(const Duration(seconds: 18));
      engine.advance();
      final before = first.find(trip.id)!;
      expect(before.status, TripStatus.driverEnRoute);
      await first.flush();
      await engine.dispose();
      await first.dispose();
      final second = store();
      await second.openSession('local:one');
      expect(second.find(trip.id), before);
      final resumed = MockActiveTripRepository(
        second,
        now: () => now,
        autoStart: false,
      );
      expect((await resumed.current())?.id, trip.id);
      expect(second.trips, hasLength(1));
      await resumed.dispose();
      await second.dispose();
    },
  );
  test(
    'restart restores multiple reservations beside an immediate ride, with isolated cancellation',
    () async {
      final cache = MemorySnapshots();
      final now = DateTime.utc(2026, 11, 18, 12);
      MockTripStore store() => MockTripStore(
        now: () => now,
        snapshots: MockTripSnapshotStore(cache),
      );
      final first = store();
      await first.openSession('local:one');
      final input = booking();
      Trip reserve(String key, int days) => first.create(
        TripBookingInput(
          pickup: input.pickup,
          destination: input.destination,
          vehicleClassId: input.vehicleClassId,
          fare: input.fare,
          scheduledAt: now.add(Duration(days: days)),
        ),
        idempotencyKey: key,
      );
      final later = reserve('later', 2);
      final earlier = reserve('earlier', 1);
      final immediate = first.create(input, idempotencyKey: 'immediate');
      await first.flush();
      await first.dispose();
      final second = store();
      await second.openSession('local:one');
      final repository = MockActiveTripRepository(
        second,
        now: () => now,
        autoStart: false,
      );
      expect((await repository.current())!.id, immediate.id);
      expect((await repository.upcoming()).map((t) => t.id), [
        earlier.id,
        later.id,
      ]);
      await repository.cancel(earlier.id);
      expect((await repository.upcoming()).single.id, later.id);
      expect((await repository.fetch(immediate.id))!.status.isActive, isTrue);
      await repository.dispose();
      await second.dispose();
      final third = store();
      await third.openSession('local:one');
      expect(third.find(earlier.id)!.status, TripStatus.cancelled);
      expect(third.find(later.id)!.status, TripStatus.scheduled);
      await third.openSession('local:two');
      expect(third.trips, isEmpty);
      await third.dispose();
    },
  );
  test(
    'logout and account switch cannot expose or resurrect old snapshots',
    () async {
      final cache = MemorySnapshots();
      final snapshots = MockTripSnapshotStore(cache);
      final store = MockTripStore(snapshots: snapshots);
      await store.openSession('A');
      store.create(booking(), idempotencyKey: 'A');
      await store.flush();
      await store.openSession('B');
      expect(store.trips, isEmpty);
      await store.openSession('A');
      expect(store.trips, isEmpty);
      store.create(booking(), idempotencyKey: 'second');
      store.resetSession();
      await store.openSession('A');
      expect(store.trips, isEmpty);
      await store.dispose();
    },
  );
  test('late restore after logout does not repopulate the session', () async {
    final cache = MemorySnapshots();
    final snapshots = MockTripSnapshotStore(cache);
    final first = MockTripStore(snapshots: snapshots);
    await first.openSession('guest');
    first.create(booking(), idempotencyKey: 'one');
    await first.flush();
    await first.dispose();
    cache.delay = Completer<void>();
    final second = MockTripStore(snapshots: snapshots);
    final opening = second.openSession('guest');
    second.resetSession();
    cache.delay!.complete();
    await opening;
    await second.flush();
    expect(second.trips, isEmpty);
    expect(cache.values, isEmpty);
    await second.dispose();
  });
  test(
    'read failure blocks uncertain lookup until retry succeeds; no fake empty trip',
    () async {
      final cache = MemorySnapshots()..readFails = true;
      final store = MockTripStore(snapshots: MockTripSnapshotStore(cache));
      await store.openSession('guest');
      final repository = MockActiveTripRepository(store, autoStart: false);
      await expectLater(repository.current(), throwsA(anything));
      cache.readFails = false;
      expect(await repository.current(), isNull);
      await repository.dispose();
      await store.dispose();
    },
  );
  test(
    'cancelled trip stays terminal after restart and write failure is reported',
    () async {
      final cache = MemorySnapshots();
      final first = MockTripStore(snapshots: MockTripSnapshotStore(cache));
      await first.openSession('guest');
      final trip = first.create(booking(), idempotencyKey: 'one');
      first.cancel(trip.id);
      await first.flush();
      await first.dispose();
      final second = MockTripStore(snapshots: MockTripSnapshotStore(cache));
      await second.openSession('guest');
      expect(second.find(trip.id)!.status, TripStatus.cancelled);
      cache.writeFails = true;
      second.create(booking(), idempotencyKey: 'two');
      await expectLater(second.flush(), throwsA(isA<MockTripStoreFailure>()));
      await second.dispose();
    },
  );
}
