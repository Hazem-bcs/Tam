import 'package:tam_customer/features/active_trip/data/mock/active_trip_scenario.dart';
import 'package:tam_customer/features/active_trip/data/mock/mock_active_trip_repository.dart';
import 'package:tam_customer/features/maps/domain/maps_repository.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_places.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/trip.dart';

final class ActiveTripFixture {
  ActiveTripFixture({
    ActiveTripScenario scenario = ActiveTripScenario.success,
    ActiveTripTimings? durations,
    MapsRepository? routing,
  }) {
    store = MockTripStore(now: () => now);
    repository = MockActiveTripRepository(
      store,
      now: () => now,
      scenario: scenario,
      timings: durations ?? timings,
      autoStart: false,
      routing: routing,
    );
  }
  DateTime now = DateTime.utc(2026, 11, 9, 12);
  static const timings = ActiveTripTimings(
    search: Duration(seconds: 2),
    assignment: Duration(seconds: 1),
    approach: Duration(seconds: 4),
    waiting: Duration(seconds: 2),
    journey: Duration(seconds: 5),
  );
  late final MockTripStore store;
  late final MockActiveTripRepository repository;
  int _key = 0;
  Trip book({DateTime? scheduledAt, String vehicleClassId = 'standard'}) =>
      store.create(
        TripBookingInput(
          pickup: mockRidePlaces[0].location,
          destination: mockRidePlaces[1].location,
          vehicleClassId: vehicleClassId,
          fare: Money(amountMinor: 27000),
          scheduledAt: scheduledAt,
        ),
        idempotencyKey: 'trip-${++_key}',
      );
  void advance(int seconds) {
    now = now.add(Duration(seconds: seconds));
    repository.advance();
  }

  Future<void> dispose() async {
    await repository.dispose();
    await store.dispose();
  }
}
