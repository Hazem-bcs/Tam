import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/active_trip/domain/active_trip_repository.dart';
import 'package:tam_customer/features/active_trip/presentation/bloc/active_trip_cubit.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';
import 'active_trip_test_support.dart';

Future<void> flushActive() => Future<void>.delayed(Duration.zero);
Trip revised(Trip trip, int revision, {TripStatus? status}) => trip.withLive(
  status ?? trip.status,
  TripLiveDetails(
    revision: revision,
    updatedAt: trip.live!.updatedAt,
    statusChangedAt: trip.live!.statusChangedAt,
    driver: trip.live!.driver,
    position: trip.live!.position,
    etaSeconds: trip.live!.etaSeconds,
  ),
);

void main() {
  late ActiveTripFixture fixture;
  late _Source source;
  late ActiveTripCubit cubit;
  setUp(() async {
    fixture = ActiveTripFixture();
    final trip = fixture.book();
    fixture.advance(3);
    source = _Source((await fixture.repository.fetch(trip.id))!);
    cubit = ActiveTripCubit(
      source,
      tripId: trip.id,
      poll: false,
      now: () => fixture.now,
    );
    await flushActive();
  });
  tearDown(() async {
    await cubit.close();
    await source.events.close();
    await fixture.dispose();
  });
  test(
    'offline preserves cached state and reconnect fetches the latest revision',
    () async {
      final old = cubit.state.trip;
      source.fail = true;
      await cubit.refresh();
      expect(cubit.state.trip, old);
      expect(cubit.state.offline, isTrue);
      expect(cubit.state.canCancel, isFalse);
      source.fail = false;
      source.value = revised(source.value!, 8);
      await cubit.refresh();
      expect(cubit.state.offline, isFalse);
      expect(cubit.state.trip!.live!.revision, 8);
      expect(cubit.state.canCancel, isTrue);
    },
  );
  test(
    'stale and contradictory responses cannot overwrite a newer snapshot',
    () async {
      source.value = revised(source.value!, 8);
      await cubit.refresh();
      source.value = revised(source.value!, 7);
      await cubit.refresh();
      expect(cubit.state.trip!.live!.revision, 8);
      source.value = revised(source.value!, 8, status: TripStatus.inProgress);
      await cubit.refresh();
      expect(cubit.state.failure, 'INVALID_RESPONSE');
      expect(cubit.state.trip!.status, TripStatus.driverEnRoute);
    },
  );
  test(
    'late read cannot restore the state preceding a successful cancellation',
    () async {
      final pending = source.nextRead = Completer<Trip?>();
      final old = source.value!;
      final read = cubit.refresh();
      await cubit.cancel();
      expect(cubit.state.trip!.status, TripStatus.cancelled);
      pending.complete(old);
      await read;
      expect(cubit.state.trip!.status, TripStatus.cancelled);
      expect(cubit.state.cancelUncertain, isFalse);
    },
  );
  test(
    'uncertain cancellation blocks rebooking until same-id retry resolves',
    () async {
      source.loseCancellation = true;
      await cubit.cancel();
      expect(cubit.state.cancelUncertain, isTrue);
      expect(cubit.state.canRebook, isFalse);
      await cubit.cancel();
      expect(cubit.state.trip!.status, TripStatus.cancelled);
      expect(cubit.state.cancelUncertain, isFalse);
      expect(source.cancelIds, [source.value!.id, source.value!.id]);
    },
  );
  test(
    'a non-cancelled mutation response is uncertain and cannot claim success',
    () async {
      source.badCancellation = true;
      await cubit.cancel();
      expect(cubit.state.cancelUncertain, isTrue);
      expect(cubit.state.actionFailure, 'INVALID_RESPONSE');
      expect(cubit.state.trip!.status, TripStatus.driverEnRoute);
    },
  );
  test('a fresh terminal read resolves a lost cancellation response', () async {
    source.loseCancellation = true;
    await cubit.cancel();
    expect(cubit.state.cancelUncertain, isTrue);
    await cubit.refresh();
    expect(cubit.state.trip!.status, TripStatus.cancelled);
    expect(cubit.state.cancelUncertain, isFalse);
    expect(cubit.state.actionFailure, isNull);
  });
  test(
    'fresh connection does not make an old driver coordinate current',
    () async {
      fixture.now = fixture.now.add(const Duration(seconds: 40));
      cubit.checkFreshness();
      expect(cubit.state.offline, isTrue);
      expect(cubit.state.positionStale, isTrue);
      await cubit.refresh();
      expect(cubit.state.offline, isFalse);
      expect(cubit.state.positionStale, isTrue);
    },
  );
  testWidgets('polling recovers updates even without an invalidation event', (
    tester,
  ) async {
    final pollingSource = _Source(source.value);
    final polled = ActiveTripCubit(
      pollingSource,
      tripId: source.value!.id,
      now: () => fixture.now,
      policy: const ActiveTripPolicy(pollInterval: Duration(seconds: 1)),
    );
    await tester.pump();
    pollingSource.value = revised(pollingSource.value!, 10);
    fixture.now = fixture.now.add(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(polled.state.trip!.live!.revision, 10);
    await tester.runAsync(polled.close);
    expect(polled.isClosed, isTrue);
    await tester.runAsync(pollingSource.events.close);
  });
  test(
    'read failure and missing trip are distinct from no active trip',
    () async {
      source.value = null;
      await cubit.refresh();
      expect(cubit.state.phase, ActiveTripPhase.empty);
      expect(cubit.state.trip, isNull);
      source.fail = true;
      await cubit.refresh();
      expect(cubit.state.phase, ActiveTripPhase.failed);
    },
  );
  test('closed cubit ignores completion and unregisters updates', () async {
    final pending = source.nextRead = Completer<Trip?>();
    final read = cubit.refresh();
    await cubit.close();
    pending.complete(source.value);
    await read;
    source.events.add(null);
    await flushActive();
    expect(cubit.isClosed, isTrue);
  });
}

final class _Source implements ActiveTripRepository {
  _Source(this.value);
  Trip? value;
  bool fail = false, loseCancellation = false, badCancellation = false;
  final events = StreamController<void>.broadcast(sync: true);
  final cancelIds = <String>[];
  Completer<Trip?>? nextRead;
  @override
  Future<Trip?> fetch(String id) {
    final pending = nextRead;
    nextRead = null;
    if (pending != null) return pending.future;
    if (fail) return Future.error(const ActiveTripFailure('NETWORK_ERROR'));
    return Future.value(value);
  }

  @override
  Future<Trip?> current() => fetch('current');
  @override
  Future<Trip> cancel(String id) async {
    cancelIds.add(id);
    if (badCancellation) return value!;
    value = revised(
      value!,
      value!.live!.revision + 1,
      status: TripStatus.cancelled,
    );
    if (loseCancellation) {
      loseCancellation = false;
      throw const ActiveTripFailure('NETWORK_ERROR');
    }
    return value!;
  }

  @override
  Stream<void> get changes => events.stream;
}
