import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/app/router/route_access_policy.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tam_customer/features/auth/presentation/pages/auth_status_page.dart';
import 'package:tam_customer/features/auth/presentation/pages/otp_auth_page.dart';
import 'package:tam_customer/features/auth/presentation/pages/phone_auth_page.dart';
import 'package:tam_customer/features/home/presentation/pages/home_page.dart';

export 'app_routes.dart';

GoRouter createAppRouter(AuthCubit auth, Listenable refresh) => GoRouter(
  initialLocation: AppRoutes.authStatus,
  refreshListenable: refresh,
  redirect: createAuthRedirect(auth),
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
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
