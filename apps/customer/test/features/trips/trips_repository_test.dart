import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/trips/data/api/unavailable_trips_repository.dart';
import 'package:tam_customer/features/trips/data/mock/mock_trips_repository.dart';
import 'package:tam_customer/features/trips/domain/trips_repository.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/data/mock/seed_trips.dart';
import 'package:tam_customer/shared/data/trip_wire_codec.dart';
import 'package:tam_customer/shared/domain/trip.dart';

void main() {
  test(
    'cursor pages stay sorted and distinct, including equal timestamps',
    () async {
      final booking = seedMockTrips().first.booking;
      final seed = [
        ...seedMockTrips(),
        for (var i = 0; i < 51; i++)
          Trip(
            id: 'history-$i',
            booking: booking,
            createdAt: DateTime.utc(2026, 11, 2).add(Duration(minutes: i ~/ 2)),
            status: TripStatus.requested,
          ),
      ];
      final store = MockTripStore(seed: seed);
      addTearDown(store.dispose);
      final repo = MockTripsRepository(store);
      String? cursor;
      final received = <Trip>[];
      do {
        final page = await repo.list(cursor: cursor);
        expect(page.items.length, lessThanOrEqualTo(20));
        received.addAll(page.items);
        cursor = page.nextCursor;
      } while (cursor != null);
      expect(received, hasLength(53));
      expect(received.map((trip) => trip.id).toSet(), hasLength(53));
      expect(received.first.id, 'history-50');
      expect(received.last.id, 'mock-history-002');
    },
  );

  test('filters, empty results, and invalid cursor/limit', () async {
    final store = MockTripStore(seed: seedMockTrips());
    addTearDown(store.dispose);
    final repo = MockTripsRepository(store);
    expect((await repo.list(filter: TripsFilter.active)).items, isEmpty);
    expect(
      (await repo.list(filter: TripsFilter.completed)).items.single.id,
      'mock-history-001',
    );
    expect(
      (await repo.list(filter: TripsFilter.cancelled)).items.single.id,
      'mock-history-002',
    );
    for (final invalid in [0, 51]) {
      await expectLater(
        repo.list(limit: invalid),
        throwsA(
          isA<TripsFailure>().having((e) => e.code, 'code', 'VALIDATION_ERROR'),
        ),
      );
    }
    await expectLater(
      repo.list(cursor: '!invalid!'),
      throwsA(
        isA<TripsFailure>().having((e) => e.code, 'code', 'VALIDATION_ERROR'),
      ),
    );
  });

  test(
    'booking creation and cancellation update same injected history',
    () async {
      final store = MockTripStore(seed: seedMockTrips());
      addTearDown(store.dispose);
      final repo = MockTripsRepository(store);
      final changes = <void>[];
      final subscription = repo.changes.listen(changes.add);
      addTearDown(subscription.cancel);
      final created = store.create(
        seedMockTrips().first.booking,
        idempotencyKey: 'new-booking',
      );
      expect(
        (await repo.list(filter: TripsFilter.active)).items.single.id,
        created.id,
      );
      expect((await repo.find(created.id))?.status, TripStatus.requested);
      expect((await repo.cancel(created.id)).status, TripStatus.cancelled);
      expect((await repo.find(created.id))?.status, TripStatus.cancelled);
      expect(changes, hasLength(2));
      expect((await repo.list(filter: TripsFilter.active)).items, isEmpty);
      expect(
        (await repo.list(filter: TripsFilter.cancelled)).items,
        hasLength(2),
      );
      await expectLater(
        repo.cancel('missing'),
        throwsA(
          isA<TripsFailure>().having((e) => e.code, 'code', 'TRIP_NOT_FOUND'),
        ),
      );
      await expectLater(
        repo.cancel('mock-history-001'),
        throwsA(
          isA<TripsFailure>().having(
            (e) => e.code,
            'code',
            'TRIP_NOT_CANCELLABLE',
          ),
        ),
      );
      expect((await repo.cancel(created.id)).status, TripStatus.cancelled);
      expect(changes, hasLength(2)); // repeated cancel is idempotent
    },
  );

  test('API mode never exposes seeded trips or silently succeeds', () async {
    const repo = UnavailableTripsRepository();
    await expectLater(
      repo.list(),
      throwsA(
        isA<TripsFailure>().having(
          (e) => e.code,
          'code',
          'SERVICE_UNAVAILABLE',
        ),
      ),
    );
    await expectLater(
      repo.find('mock-history-001'),
      throwsA(isA<TripsFailure>()),
    );
    await expectLater(
      repo.cancel('mock-history-001'),
      throwsA(isA<TripsFailure>()),
    );
  });

  test(
    'wire examples parse into the canonical Trip with no guessed values',
    () {
      Map<String, dynamic> read(String name) =>
          jsonDecode(
                File('../../docs/api/trips/examples/$name').readAsStringSync(),
              )
              as Map<String, dynamic>;
      final decoded = TripWireCodec.fromJson(read('trip-completed.json'));
      expect(decoded, seedMockTrips().first);
      expect(
        TripWireCodec.fromJson(read('trip-cancelled.json')).status,
        TripStatus.cancelled,
      );
      final requested = TripWireCodec.fromJson(read('trip-requested.json'));
      expect(requested.status, TripStatus.requested);
      expect(TripWireCodec.fromJson(TripWireCodec.toJson(decoded)), decoded);
      final detail = read('trip-details.json');
      expect(
        TripWireCodec.fromJson(detail['data'] as Map<String, dynamic>),
        decoded,
      );
      final list = read('trips-page-1.json');
      expect(
        (list['data'] as List)
            .map((raw) => TripWireCodec.fromJson(raw as Map<String, dynamic>))
            .toList(),
        seedMockTrips(),
      );
      expect(list['meta'], {'next_cursor': null});
    },
  );

  test('wire rejects missing/invalid price, timestamp, and status', () {
    final source =
        jsonDecode(
              File(
                '../../docs/api/trips/examples/trip-completed.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    Map<String, dynamic> copy() =>
        jsonDecode(jsonEncode(source)) as Map<String, dynamic>;
    final missingFare = copy()..remove('fare');
    expect(() => TripWireCodec.fromJson(missingFare), throwsFormatException);
    final badMoney = copy()..['fare']['amount_minor'] = 12.5;
    expect(() => TripWireCodec.fromJson(badMoney), throwsFormatException);
    final badDate = copy()..['created_at'] = '2026-11-01T12:00:00+03:00';
    expect(() => TripWireCodec.fromJson(badDate), throwsFormatException);
    for (final date in ['2026-02-30T12:00:00Z', '2026-11-01T25:00:00Z']) {
      expect(
        () => TripWireCodec.fromJson(copy()..['created_at'] = date),
        throwsFormatException,
      );
    }
    expect(
      () => TripWireCodec.fromJson(copy()..['pickup']['latitude'] = 91),
      throwsFormatException,
    );
    expect(
      () => TripWireCodec.fromJson(copy()..['fare']['amount_minor'] = -1),
      throwsFormatException,
    );
    expect(
      () => TripWireCodec.fromJson(copy()..['id'] = '   '),
      throwsFormatException,
    );
    final badStatus = copy()..['status'] = 'driver_here';
    expect(() => TripWireCodec.fromJson(badStatus), throwsFormatException);
  });
}
