import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_journey_panel.dart';
import 'package:tam_customer/features/home/presentation/pages/home_page.dart';
import 'package:tam_customer/features/maps/presentation/widgets/route_map_view.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_places.dart';
import 'package:tam_customer/features/ride_request/presentation/pages/ride_request_page.dart';
import 'package:tam_customer/shared/domain/trip.dart';

import 'support/customer_app_harness.dart';

void main() {
  testWidgets('confirmed booking stays on the same map and back reaches Home', (
    tester,
  ) async {
    await launchCustomerApp(tester);
    await enterCustomerSession(tester);
    final router = customerRouter(tester);
    RouterCustomerNavigation(router).openRideRequest(
      prefill: TripPrefill(
        pickup: mockRidePlaces[0].location,
        destination: mockRidePlaces[1].location,
      ),
    );
    await tester.pumpAndSettle();
    final map = tester.state(find.byType(RouteMapView));
    final next = find.byKey(const Key('ride-flow-continue'));
    await tester.ensureVisible(next);
    await tester.tap(next);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(ActiveJourneyPanel), findsOneWidget);
    expect(find.byType(RideRequestPage), findsOneWidget);
    expect(
      GoRouterState.of(
        tester.element(find.byType(RideRequestPage)),
      ).matchedLocation,
      AppRoutes.rideRequest,
    );
    expect(tester.state(find.byType(RouteMapView)), same(map));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(RideRequestPage, skipOffstage: false), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
