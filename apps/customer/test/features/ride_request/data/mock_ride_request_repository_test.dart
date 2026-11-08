import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_places.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/data/repositories/unavailable_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';

void main() {
  late DateTime now;
  late MockTripStore trips;
  late MockRideRequestRepository repository;

  setUp(() {
    now = DateTime.utc(2026, 11, 7, 12);
    trips = MockTripStore(now: () => now);
    repository = MockRideRequestRepository(trips: trips, now: () => now);
  });
  tearDown(() async => trips.dispose());

  test(
    'search returns deterministic Arabic/English matches and empty results',
    () async {
      expect((await repository.searchPlaces('مزة')).single.id, 'place-mezzeh');
      expect(
        (await repository.searchPlaces('citadel')).single.id,
        'place-citadel',
      );
      expect(await repository.searchPlaces('nothing-found'), isEmpty);
      expect(
        await repository.searchPlaces(''),
        hasLength(mockRidePlaces.length),
      );
    },
  );

  test(
    'valid quote is SYP minorUnit zero, bound to route and expires',
    () async {
      final quote = await repository.requestQuote(
        pickup: mockRidePlaces[0].location,
        destination: mockRidePlaces[1].location,
        vehicleClass: RideVehicleClass.standard,
      );
      expect(quote.fare.currency, 'SYP');
      expect(quote.fare.minorUnit, 0);
      expect(quote.fare.amountMinor, greaterThan(0));
      expect(quote.isValidAt(now), isTrue);
      now = now.add(const Duration(seconds: 90));
      expect(quote.isValidAt(now), isFalse);
      await expectLater(
        repository.confirm(quote: quote, idempotencyKey: 'booking-key-01'),
        throwsA(
          isA<RideRequestFailure>().having(
            (error) => error.code,
            'code',
            'QUOTE_EXPIRED',
          ),
        ),
      );
      expect(trips.trips, isEmpty);
    },
  );

  test('rejects same pickup/destination and simulates quote failure', () async {
    await expectLater(
      repository.requestQuote(
        pickup: mockRidePlaces[0].location,
        destination: mockRidePlaces[0].location,
        vehicleClass: RideVehicleClass.standard,
      ),
      throwsA(
        isA<RideRequestFailure>().having(
          (error) => error.code,
          'code',
          'VALIDATION_ERROR',
        ),
      ),
    );
    repository.failNextQuote = true;
    await expectLater(
      repository.requestQuote(
        pickup: mockRidePlaces[0].location,
        destination: mockRidePlaces[1].location,
        vehicleClass: RideVehicleClass.standard,
      ),
      throwsA(
        isA<RideRequestFailure>().having(
          (error) => error.code,
          'code',
          'SERVICE_UNAVAILABLE',
        ),
      ),
    );
  });

  test(
    'lost confirmation response retries same key without another trip',
    () async {
      repository.loseFirstConfirmationResponse = true;
      final quote = await repository.requestQuote(
        pickup: mockRidePlaces[0].location,
        destination: mockRidePlaces[1].location,
        vehicleClass: RideVehicleClass.standard,
      );
      await expectLater(
        repository.confirm(quote: quote, idempotencyKey: 'same-key'),
        throwsA(isA<RideRequestFailure>()),
      );
      expect(trips.trips, hasLength(1));
      final confirmed = await repository.confirm(
        quote: quote,
        idempotencyKey: 'same-key',
      );
      expect(confirmed.id, trips.trips.single.id);
      expect(trips.trips, hasLength(1));
      expect(trips.find(confirmed.id), confirmed);
    },
  );

  test('api stub fails explicitly and never writes mockTrips', () async {
    const api = UnavailableRideRequestRepository();
    await expectLater(
      api.searchPlaces('Aleppo'),
      throwsA(
        isA<RideRequestFailure>().having(
          (error) => error.code,
          'code',
          'SERVICE_UNAVAILABLE',
        ),
      ),
    );
    expect(trips.trips, isEmpty);
  });
}
