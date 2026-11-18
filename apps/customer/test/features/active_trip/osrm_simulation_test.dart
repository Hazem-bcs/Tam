import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/active_trip/data/mock/mock_active_trip_repository.dart';
import 'package:tam_customer/features/active_trip/domain/active_trip_repository.dart';
import 'package:tam_customer/features/active_trip/presentation/bloc/active_trip_cubit.dart';
import 'package:tam_customer/features/maps/domain/maps_repository.dart';
import 'package:tam_customer/shared/domain/geo_path.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';

import '../maps/maps_test_support.dart';
import 'active_trip_test_support.dart';

Future<void> settleRoads() => Future<void>.delayed(Duration.zero);
void main() {
  late ActiveTripFixture f;
  late MockActiveTripRepository repo;
  late MapsProbe maps;
  setUp(() {
    maps = MapsProbe();
    maps.onRoute = (a, b) async => MapRoute(
      origin: a,
      destination: b,
      points: [
        a,
        GeoPoint(latitude: a.latitude, longitude: b.longitude),
        b,
      ],
      distanceMeters: 1000,
      durationSeconds: 100,
      provider: 'osrm',
    );
    f = ActiveTripFixture(routing: maps);
    repo = f.repository;
  });
  tearDown(() async {
    await f.dispose();
  });
  test(
    'both legs use road geometry, arc distance and heading; no requests per tick',
    () async {
      final booked = f.book();
      await repo.fetch(booked.id);
      await settleRoads();
      f.now = f.now.add(const Duration(seconds: 4));
      var trip = (await repo.fetch(booked.id))!;
      expect(trip.status, TripStatus.driverEnRoute);
      final approach = trip.live!.route!;
      expect(approach.roadAligned, isTrue);
      expect(approach.leg, TrackingRouteLeg.toPickup);
      expect(approach.points.last, booked.booking.pickup.point);
      final path = GeoPath(approach.points);
      expect(
        GeoPath.meters(
          trip.live!.position!.point,
          path.at(path.length / (path.length / 18).ceil()),
        ),
        lessThan(.01),
      );
      expect(
        trip.live!.position!.bearing,
        closeTo(path.headingAt(path.length / (path.length / 18).ceil()), .01),
      );
      f.now = booked.createdAt.add(
        Duration(seconds: 3 + (path.length / 18).ceil()),
      );
      trip = (await repo.fetch(booked.id))!;
      expect(trip.status, TripStatus.driverArrived);
      expect(trip.live!.position!.point, approach.points.last);
      f.now = f.now.add(const Duration(seconds: 3));
      trip = (await repo.fetch(booked.id))!;
      expect(trip.status, TripStatus.inProgress);
      expect(trip.live!.route!.leg, TrackingRouteLeg.toDestination);
      expect(trip.live!.route!.points.last, booked.booking.destination.point);
      expect(maps.routes, 2);
      f.now = f.now.add(
        Duration(
          seconds: (GeoPath(trip.live!.route!.points).length / 18).ceil(),
        ),
      );
      expect((await repo.fetch(booked.id))!.status, TripStatus.completed);
      expect(maps.routes, 2);
    },
  );
  test(
    'slow routes hold departure then start from the first road point',
    () async {
      final gate = Completer<MapRoute>();
      maps.onRoute = (a, b) =>
          maps.routes == 1 ? gate.future : Future.value(routeValue(a, b));
      final booked = f.book();
      await repo.fetch(booked.id);
      f.now = f.now.add(const Duration(seconds: 20));
      final waiting = (await repo.fetch(booked.id))!;
      expect(waiting.status, TripStatus.confirmed);
      expect(waiting.live!.position, isNull);
      final start = GeoPath.mix(
        booked.booking.pickup.point,
        booked.booking.destination.point,
        .5,
      );
      gate.complete(routeValue(start, booked.booking.pickup.point));
      await settleRoads();
      final moving = (await repo.fetch(booked.id))!;
      expect(moving.status, TripStatus.driverEnRoute);
      expect(moving.live!.position!.point, start);
    },
  );
  test(
    'routing outage never uses synthetic path and still permits cancellation',
    () async {
      maps.onRoute = (a, b) async => throw const MapsFailure('ROUTE_NOT_FOUND');
      final booked = f.book();
      await repo.fetch(booked.id);
      await settleRoads();
      f.now = f.now.add(const Duration(seconds: 4));
      await expectLater(
        repo.fetch(booked.id),
        throwsA(
          isA<ActiveTripFailure>().having(
            (f) => f.code,
            'code',
            'ROUTING_UNAVAILABLE',
          ),
        ),
      );
      expect(f.store.find(booked.id)!.status, TripStatus.confirmed);
      expect(f.store.find(booked.id)!.live!.route, isNull);
      expect((await repo.cancel(booked.id)).status, TripStatus.cancelled);
    },
  );
  test(
    'late route response after logout cannot update a reused trip ID',
    () async {
      final gate = Completer<MapRoute>();
      maps.onRoute = (a, b) => gate.future;
      final old = f.book();
      await repo.fetch(old.id);
      repo.resetSession();
      f.store.resetSession();
      gate.complete(
        routeValue(
          GeoPath.mix(
            old.booking.pickup.point,
            old.booking.destination.point,
            .5,
          ),
          old.booking.pickup.point,
        ),
      );
      await settleRoads();
      expect(f.store.find(old.id), isNull);
    },
  );
  test(
    'reopening a previously routed trip catches up without restarting its journey',
    () async {
      final booked = f.book();
      await repo.fetch(booked.id);
      await settleRoads();
      f.now = f.now.add(const Duration(seconds: 4));
      final moving = (await repo.fetch(booked.id))!;
      expect(moving.live!.route!.roadAligned, isTrue);
      await repo.dispose();
      f.now = f.now.add(const Duration(hours: 1));
      final resumed = MockActiveTripRepository(
        f.store,
        routing: maps,
        now: () => f.now,
        autoStart: false,
        timings: ActiveTripFixture.timings,
      );
      addTearDown(resumed.dispose);
      await resumed.fetch(booked.id);
      await settleRoads();
      expect((await resumed.fetch(booked.id))!.status, TripStatus.completed);
    },
  );
  test(
    'routing error keeps the cancellation action available in presentation state',
    () async {
      maps.onRoute = (a, b) async =>
          throw const MapsFailure('SERVICE_UNAVAILABLE');
      final booked = f.book();
      final cubit = ActiveTripCubit(
        repo,
        tripId: booked.id,
        now: () => f.now,
        poll: false,
      );
      addTearDown(cubit.close);
      await settleRoads();
      f.now = f.now.add(const Duration(seconds: 4));
      await cubit.refresh();
      expect(cubit.state.failure, 'ROUTING_UNAVAILABLE');
      expect(cubit.state.offline, isFalse);
      expect(cubit.state.canCancel, isTrue);
      await cubit.cancel();
      expect(cubit.state.trip!.status, TripStatus.cancelled);
    },
  );
}
