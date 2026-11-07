import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/data/mock/seed_trips.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';

TripBookingInput booking([int amount = 25000]) => TripBookingInput(
  pickup: TripLocation(
    label: 'A',
    point: GeoPoint(latitude: 33.5, longitude: 36.2),
  ),
  destination: TripLocation(
    label: 'B',
    point: GeoPoint(latitude: 33.6, longitude: 36.3),
  ),
  vehicleClassId: 'standard',
  fare: Money(amountMinor: amount),
);

void main() {
  test(
    'confirmation and cancellation publish the same shared trip state',
    () async {
      final store = MockTripStore(now: () => DateTime.utc(2026, 11, 7));
      final snapshots = <List<Trip>>[];
      final subscription = store.changes.listen(snapshots.add);
      final trip = store.create(booking(), idempotencyKey: 'request-1');
      expect(store.find(trip.id), trip);
      expect(trip.createdAt.isUtc, isTrue);
      expect(() => snapshots.single.add(trip), throwsUnsupportedError);
      final cancelled = store.cancel(trip.id);
      expect(cancelled.status, TripStatus.cancelled);
      expect(snapshots.last.single, cancelled);
      expect(snapshots.first.single.status, TripStatus.requested);
      expect(store.cancel(trip.id), cancelled);
      expect(snapshots, hasLength(2));
      await subscription.cancel();
      await store.dispose();
    },
  );

  test(
    'retry does not duplicate a booking or resurrect a cancelled trip',
    () async {
      final store = MockTripStore();
      final first = store.create(booking(), idempotencyKey: 'same');
      expect(store.create(booking(), idempotencyKey: 'same'), first);
      store.cancel(first.id);
      expect(
        store.create(booking(), idempotencyKey: 'same').status,
        TripStatus.cancelled,
      );
      expect(store.trips, hasLength(1));
      expect(
        () => store.create(booking(1), idempotencyKey: 'same'),
        throwsA(
          isA<MockTripStoreFailure>().having(
            (e) => e.code,
            'code',
            'IDEMPOTENCY_CONFLICT',
          ),
        ),
      );
      expect(
        () => store.create(booking(), idempotencyKey: ' '),
        throwsA(isA<MockTripStoreFailure>()),
      );
      await store.dispose();
    },
  );

  test('history cannot be cancelled and unknown IDs fail clearly', () async {
    final store = MockTripStore(seed: seedMockTrips());
    expect(store.find('mock-history-001')!.status, TripStatus.completed);
    expect(
      () => store.cancel('mock-history-001'),
      throwsA(
        isA<MockTripStoreFailure>().having(
          (e) => e.code,
          'code',
          'TRIP_NOT_CANCELLABLE',
        ),
      ),
    );
    expect(
      () => store.cancel('missing'),
      throwsA(
        isA<MockTripStoreFailure>().having(
          (e) => e.code,
          'code',
          'TRIP_NOT_FOUND',
        ),
      ),
    );
    await store.dispose();
  });

  test(
    'clearing ends the session dataset including idempotency records',
    () async {
      final store = MockTripStore(seed: seedMockTrips());
      final first = store.create(booking(), idempotencyKey: 'key');
      store.clear();
      expect(store.trips, isEmpty);
      expect(store.find(first.id), isNull);
      expect(
        store.create(booking(1), idempotencyKey: 'key').id,
        isNot(first.id),
      );
      await store.dispose();
    },
  );

  test('money rejects ambiguous or invalid fare representations', () {
    expect(() => Money(amountMinor: -1), throwsArgumentError);
    expect(() => Money(amountMinor: 1, currency: 'syp'), throwsArgumentError);
    expect(() => Money(amountMinor: 1, minorUnit: 4), throwsArgumentError);
    expect(Money(amountMinor: 25000).minorUnit, 0);
  });
}
