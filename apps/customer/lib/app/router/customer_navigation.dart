import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// Presentation callbacks; domain code must not import app navigation.
abstract interface class CustomerNavigation {
  void openAccountPhone();
  void openAccountDeletion();
  void openDriverContact(String tripId, String driverId);
  void openHome();
  void openRideRequest({TripPrefill? prefill});
  void openTrips();
  void openTrip(String id);
  void openNotifications();
  void openSettings();
  void openAddresses();
  void openActiveTrip({String? id, bool replaceCurrent = false});
  void openChat(String tripId);
  void openCompletion(String tripId);
  void openSupport({String? tripId});
  void openTerms();
  void openPrivacy();
}

final class RouterCustomerNavigation implements CustomerNavigation {
  const RouterCustomerNavigation(this.router);
  final GoRouter router;
  @override
  void openAccountPhone() =>
      unawaited(router.push<void>(AppRoutes.changePhone));
  @override
  void openAccountDeletion() =>
      unawaited(router.push<void>(AppRoutes.deleteAccount));
  @override
  void openDriverContact(String tripId, String driverId) => unawaited(
    router.push<void>(AppRoutes.driverContactLocation(tripId, driverId)),
  );
  @override
  void openCompletion(String tripId) =>
      unawaited(router.push<void>(AppRoutes.completionLocation(tripId)));
  @override
  void openSupport({String? tripId}) => unawaited(
    router.push<void>(
      tripId == null
          ? AppRoutes.support
          : AppRoutes.supportNewLocation(tripId: tripId),
    ),
  );
  @override
  void openTerms() => unawaited(router.push<void>(AppRoutes.terms));
  @override
  void openPrivacy() => unawaited(router.push<void>(AppRoutes.privacy));
  @override
  void openChat(String tripId) =>
      unawaited(router.push<void>(AppRoutes.chatLocation(tripId)));
  @override
  void openActiveTrip({String? id, bool replaceCurrent = false}) {
    final location = id == null
        ? AppRoutes.activeTrip
        : AppRoutes.activeTripLocation(id);
    unawaited(
      replaceCurrent
          ? router.pushReplacement<void>(location)
          : router.push<void>(location),
    );
  }

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
  @override
  void openAddresses() => unawaited(router.push<void>(AppRoutes.addresses));
}
