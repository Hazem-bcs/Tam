import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_places.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/domain/repositories/ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/data/trip_wire_codec.dart';
import 'package:tam_customer/shared/domain/trip.dart';

void main() {
  final now = DateTime.utc(2026, 11, 17, 12);
  late MockTripStore store;
  late MockRideRequestRepository repository;
  final prefill = TripPrefill(
    pickup: mockRidePlaces[0].location,
    destination: mockRidePlaces[1].location,
  );
  setUp(() {
    store = MockTripStore(now: () => now);
    repository = MockRideRequestRepository(trips: store, now: () => now);
  });
  tearDown(() => store.dispose());
  Future<RideDraftBloc> create() async {
    final bloc = RideDraftBloc(
      repository: repository,
      now: () => now,
      prefill: prefill,
    );
    addTearDown(bloc.close);
    await bloc.stream.firstWhere((s) => s.status == RideFlowStatus.ready);
    return bloc;
  }

  test(
    'all classes have route-bound fares; selection uses its issued quote',
    () async {
      final bloc = await create();
      final catalog = bloc.state.vehicleQuotes;
      expect(catalog.keys, containsAll(RideVehicleClass.values));
      expect(
        catalog[RideVehicleClass.comfort]!.fare.amountMinor,
        greaterThan(catalog[RideVehicleClass.standard]!.fare.amountMinor),
      );
      bloc.add(const VehicleClassSelected(RideVehicleClass.comfort));
      await bloc.stream.firstWhere(
        (s) => s.vehicleClass == RideVehicleClass.comfort,
      );
      expect(bloc.state.quote, same(catalog[RideVehicleClass.comfort]));
      expect(bloc.canConfirm, isTrue);
    },
  );
  test(
    'wallet and coupon survive repricing, confirmation, retry and wire roundtrip',
    () async {
      final bloc = await create();
      bloc.add(const RidePaymentChanged(TripPaymentMethod.wallet));
      await bloc.stream.firstWhere(
        (s) => s.quote?.paymentMethod == TripPaymentMethod.wallet,
      );
      bloc.add(const RideCouponApplied(' tam10 '));
      await bloc.stream.firstWhere((s) => s.quote?.couponCode == 'TAM10');
      expect(bloc.state.quote!.fare.amountMinor, 24300);
      expect(bloc.state.quote!.discount!.amountMinor, 2700);
      bloc.add(const VehicleClassSelected(RideVehicleClass.comfort));
      await bloc.stream.firstWhere(
        (s) => s.vehicleClass == RideVehicleClass.comfort,
      );
      expect(bloc.state.quote!.fare.amountMinor, 33300);
      repository.loseFirstConfirmationResponse = true;
      bloc.add(const RideConfirmationRequested());
      await bloc.stream.firstWhere(
        (s) => s.failureStep == RideFailureStep.confirmation,
      );
      expect(store.trips, hasLength(1));
      bloc.add(const RidePaymentChanged(TripPaymentMethod.cash));
      bloc.add(const RideCouponRemoved());
      bloc.add(const RideConfirmationRequested());
      await bloc.stream.firstWhere((s) => s.status == RideFlowStatus.booked);
      final trip = bloc.state.confirmedTrip!;
      expect(store.trips, hasLength(1));
      expect(trip.booking.paymentMethod, TripPaymentMethod.wallet);
      expect(trip.booking.couponCode, 'TAM10');
      expect(trip.booking.fare.amountMinor, 33300);
      expect(TripWireCodec.fromJson(TripWireCodec.toJson(trip)), trip);
    },
  );
  test('invalid coupon blocks confirmation until explicitly removed', () async {
    final bloc = await create();
    bloc.add(const RideCouponApplied('EXPIRED'));
    await bloc.stream.firstWhere((s) => s.errorCode == 'COUPON_INVALID');
    expect(bloc.canConfirm, isFalse);
    expect(bloc.state.quote, isNull);
    expect(store.trips, isEmpty);
    bloc.add(const RideCouponRemoved());
    await bloc.stream.firstWhere((s) => s.status == RideFlowStatus.ready);
    expect(bloc.state.quote!.couponCode, isNull);
    expect(bloc.state.quote!.fare.amountMinor, 27000);
  });
  test('unavailable wallet never silently books as cash', () async {
    repository = MockRideRequestRepository(
      trips: store,
      now: () => now,
      walletAvailable: false,
    );
    final bloc = await create();
    bloc.add(const RidePaymentChanged(TripPaymentMethod.wallet));
    await bloc.stream.firstWhere((s) => s.errorCode == 'PAYMENT_UNAVAILABLE');
    expect(bloc.canConfirm, isFalse);
    expect(bloc.state.paymentMethod, TripPaymentMethod.wallet);
    expect(store.trips, isEmpty);
    bloc.add(const RidePaymentChanged(TripPaymentMethod.cash));
    await bloc.stream.firstWhere((s) => s.status == RideFlowStatus.ready);
    expect(bloc.state.quote!.paymentMethod, TripPaymentMethod.cash);
  });
  test('late wallet results never replace a newer cash intent', () async {
    final delayed = _DelayedWallet(repository);
    final bloc = RideDraftBloc(
      repository: delayed,
      now: () => now,
      prefill: prefill,
    );
    addTearDown(bloc.close);
    await bloc.stream.firstWhere((s) => s.status == RideFlowStatus.ready);
    bloc.add(const RidePaymentChanged(TripPaymentMethod.wallet));
    await bloc.stream.firstWhere((s) => s.status == RideFlowStatus.quoting);
    bloc.add(const RidePaymentChanged(TripPaymentMethod.cash));
    await bloc.stream.firstWhere((s) => s.status == RideFlowStatus.ready);
    final current = bloc.state.quote;
    delayed.wallet.complete();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.quote, same(current));
    expect(bloc.state.paymentMethod, TripPaymentMethod.cash);
  });

  test('payment and coupon values affect booking idempotency identity', () {
    final cash = TripBookingInput(
      pickup: prefill.pickup,
      destination: prefill.destination,
      vehicleClassId: 'standard',
      fare: Money(amountMinor: 100),
    );
    final wallet = TripBookingInput(
      pickup: prefill.pickup,
      destination: prefill.destination,
      vehicleClassId: 'standard',
      fare: Money(amountMinor: 100),
      paymentMethod: TripPaymentMethod.wallet,
    );
    store.create(cash, idempotencyKey: 'same');
    expect(
      () => store.create(wallet, idempotencyKey: 'same'),
      throwsA(isA<MockTripStoreFailure>()),
    );
  });
}

final class _DelayedWallet implements RideRequestRepository {
  _DelayedWallet(this.delegate);
  final RideRequestRepository delegate;
  final wallet = Completer<void>();
  @override
  Future<RideQuote> requestQuote({
    required TripLocation pickup,
    required TripLocation destination,
    required RideVehicleClass vehicleClass,
    DateTime? scheduledAt,
    TripPaymentMethod paymentMethod = TripPaymentMethod.cash,
    String? couponCode,
  }) async {
    if (paymentMethod == TripPaymentMethod.wallet) await wallet.future;
    return delegate.requestQuote(
      pickup: pickup,
      destination: destination,
      vehicleClass: vehicleClass,
      scheduledAt: scheduledAt,
      paymentMethod: paymentMethod,
      couponCode: couponCode,
    );
  }

  @override
  Future<List<RidePlace>> searchPlaces(String query) =>
      delegate.searchPlaces(query);
  @override
  Future<Trip> confirm({
    required RideQuote quote,
    required String idempotencyKey,
  }) => delegate.confirm(quote: quote, idempotencyKey: idempotencyKey);
}
