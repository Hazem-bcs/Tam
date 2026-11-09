import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_places.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/data/repositories/unavailable_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/features/trips/data/mock/mock_trips_repository.dart';
import 'package:tam_customer/features/trips/domain/trips_repository.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/trip.dart';

void main() {
  late DateTime now;
  late MockTripStore store;
  late MockRideRequestRepository repository;
  setUp(() {
    now = DateTime.utc(2026, 11, 9, 12);
    store = MockTripStore(now: () => now);
    repository = MockRideRequestRepository(trips: store, now: () => now);
  });
  tearDown(() => store.dispose());
  Future<RideQuote> quote(DateTime? scheduledAt) => repository.requestQuote(
    pickup: mockRidePlaces[0].location,
    destination: mockRidePlaces[1].location,
    vehicleClass: RideVehicleClass.standard,
    scheduledAt: scheduledAt,
  );
  Matcher failure(String code) =>
      throwsA(isA<RideRequestFailure>().having((e) => e.code, 'code', code));

  test(
    'scheduled booking is shared, active, cancellable and retains its time',
    () async {
      final time = now.add(const Duration(hours: 2));
      final result = await quote(time);
      expect(result.scheduledAt, time);
      final trip = await repository.confirm(
        quote: result,
        idempotencyKey: 'scheduled-1',
      );
      expect(trip.status, TripStatus.scheduled);
      expect(trip.booking.scheduledAt, time);
      final trips = MockTripsRepository(store);
      expect((await trips.list(filter: TripsFilter.active)).items, [trip]);
      final cancelled = await trips.cancel(trip.id);
      expect(cancelled.status, TripStatus.cancelled);
      expect(cancelled.booking.scheduledAt, time);
      expect(
        await repository.confirm(quote: result, idempotencyKey: 'scheduled-1'),
        cancelled,
      );
    },
  );

  test(
    'quote rejects both out-of-range boundaries and unavailable scheduling',
    () async {
      for (final delta in [
        const Duration(minutes: 29),
        const Duration(days: 8),
      ]) {
        await expectLater(
          quote(now.add(delta)),
          failure('SCHEDULE_OUT_OF_RANGE'),
        );
      }
      repository.schedulingAvailable = false;
      await expectLater(
        quote(now.add(const Duration(hours: 2))),
        failure('SCHEDULE_UNAVAILABLE'),
      );
      expect((await quote(null)).scheduledAt, isNull);
      expect(store.trips, isEmpty);
    },
  );

  test(
    'confirmation rechecks time while quote itself is still valid',
    () async {
      final result = await quote(now.add(const Duration(minutes: 31)));
      now = now.add(const Duration(seconds: 61));
      expect(result.isValidAt(now), isTrue);
      await expectLater(
        repository.confirm(quote: result, idempotencyKey: 'late'),
        failure('SCHEDULE_OUT_OF_RANGE'),
      );
      expect(store.trips, isEmpty);
    },
  );

  test(
    'availability can change after quoting without creating a trip',
    () async {
      final result = await quote(now.add(const Duration(hours: 2)));
      repository.schedulingAvailable = false;
      await expectLater(
        repository.confirm(quote: result, idempotencyKey: 'full'),
        failure('SCHEDULE_UNAVAILABLE'),
      );
      expect(store.trips, isEmpty);
    },
  );

  test(
    'lost response retry resolves original even after scheduled time',
    () async {
      final result = await quote(now.add(const Duration(hours: 1)));
      repository.loseFirstConfirmationResponse = true;
      await expectLater(
        repository.confirm(quote: result, idempotencyKey: 'same'),
        failure('SERVICE_UNAVAILABLE'),
      );
      now = now.add(const Duration(hours: 3));
      repository.schedulingAvailable = false;
      final resolved = await repository.confirm(
        quote: result,
        idempotencyKey: 'same',
      );
      expect(resolved, store.trips.single);
      expect(resolved.booking.scheduledAt, result.scheduledAt);
    },
  );

  test('a changed schedule is a different booking intent', () async {
    final first = await quote(now.add(const Duration(hours: 1)));
    await repository.confirm(quote: first, idempotencyKey: 'same');
    final second = await quote(now.add(const Duration(hours: 2)));
    await expectLater(
      repository.confirm(quote: second, idempotencyKey: 'same'),
      failure('IDEMPOTENCY_CONFLICT'),
    );
    expect(store.trips, hasLength(1));
  });

  test(
    'API scheduled request fails explicitly without touching mock state',
    () async {
      await expectLater(
        const UnavailableRideRequestRepository().requestQuote(
          pickup: mockRidePlaces[0].location,
          destination: mockRidePlaces[1].location,
          vehicleClass: RideVehicleClass.standard,
          scheduledAt: now.add(const Duration(hours: 1)),
        ),
        failure('SERVICE_UNAVAILABLE'),
      );
      expect(store.trips, isEmpty);
    },
  );
}
