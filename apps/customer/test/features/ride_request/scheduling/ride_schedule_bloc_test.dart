import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_places.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/domain/repositories/ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/trip.dart';

void main() {
  late DateTime now;
  late MockTripStore store;
  late MockRideRequestRepository repository;
  final prefill = TripPrefill(
    pickup: mockRidePlaces[0].location,
    destination: mockRidePlaces[1].location,
  );
  setUp(() {
    now = DateTime.utc(2026, 11, 9, 12);
    store = MockTripStore(now: () => now);
    repository = MockRideRequestRepository(trips: store, now: () => now);
  });
  tearDown(() => store.dispose());
  RideDraftBloc create({RideRequestRepository? source}) {
    final bloc = RideDraftBloc(
      repository: source ?? repository,
      prefill: prefill,
      now: () => now,
    );
    addTearDown(bloc.close);
    return bloc;
  }

  Future<void> ready(RideDraftBloc bloc) async {
    await bloc.stream.firstWhere((s) => s.status == RideFlowStatus.ready);
  }

  test(
    'changing or removing schedule discards quote and reprices the same route',
    () async {
      final bloc = create();
      await ready(bloc);
      final old = bloc.state.quote!;
      final time = now.add(const Duration(hours: 2));
      bloc.add(RideScheduleChanged(time));
      await ready(bloc);
      expect(bloc.state.quote!.id, isNot(old.id));
      expect(bloc.state.quote!.scheduledAt, time);
      expect(bloc.canConfirm, isTrue);
      bloc.add(const RideScheduleChanged(null));
      await ready(bloc);
      expect(bloc.state.scheduledAt, isNull);
      expect(bloc.state.quote!.scheduledAt, isNull);
      expect(bloc.state.pickup, prefill.pickup);
      expect(store.trips, isEmpty);
    },
  );

  test(
    'invalid selection is rejected and confirmation rechecks the clock',
    () async {
      final bloc = create();
      await ready(bloc);
      bloc.add(RideScheduleChanged(now.add(const Duration(minutes: 10))));
      await bloc.stream.firstWhere(
        (s) => s.errorCode == 'SCHEDULE_OUT_OF_RANGE',
      );
      expect(bloc.state.scheduledAt, isNull);
      bloc.add(RideScheduleChanged(now.add(const Duration(minutes: 31))));
      await ready(bloc);
      now = now.add(const Duration(seconds: 61));
      expect(bloc.canConfirm, isFalse);
      bloc.add(const RideConfirmationRequested());
      await bloc.stream.firstWhere(
        (s) => s.errorCode == 'SCHEDULE_OUT_OF_RANGE',
      );
      expect(store.trips, isEmpty);
    },
  );

  test(
    'known unavailable confirmation releases editing for another schedule',
    () async {
      final bloc = create();
      await ready(bloc);
      bloc.add(RideScheduleChanged(now.add(const Duration(hours: 2))));
      await ready(bloc);
      repository.schedulingAvailable = false;
      bloc.add(const RideConfirmationRequested());
      await bloc.stream.firstWhere(
        (s) => s.errorCode == 'SCHEDULE_UNAVAILABLE',
      );
      expect(bloc.state.confirmationPending, isFalse);
      bloc.add(const RideScheduleChanged(null));
      await ready(bloc);
      bloc.add(const RideConfirmationRequested());
      await bloc.stream.firstWhere((s) => s.status == RideFlowStatus.booked);
      expect(store.trips.single.status, TripStatus.requested);
    },
  );

  test(
    'uncertain confirmation freezes schedule and retries the original operation',
    () async {
      final bloc = create();
      await ready(bloc);
      final time = now.add(const Duration(hours: 1));
      bloc.add(RideScheduleChanged(time));
      await ready(bloc);
      repository.loseFirstConfirmationResponse = true;
      bloc.add(const RideConfirmationRequested());
      await bloc.stream.firstWhere(
        (s) => s.failureStep == RideFailureStep.confirmation,
      );
      bloc.add(const RideScheduleChanged(null));
      now = now.add(const Duration(hours: 3));
      bloc.add(const RideConfirmationRequested());
      await bloc.stream.firstWhere((s) => s.status == RideFlowStatus.booked);
      expect(bloc.state.confirmedTrip!.booking.scheduledAt, time);
      expect(store.trips, hasLength(1));
    },
  );

  test('stale quote cannot replace a newer schedule', () async {
    final controlled = _DelayedQuoteRepository(repository);
    final bloc = create(source: controlled);
    await ready(bloc);
    final pending = controlled.delayNext = Completer<RideQuote>();
    final firstTime = now.add(const Duration(hours: 1));
    bloc.add(RideScheduleChanged(firstTime));
    await bloc.stream.firstWhere((s) => s.status == RideFlowStatus.quoting);
    final secondTime = now.add(const Duration(hours: 2));
    bloc.add(RideScheduleChanged(secondTime));
    await ready(bloc);
    pending.complete(
      await repository.requestQuote(
        pickup: prefill.pickup,
        destination: prefill.destination,
        vehicleClass: RideVehicleClass.standard,
        scheduledAt: firstTime,
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.quote!.scheduledAt, secondTime);
  });

  testWidgets('schedule boundary expires before a still-valid quote', (
    tester,
  ) async {
    final bloc = create();
    await tester.pump();
    await tester.pump();
    bloc.add(
      RideScheduleChanged(now.add(const Duration(minutes: 30, seconds: 1))),
    );
    await tester.pump();
    await tester.pump();
    expect(bloc.state.status, RideFlowStatus.ready);
    now = now.add(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(bloc.state.errorCode, 'SCHEDULE_OUT_OF_RANGE');
    expect(bloc.state.quote!.isValidAt(now), isTrue);
  });
}

final class _DelayedQuoteRepository implements RideRequestRepository {
  _DelayedQuoteRepository(this.delegate);
  final RideRequestRepository delegate;
  Completer<RideQuote>? delayNext;
  @override
  Future<RideQuote> requestQuote({
    required TripLocation pickup,
    required TripLocation destination,
    required RideVehicleClass vehicleClass,
    DateTime? scheduledAt,
  }) {
    final pending = delayNext;
    delayNext = null;
    return pending?.future ??
        delegate.requestQuote(
          pickup: pickup,
          destination: destination,
          vehicleClass: vehicleClass,
          scheduledAt: scheduledAt,
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
