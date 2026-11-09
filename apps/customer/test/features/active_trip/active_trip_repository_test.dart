import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/active_trip/data/mock/active_trip_scenario.dart';
import 'package:tam_customer/features/active_trip/data/unavailable_active_trip_repository.dart';
import 'package:tam_customer/features/active_trip/domain/active_trip_repository.dart';
import 'package:tam_customer/features/trips/data/mock/mock_trips_repository.dart';
import 'package:tam_customer/features/trips/domain/trips_repository.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';
import 'active_trip_test_support.dart';

void main() {
  late ActiveTripFixture fixture;
  setUp(() => fixture = ActiveTripFixture());
  tearDown(() => fixture.dispose());
  test(
    'one atomic source progresses through all phases to completion',
    () async {
      final id = fixture.book().id;
      var previous = (await fixture.repository.fetch(id))!;
      expect(previous.status, TripStatus.requested);
      final history = MockTripsRepository(fixture.store);
      for (final stage in [
        (2, TripStatus.confirmed),
        (1, TripStatus.driverEnRoute),
        (4, TripStatus.driverArrived),
        (2, TripStatus.inProgress),
        (5, TripStatus.completed),
      ]) {
        fixture.advance(stage.$1);
        final current = (await fixture.repository.fetch(id))!;
        expect(current.status, stage.$2);
        expect(current.live!.revision, greaterThan(previous.live!.revision));
        expect(await history.find(id), current);
        if (current.status.isActive) {
          expect((await history.list(filter: TripsFilter.active)).items, [
            current,
          ]);
        }
        previous = current;
      }
      expect(previous.live!.position, isNull);
      expect(previous.live!.etaSeconds, isNull);
      expect(await fixture.repository.current(), isNull);
    },
  );
  test(
    'approach updates position and ETA without changing booking identity',
    () async {
      final trip = fixture.book();
      fixture.advance(3);
      final first = (await fixture.repository.fetch(trip.id))!;
      fixture.advance(2);
      final second = (await fixture.repository.fetch(trip.id))!;
      expect(second.booking, trip.booking);
      expect(second.live!.position!.point, isNot(first.live!.position!.point));
      expect(second.live!.etaSeconds, lessThan(first.live!.etaSeconds!));
    },
  );
  test(
    'scheduled dispatch is due-driven and catches up after time away',
    () async {
      final due = fixture.now.add(const Duration(minutes: 30));
      final trip = fixture.book(scheduledAt: due);
      expect(
        (await fixture.repository.fetch(trip.id))!.status,
        TripStatus.scheduled,
      );
      fixture.advance(1799);
      expect(
        (await fixture.repository.fetch(trip.id))!.status,
        TripStatus.scheduled,
      );
      fixture.advance(1);
      expect(
        (await fixture.repository.fetch(trip.id))!.status,
        TripStatus.requested,
      );
      fixture.advance(20);
      final current = (await fixture.repository.fetch(trip.id))!;
      expect(current.status, TripStatus.completed);
      expect(current.booking.scheduledAt, due);
    },
  );
  test(
    'cancel from history stops all further simulated driver events',
    () async {
      final trip = fixture.book();
      fixture.advance(7);
      expect(fixture.store.find(trip.id)!.status, TripStatus.driverArrived);
      final cancelled = await MockTripsRepository(
        fixture.store,
      ).cancel(trip.id);
      fixture.advance(60);
      expect(await fixture.repository.fetch(trip.id), cancelled);
      expect(cancelled.live!.position, isNull);
      expect(await fixture.repository.cancel(trip.id), cancelled);
    },
  );
  test(
    'in-progress cancellation is refused and cannot rewind trip state',
    () async {
      final trip = fixture.book();
      fixture.advance(9);
      await expectLater(
        fixture.repository.cancel(trip.id),
        throwsA(
          isA<ActiveTripFailure>().having(
            (e) => e.code,
            'code',
            'TRIP_NOT_CANCELLABLE',
          ),
        ),
      );
      expect(fixture.store.find(trip.id)!.status, TripStatus.inProgress);
    },
  );
  test(
    'compare-and-set refuses stale revisions and illegal transitions',
    () async {
      final id = fixture.book().id;
      final old = (await fixture.repository.fetch(id))!;
      fixture.advance(2);
      final current = fixture.store.find(id)!;
      final stale = old.withLive(
        TripStatus.cancelled,
        TripLiveDetails(
          revision: old.live!.revision + 1,
          updatedAt: fixture.now,
          statusChangedAt: fixture.now,
        ),
      );
      expect(
        () => fixture.store.updateLive(
          stale,
          expectedRevision: old.live!.revision,
        ),
        throwsA(isA<MockTripStoreFailure>()),
      );
      final illegal = current.withLive(
        TripStatus.completed,
        TripLiveDetails(
          revision: current.live!.revision + 1,
          updatedAt: fixture.now,
          statusChangedAt: fixture.now,
        ),
      );
      expect(
        () => fixture.store.updateLive(
          illegal,
          expectedRevision: current.live!.revision,
        ),
        throwsA(isA<MockTripStoreFailure>()),
      );
      expect(fixture.store.find(id), current);
    },
  );
  test('lost cancellation response can safely retry for the same id', () async {
    final id = fixture.book().id;
    await fixture.repository.fetch(id);
    fixture.repository.loseNextCancelResponse = true;
    await expectLater(
      fixture.repository.cancel(id),
      throwsA(isA<ActiveTripFailure>()),
    );
    expect((await fixture.repository.cancel(id)).status, TripStatus.cancelled);
    expect(fixture.store.trips, hasLength(1));
  });
  test(
    'current prioritizes dispatched trips then earliest scheduled time',
    () async {
      final later = fixture.book(
        scheduledAt: fixture.now.add(const Duration(days: 2)),
      );
      final earlier = fixture.book(
        scheduledAt: fixture.now.add(const Duration(days: 1)),
      );
      expect((await fixture.repository.current())!.id, earlier.id);
      final immediate = fixture.book();
      expect((await fixture.repository.current())!.id, immediate.id);
      await fixture.repository.cancel(immediate.id);
      await fixture.repository.cancel(earlier.id);
      expect((await fixture.repository.current())!.id, later.id);
    },
  );
  test(
    'reset removes previous session live data and pending operations',
    () async {
      final id = fixture.book().id;
      fixture.advance(3);
      fixture.store.resetSession();
      fixture.repository.resetSession();
      fixture.advance(60);
      expect(await fixture.repository.fetch(id), isNull);
      expect(await fixture.repository.current(), isNull);
      expect(fixture.store.trips, isEmpty);
    },
  );
  test('API stub never fabricates a current trip or cancellation', () async {
    const api = UnavailableActiveTripRepository();
    await expectLater(api.current(), throwsA(isA<ActiveTripFailure>()));
    await expectLater(api.fetch('x'), throwsA(isA<ActiveTripFailure>()));
    await expectLater(api.cancel('x'), throwsA(isA<ActiveTripFailure>()));
    expect(fixture.store.trips, isEmpty);
  });
  test(
    'a device clock moving backwards does not rewind or crash the engine',
    () async {
      final id = fixture.book().id;
      fixture.advance(3);
      final previous = (await fixture.repository.fetch(id))!;
      fixture.now = fixture.now.subtract(const Duration(seconds: 2));
      expect(await fixture.repository.fetch(id), previous);
      fixture.advance(4);
      expect(
        (await fixture.repository.fetch(id))!.live!.revision,
        greaterThan(previous.live!.revision),
      );
    },
  );
  test(
    'no-driver scenario is terminal and excluded from active history',
    () async {
      final other = ActiveTripFixture(scenario: ActiveTripScenario.noDriver);
      addTearDown(other.dispose);
      final trip = other.book();
      other.advance(2);
      expect(
        (await other.repository.fetch(trip.id))!.status,
        TripStatus.noDriver,
      );
      expect(await other.repository.current(), isNull);
      expect(
        (await MockTripsRepository(
          other.store,
        ).list(filter: TripsFilter.active)).items,
        isEmpty,
      );
      expect(() => ActiveTripScenario.parse('unknown'), throwsArgumentError);
    },
  );
  test(
    'disconnect does not pause the simulated server or regress on reconnect',
    () async {
      final other = ActiveTripFixture(scenario: ActiveTripScenario.disconnect);
      addTearDown(other.dispose);
      final id = other.book().id;
      other.advance(20);
      await expectLater(
        other.repository.fetch(id),
        throwsA(isA<ActiveTripFailure>()),
      );
      expect(other.store.find(id)!.status, TripStatus.completed);
      other.advance(15);
      expect((await other.repository.fetch(id))!.status, TripStatus.completed);
    },
  );
}
