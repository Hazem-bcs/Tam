import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/active_trip/domain/active_trip_repository.dart';
import 'package:tam_customer/features/active_trip/domain/upcoming_trips_repository.dart';
import 'package:tam_customer/features/home/presentation/bloc/home_upcoming_trips_cubit.dart';
import 'package:tam_customer/shared/domain/trip.dart';

import '../active_trip/active_trip_test_support.dart';

final class DelayedUpcoming implements UpcomingTripsRepository {
  final requests = <Completer<List<Trip>>>[];
  final updates = StreamController<void>.broadcast();
  @override
  Stream<void> get changes => updates.stream;
  @override
  Future<List<Trip>> upcoming() {
    final request = Completer<List<Trip>>();
    requests.add(request);
    return request.future;
  }
}

Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  test(
    'home follows cancellation and session reset without losing reservations',
    () async {
      final fixture = ActiveTripFixture();
      final tomorrow = fixture.book(
        scheduledAt: fixture.now.add(const Duration(days: 1)),
      );
      final later = fixture.book(
        scheduledAt: fixture.now.add(const Duration(days: 2)),
      );
      final cubit = HomeUpcomingTripsCubit(fixture.repository);
      await settle();
      expect(cubit.state.trips.map((t) => t.id), [tomorrow.id, later.id]);
      final immediate = fixture.book();
      await settle();
      expect((await fixture.repository.current())!.id, immediate.id);
      expect(cubit.state.trips.map((t) => t.id), [tomorrow.id, later.id]);
      await fixture.repository.cancel(tomorrow.id);
      await settle();
      expect(cubit.state.trips.map((t) => t.id), [later.id]);
      fixture.store.resetSession();
      await settle();
      expect(cubit.state.trips, isEmpty);
      await cubit.close();
      await fixture.dispose();
    },
  );

  test(
    'failed refresh retains marked stale data; older async result cannot resurrect it',
    () async {
      final fixture = ActiveTripFixture();
      final trip = fixture.book(
        scheduledAt: fixture.now.add(const Duration(days: 1)),
      );
      final source = DelayedUpcoming();
      final cubit = HomeUpcomingTripsCubit(source);
      source.requests[0].complete([trip]);
      await settle();
      final older = cubit.load();
      final newer = cubit.load();
      source.requests[2].completeError(
        const ActiveTripFailure('NETWORK_ERROR'),
      );
      await newer;
      expect(cubit.state.failed, isTrue);
      expect(cubit.state.trips.single.id, trip.id);
      source.requests[1].complete([]);
      await older;
      expect(cubit.state.failed, isTrue);
      final retry = cubit.load();
      source.requests[3].complete([]);
      await retry;
      expect(cubit.state.failed, isFalse);
      expect(cubit.state.trips, isEmpty);
      final closing = cubit.load();
      await cubit.close();
      source.requests[4].complete([trip]);
      await closing;
      await source.updates.close();
      await fixture.dispose();
    },
  );
}
