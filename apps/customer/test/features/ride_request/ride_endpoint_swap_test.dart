import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_places.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/trip.dart';

void main() {
  test(
    'swap reverses endpoints atomically and replaces the bound quote',
    () async {
      final store = MockTripStore();
      final bloc = RideDraftBloc(
        repository: MockRideRequestRepository(trips: store),
        prefill: TripPrefill(
          pickup: mockRidePlaces[0].location,
          destination: mockRidePlaces[1].location,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      final before = bloc.state;
      bloc.add(const RideEndpointsSwapped());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.pickup, before.destination);
      expect(bloc.state.destination, before.pickup);
      expect(bloc.state.pickupFromDevice, isFalse);
      expect(bloc.state.quote?.pickup, before.destination);
      expect(bloc.state.quote?.id, isNot(before.quote?.id));
      expect(store.trips, isEmpty);
      await bloc.close();
      await store.dispose();
    },
  );
  test(
    'uncertain confirmation cannot be changed by swapping endpoints',
    () async {
      final store = MockTripStore();
      final bloc = RideDraftBloc(
        repository: MockRideRequestRepository(
          trips: store,
          loseFirstConfirmationResponse: true,
        ),
        prefill: TripPrefill(
          pickup: mockRidePlaces[0].location,
          destination: mockRidePlaces[1].location,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      final before = bloc.state;
      bloc.add(const RideConfirmationRequested());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.failureStep, RideFailureStep.confirmation);
      bloc.add(const RideEndpointsSwapped());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.pickup, before.pickup);
      expect(bloc.state.destination, before.destination);
      expect(store.trips, hasLength(1));
      await bloc.close();
      await store.dispose();
    },
  );
}
