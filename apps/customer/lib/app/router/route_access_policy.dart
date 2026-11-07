import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';

enum RouteAccess { public, authentication, authenticated }

/// Access is keyed by GoRouter's full matched pattern, including parent paths
/// and parameters (for example /ride/:id), rather than the raw URL/query string.
/// Unclassified paths require authentication; new public pages opt in explicitly.
final class RouteAccessPolicy {
  const RouteAccessPolicy({this.routes = appRoutes});

  static const appRoutes = {
    AppRoutes.home: RouteAccess.public,
    AppRoutes.auth: RouteAccess.authentication,
    AppRoutes.otp: RouteAccess.authentication,
    AppRoutes.authStatus: RouteAccess.authentication,
  };

  final Map<String, RouteAccess> routes;

  String? redirect(AuthState auth, Uri location, {String? matchedPath}) {
    final access =
        routes[matchedPath ?? location.path] ?? RouteAccess.authenticated;
    final target = switch (auth.status) {
      AuthStatus.restoring ||
      AuthStatus.sessionUnavailable => AppRoutes.authStatus,
      AuthStatus.signedOut => AppRoutes.auth,
      AuthStatus.awaitingOtp =>
        auth.challenge == null ? AppRoutes.auth : AppRoutes.otp,
      AuthStatus.authenticated ||
      AuthStatus.guest ||
      AuthStatus.localAccess => null,
    };

    if (target != null) {
      if (location.path == target) return null;
      // Carry the original URL through status -> phone -> OTP. The router owns
      // this URL state; AuthCubit remains independent of navigation intent.
      final from = access == RouteAccess.authentication
          ? _safeReturnTo(location.queryParameters[_returnTo])
          : _safeReturnTo(location.toString());
      return Uri(
        path: target,
        queryParameters: from == null || from == AppRoutes.home
            ? null
            : {_returnTo: from},
      ).toString();
    }

    if (access == RouteAccess.authentication) {
      // The resumed URL is checked by this same guard before its page is built.
      // A protected return URL therefore cannot promote a guest/local session.
      return _safeReturnTo(location.queryParameters[_returnTo]) ??
          AppRoutes.home;
    }
    if (access == RouteAccess.authenticated &&
        auth.status != AuthStatus.authenticated) {
      return AppRoutes.home;
    }
    // Public pages and authorized protected pages retain their current URL,
    // history and query/fragment; an unchanged auth status is not a navigation.
    return null;
  }

  static const _returnTo = 'from';

  String? _safeReturnTo(String? value) {
    if (value == null) return null;
    final uri = Uri.tryParse(value);
    if (uri == null) return null;
    final String path;
    try {
      path = Uri.decodeComponent(uri.path);
    } on FormatException {
      return null;
    }
    if (uri.hasScheme ||
        uri.hasAuthority ||
        !path.startsWith('/') ||
        path.startsWith('//') ||
        path.contains('\\') ||
        path.runes.any((char) => char < 32 || char == 127) ||
        path == AppRoutes.auth ||
        path.startsWith('${AppRoutes.auth}/')) {
      return null;
    }
    return uri.toString();
  }
}
