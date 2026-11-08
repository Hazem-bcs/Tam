import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_places.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/trip.dart';

void main() {
  late DateTime now;
  late MockTripStore trips;
  late MockRideRequestRepository repository;
  RideDraftBloc create({TripPrefill? prefill}) => RideDraftBloc(
    repository: repository,
    prefill: prefill,
    now: () => now,
    newIdempotencyKey: () => 'stable-key',
  );

  setUp(() {
    now = DateTime.utc(2026, 11, 7, 12);
    trips = MockTripStore(now: () => now);
    repository = MockRideRequestRepository(trips: trips, now: () => now);
  });
  tearDown(() async => trips.dispose());

  test('route requires two distinct valid locations', () async {
    final bloc = create();
    addTearDown(bloc.close);
    expect(bloc.state.hasRoute, isFalse);
    bloc.add(PickupSelected(mockRidePlaces[0].location));
    await bloc.stream.firstWhere((s) => s.pickup != null);
    expect(bloc.state.hasRoute, isFalse);
    bloc.add(DestinationSelected(mockRidePlaces[0].location));
    await bloc.stream.firstWhere((s) => s.destination != null);
    expect(bloc.state.hasRoute, isFalse);
    bloc.add(const RideConfirmationRequested());
    await bloc.stream.firstWhere((s) => s.errorCode == 'VALIDATION_ERROR');
    expect(trips.trips, isEmpty);
  });

  test('prefill fills locations only and obtains a new quote', () async {
    final bloc = create(
      prefill: TripPrefill(
        pickup: mockRidePlaces[0].location,
        destination: mockRidePlaces[1].location,
      ),
    );
    addTearDown(bloc.close);
    expect(bloc.state.quote, isNull);
    await bloc.stream.firstWhere((s) => s.status == RideFlowStatus.ready);
    expect(bloc.state.quote, isNotNull);
    expect(bloc.state.quote!.vehicleClass, RideVehicleClass.standard);
    bloc.add(const VehicleClassSelected(RideVehicleClass.van));
    await bloc.stream.firstWhere(
      (s) =>
          s.status == RideFlowStatus.ready &&
          s.quote?.vehicleClass == RideVehicleClass.van,
    );
    expect(trips.trips, isEmpty);
  });

  test('expired quote cannot confirm and can be refreshed', () async {
    final bloc = create(
      prefill: TripPrefill(
        pickup: mockRidePlaces[0].location,
        destination: mockRidePlaces[1].location,
      ),
    );
    addTearDown(bloc.close);
    await bloc.stream.firstWhere((s) => s.status == RideFlowStatus.ready);
    now = now.add(const Duration(minutes: 2));
    bloc.add(const RideConfirmationRequested());
    await bloc.stream.firstWhere((s) => s.errorCode == 'QUOTE_EXPIRED');
    expect(trips.trips, isEmpty);
    bloc.add(const RideQuoteRequested());
    await bloc.stream.firstWhere(
      (s) => s.status == RideFlowStatus.ready && s.quote!.isValidAt(now),
    );
    expect(bloc.state.canConfirmAt(now), isTrue);
  });

  test(
    'double tap and retry after lost response create exactly one trip',
    () async {
      repository.loseFirstConfirmationResponse = true;
      final bloc = create(
        prefill: TripPrefill(
          pickup: mockRidePlaces[0].location,
          destination: mockRidePlaces[1].location,
        ),
      );
      addTearDown(bloc.close);
      await bloc.stream.firstWhere((s) => s.status == RideFlowStatus.ready);
      bloc.add(const RideConfirmationRequested());
      bloc.add(const RideConfirmationRequested());
      await bloc.stream.firstWhere(
        (s) =>
            s.status == RideFlowStatus.failed &&
            s.failureStep == RideFailureStep.confirmation,
      );
      expect(trips.trips, hasLength(1));
      bloc.add(const RideConfirmationRequested());
      await bloc.stream.firstWhere((s) => s.status == RideFlowStatus.booked);
      expect(trips.trips, hasLength(1));
      expect(bloc.state.confirmedTrip, trips.trips.single);
      bloc.add(const RideConfirmationRequested());
      await Future<void>.delayed(Duration.zero);
      expect(trips.trips, hasLength(1));
    },
  );

  test('failed quote exposes retry and no confirmation is created', () async {
    repository.failNextQuote = true;
    final bloc = create(
      prefill: TripPrefill(
        pickup: mockRidePlaces[0].location,
        destination: mockRidePlaces[1].location,
      ),
    );
    addTearDown(bloc.close);
    await bloc.stream.firstWhere((s) => s.errorCode == 'SERVICE_UNAVAILABLE');
    expect(bloc.state.quote, isNull);
    expect(bloc.state.canConfirmAt(now), isFalse);
    bloc.add(const RideQuoteRequested());
    await bloc.stream.firstWhere((s) => s.status == RideFlowStatus.ready);
    expect(trips.trips, isEmpty);
  });
  test('uncertain booking can retry after expiry with the same key', () async {
    repository.loseFirstConfirmationResponse = true;
    final bloc = create(
      prefill: TripPrefill(
        pickup: mockRidePlaces[0].location,
        destination: mockRidePlaces[1].location,
      ),
    );
    addTearDown(bloc.close);
    await bloc.stream.firstWhere((s) => s.status == RideFlowStatus.ready);
    bloc.add(const RideConfirmationRequested());
    await bloc.stream.firstWhere(
      (s) =>
          s.status == RideFlowStatus.failed &&
          s.failureStep == RideFailureStep.confirmation,
    );
    final firstId = trips.trips.single.id;
    now = now.add(const Duration(minutes: 5));
    bloc.add(const RideConfirmationRequested());
    await bloc.stream.firstWhere((s) => s.status == RideFlowStatus.booked);
    expect(bloc.state.confirmedTrip!.id, firstId);
    expect(trips.trips, hasLength(1));
  });

  test(
    'unresolved confirmation cannot be replaced by editing or quoting',
    () async {
      repository.loseFirstConfirmationResponse = true;
      var keys = 0;
      final bloc = RideDraftBloc(
        repository: repository,
        prefill: TripPrefill(
          pickup: mockRidePlaces[0].location,
          destination: mockRidePlaces[1].location,
        ),
        now: () => now,
        newIdempotencyKey: () => 'key-${++keys}',
      );
      addTearDown(bloc.close);
      await bloc.stream.firstWhere((s) => s.status == RideFlowStatus.ready);
      final originalQuote = bloc.state.quote;
      bloc.add(const RideConfirmationRequested());
      await bloc.stream.firstWhere(
        (s) =>
            s.status == RideFlowStatus.failed &&
            s.failureStep == RideFailureStep.confirmation,
      );
      bloc.add(PickupSelected(mockRidePlaces[2].location));
      bloc.add(DestinationSelected(mockRidePlaces[3].location));
      bloc.add(const VehicleClassSelected(RideVehicleClass.van));
      bloc.add(const RideQuoteRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(bloc.state.quote, originalQuote);
      expect(bloc.state.failureStep, RideFailureStep.confirmation);
      bloc.add(const RideConfirmationRequested());
      await bloc.stream.firstWhere((s) => s.status == RideFlowStatus.booked);
      expect(keys, 1);
      expect(trips.trips, hasLength(1));
    },
  );
}
