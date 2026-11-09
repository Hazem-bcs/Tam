import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:tam_customer/app/locale/app_locale_controller.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/router/route_access_policy.dart';
import 'package:tam_customer/core/config/app_config.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/features/active_trip/active_trip_entry.dart';
import 'package:tam_customer/features/active_trip/domain/active_trip_repository.dart';
import 'package:tam_customer/features/addresses/addresses_entry.dart';
import 'package:tam_customer/features/addresses/domain/addresses_repository.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tam_customer/features/auth/presentation/pages/auth_status_page.dart';
import 'package:tam_customer/features/auth/presentation/pages/otp_auth_page.dart';
import 'package:tam_customer/features/auth/presentation/pages/phone_auth_page.dart';
import 'package:tam_customer/features/home/home_entry.dart';
import 'package:tam_customer/features/notifications/domain/notifications_repository.dart';
import 'package:tam_customer/features/notifications/notifications_entry.dart';
import 'package:tam_customer/features/ride_request/ride_request_entry.dart';
import 'package:tam_customer/features/settings/settings_entry.dart';
import 'package:tam_customer/features/trips/trips_entry.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/trip.dart';

export 'app_routes.dart';

GoRouter createAppRouter(
  AuthCubit auth,
  Listenable refresh, {
  required NotificationsRepository notifications,
  required AddressesRepository addresses,
  required ActiveTripRepository activeTrips,
  required AddressPlaceSearch Function(String languageCode) addressPlaceSearch,
  FeatureDataModes dataModes = const FeatureDataModes(),
  MockTripStore? mockTrips,
  AppLocaleController? locale,
  DateTime Function()? clock,
}) {
  final trips = mockTrips ?? MockTripStore();
  final language = locale ?? AppLocaleController();
  CustomerNavigation navigation(BuildContext context) =>
      RouterCustomerNavigation(GoRouter.of(context));
  String? phone() => auth.state.localPhoneE164 ?? auth.state.user?.phoneE164;
  return GoRouter(
    initialLocation: AppRoutes.authStatus,
    refreshListenable: refresh,
    redirect: createAuthRedirect(
      auth,
      policy: RouteAccessPolicy.forFeatures(dataModes),
    ),
    routes: [
      for (final path in [AppRoutes.activeTrip, AppRoutes.activeTripDetails])
        GoRoute(
          path: path,
          builder: (context, state) => buildActiveTripFeature(
            repository: activeTrips,
            navigation: navigation(context),
            policy: AppConfig.activeTripPolicy,
            now: clock,
            tripId: state.pathParameters['tripId'],
          ),
        ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => buildHomeFeature(
          context,
          navigation: navigation(context),
          dataMode: dataModes.forFeature(CustomerFeature.home),
          phoneE164: phone(),
          logout: auth.logout,
          unreadCountSource: notifications,
        ),
      ),
      GoRoute(
        path: AppRoutes.rideRequest,
        builder: (context, state) => buildRideRequestFeature(
          context,
          navigation: navigation(context),
          dataMode: dataModes.forFeature(CustomerFeature.rideRequest),
          mockTrips: trips,
          addresses: addresses,
          prefill: state.extra is TripPrefill
              ? state.extra as TripPrefill
              : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.trips,
        builder: (context, state) => buildTripsFeature(
          context,
          navigation: navigation(context),
          dataMode: dataModes.forFeature(CustomerFeature.trips),
          mockTrips: trips,
        ),
      ),
      GoRoute(
        path: AppRoutes.tripDetails,
        builder: (context, state) => buildTripsFeature(
          context,
          navigation: navigation(context),
          dataMode: dataModes.forFeature(CustomerFeature.trips),
          mockTrips: trips,
          tripId: state.pathParameters['tripId'],
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => buildNotificationsFeature(
          context,
          navigation: navigation(context),
          repository: notifications,
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => buildSettingsFeature(
          context,
          navigation: navigation(context),
          dataMode: dataModes.forFeature(CustomerFeature.settings),
          locale: language,
          phoneE164: phone(),
          logout: auth.logout,
        ),
      ),
      GoRoute(
        path: AppRoutes.addresses,
        builder: (context, state) => buildAddressesFeature(
          context,
          repository: addresses,
          onAdd: () =>
              unawaited(GoRouter.of(context).push(AppRoutes.addAddress)),
          onEdit: (id) => unawaited(
            GoRouter.of(context).push(AppRoutes.addressEditLocation(id)),
          ),
          onBack: () => GoRouter.of(context).go(AppRoutes.home),
        ),
      ),
      GoRoute(
        path: AppRoutes.addAddress,
        builder: (context, state) => buildAddressEditorFeature(
          context,
          repository: addresses,
          places: addressPlaceSearch(
            Localizations.localeOf(context).languageCode,
          ),
          onBack: () => GoRouter.of(context).go(AppRoutes.addresses),
        ),
      ),
      GoRoute(
        path: AppRoutes.editAddress,
        builder: (context, state) => buildAddressEditorFeature(
          context,
          repository: addresses,
          id: state.pathParameters['addressId'],
          places: addressPlaceSearch(
            Localizations.localeOf(context).languageCode,
          ),
          onBack: () => GoRouter.of(context).go(AppRoutes.addresses),
        ),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const PhoneAuthPage(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) => const OtpAuthPage(),
      ),
      GoRoute(
        path: AppRoutes.authStatus,
        builder: (context, state) => const AuthStatusPage(),
      ),
    ],
  );
}

/// Shared guard wiring for app routes and isolated feature-route tests.
GoRouterRedirect createAuthRedirect(
  AuthCubit auth, {
  RouteAccessPolicy policy = const RouteAccessPolicy(),
}) =>
    (context, route) =>
        policy.redirect(auth.state, route.uri, matchedPath: route.fullPath);

/// Owns its subscription; the app disposes this together with its router.
final class AuthRouterRefresh extends ChangeNotifier {
  AuthRouterRefresh(AuthCubit auth) {
    _subscription = auth.stream
        .map((state) => state.status)
        .distinct()
        .listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthStatus> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
