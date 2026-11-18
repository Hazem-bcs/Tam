import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/core/config/map_configuration.dart';
import 'package:tam_customer/features/active_trip/presentation/bloc/active_trip_state.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_journey_map.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_tracking_geometry.dart';
import 'package:tam_customer/features/maps/domain/maps_repository.dart';
import 'package:tam_customer/features/maps/maps_dependencies.dart';
import 'package:tam_customer/features/maps/presentation/maps_scope.dart';
import 'package:tam_customer/features/maps/presentation/widgets/route_map_view.dart';
import 'package:tam_customer/features/maps/presentation/widgets/tam_map_canvas.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';
import '../trips/support/trips_test_support.dart';
import 'active_trip_test_support.dart';

Trip _snapshot(
  Trip trip, {
  bool roadAligned = true,
  int eta = 99,
  int revision = 1,
  TrackingRouteLeg leg = TrackingRouteLeg.toPickup,
  TripStatus status = TripStatus.driverEnRoute,
}) {
  final route = TripTrackingRoute(
    id: 'road-1',
    leg: leg,
    roadAligned: roadAligned,
    points: [trip.booking.destination.point, trip.booking.pickup.point],
  );
  return trip.withLive(
    status,
    TripLiveDetails(
      revision: revision,
      updatedAt: trip.createdAt.add(Duration(seconds: revision)),
      statusChangedAt: trip.createdAt,
      etaSeconds: eta,
      route: route,
      position: DriverPosition(
        point: trip.booking.destination.point,
        recordedAt: trip.createdAt.add(Duration(seconds: revision)),
      ),
    ),
  );
}

void main() {
  test(
    'legacy synthetic geometry cannot suppress the configured real route lookup',
    () async {
      final fixture = ActiveTripFixture();
      addTearDown(fixture.dispose);
      final trip = fixture.book();
      expect(
        activeTrackingGeometry(_snapshot(trip, roadAligned: false)),
        isNull,
      );
      final road = activeTrackingGeometry(_snapshot(trip));
      expect(road, isNotNull);
      expect(road!.points.last, trip.booking.pickup.point);
      expect(road.roadAligned, isTrue);
      expect(activeTrackingGeometry(trip), isNull);
      expect(
        activeTrackingGeometry(
          _snapshot(trip, leg: TrackingRouteLeg.toDestination),
        ),
        isNull,
      );
      expect(
        activeTrackingGeometry(_snapshot(trip, status: TripStatus.completed)),
        isNull,
      );
      expect(
        activeTrackingGeometry(_snapshot(trip, status: TripStatus.inProgress)),
        isNull,
      );
    },
  );
  testWidgets(
    'unusable tracking falls back once to real routing and supplies the canvas',
    (tester) async {
      final fixture = ActiveTripFixture();
      addTearDown(fixture.dispose);
      final maps = _RoadRepository();
      final inset = ValueNotifier(0.0);
      addTearDown(inset.dispose);
      await tester.pumpWidget(
        tripsTestApp(
          MapsScope(
            dependencies: MapsDependencies(
              configuration: const MapConfiguration(),
              repository: maps,
              deviceLocation: _NoLocation(),
            ),
            child: SizedBox(
              height: 400,
              child: ActiveJourneyMap(
                state: ActiveTripState(
                  trip: _snapshot(fixture.book(), roadAligned: false),
                ),
                bottomInset: inset,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(maps.calls, 1);
      final canvas = tester.widget<TamMapCanvas>(find.byType(TamMapCanvas));
      expect(canvas.route, isNotNull);
      expect(canvas.route!.roadAligned, isTrue);
      expect(canvas.route!.provider, 'test-road');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  test(
    'position ticks avoid panel rebuilds; ETA minute/status/error changes remain visible',
    () async {
      final fixture = ActiveTripFixture();
      addTearDown(fixture.dispose);
      final trip = fixture.book();
      final before = ActiveTripState(
        phase: ActiveTripPhase.ready,
        trip: _snapshot(trip),
      );
      final tick = before.copyWith(trip: _snapshot(trip, eta: 98, revision: 2));
      expect(activeJourneyPanelChanged(before, tick), isFalse);
      expect(
        activeJourneyPanelChanged(
          before,
          tick.copyWith(trip: _snapshot(trip, eta: 60)),
        ),
        isTrue,
      );
      expect(
        activeJourneyPanelChanged(before, tick.copyWith(offline: true)),
        isTrue,
      );
      expect(
        activeJourneyPanelChanged(before, tick.copyWith(cancelling: true)),
        isTrue,
      );
      expect(
        activeJourneyPanelChanged(
          before,
          tick.copyWith(failure: 'ROUTING_UNAVAILABLE'),
        ),
        isTrue,
      );
      expect(
        activeJourneyPanelChanged(
          before,
          tick.copyWith(
            trip: _snapshot(trip, status: TripStatus.driverArrived),
          ),
        ),
        isTrue,
      );
    },
  );
  testWidgets(
    'mounted map and converted geometry survive driver updates and reject old phase',
    (tester) async {
      final fixture = ActiveTripFixture();
      addTearDown(fixture.dispose);
      final trip = fixture.book();
      final inset = ValueNotifier(0.0);
      addTearDown(inset.dispose);
      Future<void> show(Trip snapshot) async {
        await tester.pumpWidget(
          tripsTestApp(
            SizedBox(
              height: 400,
              child: ActiveJourneyMap(
                state: ActiveTripState(trip: snapshot),
                bottomInset: inset,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await show(_snapshot(trip));
      final mountedMap = tester.state(find.byType(RouteMapView));
      final first = tester
          .widget<RouteMapView>(find.byType(RouteMapView))
          .trackingRoute;
      await show(_snapshot(trip, eta: 98, revision: 2));
      expect(
        identical(tester.state(find.byType(RouteMapView)), mountedMap),
        isTrue,
      );
      expect(
        identical(
          tester.widget<RouteMapView>(find.byType(RouteMapView)).trackingRoute,
          first,
        ),
        isTrue,
      );
      await show(_snapshot(trip, status: TripStatus.inProgress));
      expect(
        tester.widget<RouteMapView>(find.byType(RouteMapView)).trackingRoute,
        isNull,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}

final class _RoadRepository implements MapsRepository {
  int calls = 0;
  @override
  Future<MapRoute> route(GeoPoint origin, GeoPoint destination) async {
    calls++;
    return MapRoute(
      origin: origin,
      destination: destination,
      points: [origin, destination],
      distanceMeters: 1000,
      durationSeconds: 60,
      provider: 'test-road',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _NoLocation implements DeviceLocation {
  @override
  Future<GeoPoint> locate({bool requireFresh = false}) =>
      throw UnimplementedError();
}
