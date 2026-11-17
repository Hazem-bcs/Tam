import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/core/config/map_configuration.dart';
import 'package:tam_customer/features/maps/presentation/widgets/route_map_view.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_details_route_card.dart';
import 'package:tam_customer/shared/data/mock/seed_trips.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';

import 'support/trips_test_support.dart';

Trip _withPickup(Trip trip, GeoPoint point) => Trip(
  id: trip.id,
  status: trip.status,
  createdAt: trip.createdAt,
  live: trip.live,
  booking: TripBookingInput(
    pickup: TripLocation(label: trip.booking.pickup.label, point: point),
    destination: trip.booking.destination,
    vehicleClassId: trip.booking.vehicleClassId,
    fare: trip.booking.fare,
    scheduledAt: trip.booking.scheduledAt,
  ),
);

void main() {
  test('preview only appears with an available map and real endpoints', () {
    final trip = seedMockTrips().first;
    const vector = MapConfiguration(
      vectorStyleAsset: MapConfiguration.libertyStyleAsset,
    );
    const none = MapConfiguration();
    const raster = MapConfiguration(
      tileUrl: 'https://tiles.example.com/{z}/{x}/{y}.png',
    );

    expect(canPreviewTripRoute(trip, null), isFalse);
    expect(canPreviewTripRoute(trip, none), isFalse);
    expect(canPreviewTripRoute(trip, vector), isTrue);
    expect(canPreviewTripRoute(trip, raster), isTrue);
    expect(
      canPreviewTripRoute(
        _withPickup(trip, GeoPoint(latitude: 0, longitude: 0)),
        vector,
      ),
      isFalse,
    );
    expect(
      canPreviewTripRoute(
        _withPickup(trip, trip.booking.destination.point),
        vector,
      ),
      isFalse,
    );
    expect(
      canPreviewTripRoute(
        _withPickup(trip, GeoPoint(latitude: 90, longitude: 35)),
        vector,
      ),
      isFalse,
    );
  });

  testWidgets('without map provider use full width; never show fake map', (
    tester,
  ) async {
    tripsViewport(tester, const Size(390, 844));
    await tester.pumpWidget(
      tripsTestApp(
        Scaffold(body: TripDetailsRouteCard(trip: seedMockTrips().first)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RouteMapView), findsNothing);
    expect(find.text('المزة، شارع الجلاء'), findsOneWidget);
    expect(find.text('أبو رمانة، شارع الحمراء'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('narrow display with 2x text has no overflow', (tester) async {
    tripsViewport(tester, const Size(320, 700));
    await tester.pumpWidget(
      tripsTestApp(
        Scaffold(
          body: SingleChildScrollView(
            child: TripDetailsRouteCard(trip: seedMockTrips().first),
          ),
        ),
        scale: 2,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RouteMapView), findsNothing);
    expect(find.text('المزة، شارع الجلاء'), findsOneWidget);
    expect(find.text('أبو رمانة، شارع الحمراء'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
