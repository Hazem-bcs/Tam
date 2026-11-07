import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// Presentation callbacks; domain code must not import app navigation.
abstract interface class CustomerNavigation {
  void openHome();
  void openRideRequest({TripPrefill? prefill});
  void openTrips();
  void openTrip(String id);
  void openNotifications();
  void openSettings();
}

final class RouterCustomerNavigation implements CustomerNavigation {
  const RouterCustomerNavigation(this.router);
  final GoRouter router;
  @override
  void openHome() => router.go(AppRoutes.home);
  @override
  void openRideRequest({TripPrefill? prefill}) =>
      unawaited(router.push<void>(AppRoutes.rideRequest, extra: prefill));
  @override
  void openTrips() => unawaited(router.push<void>(AppRoutes.trips));
  @override
  void openTrip(String id) =>
      unawaited(router.push<void>(AppRoutes.tripLocation(id)));
  @override
  void openNotifications() =>
      unawaited(router.push<void>(AppRoutes.notifications));
  @override
  void openSettings() => unawaited(router.push<void>(AppRoutes.settings));
}
