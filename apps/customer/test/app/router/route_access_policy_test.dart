import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/app/router/route_access_policy.dart';
import 'package:tam_customer/features/auth/domain/auth_models.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';

const _search = '/search';
const _profile = '/profile';
const _tripPattern = '/ride/:id';
const _policy = RouteAccessPolicy(
  routes: {
    ...RouteAccessPolicy.appRoutes,
    _search: RouteAccess.public,
    _profile: RouteAccess.authenticated,
    _tripPattern: RouteAccess.authenticated,
  },
);

void main() {
  for (final status in [
    AuthStatus.guest,
    AuthStatus.localAccess,
    AuthStatus.authenticated,
  ]) {
    test(
      '$status retains public navigation including its query and fragment',
      () {
        final location = Uri.parse('$_search?query=airport#pickup');
        expect(_policy.redirect(AuthState(status: status), location), isNull);
        expect(
          _policy.redirect(
            AuthState(status: status),
            Uri.parse(AppRoutes.home),
          ),
          isNull,
        );
      },
    );
  }

  test(
    'only real authentication permits protected and unclassified routes',
    () {
      for (final status in [
        AuthStatus.guest,
        AuthStatus.localAccess,
        AuthStatus.authenticated,
      ]) {
        final expected = status == AuthStatus.authenticated
            ? null
            : AppRoutes.home;
        expect(
          _policy.redirect(AuthState(status: status), Uri.parse(_profile)),
          expected,
        );
        expect(
          _policy.redirect(
            AuthState(status: status),
            Uri.parse('/unclassified'),
          ),
          expected,
        );
        expect(
          _policy.redirect(
            AuthState(status: status),
            Uri.parse('/ride/42?source=home'),
            matchedPath: _tripPattern,
          ),
          expected,
        );
      }
    },
  );

  test('signed out entry remembers the requested URL without altering it', () {
    const state = AuthState(status: AuthStatus.signedOut);
    final destination =
        '$_search?query=%D8%AF%D9%85%D8%B4%D9%82&near=1&near=2#pickup';
    final redirect = Uri.parse(
      _policy.redirect(state, Uri.parse(destination))!,
    );
    expect(redirect.path, AppRoutes.auth);
    expect(redirect.queryParameters['from'], destination);
    expect(_policy.redirect(state, redirect), isNull);
    expect(_policy.redirect(state, Uri.parse(AppRoutes.home)), AppRoutes.auth);
  });

  test(
    'restoring and unavailable sessions wait on status with the same intent',
    () {
      for (final status in [
        AuthStatus.restoring,
        AuthStatus.sessionUnavailable,
      ]) {
        final redirect = Uri.parse(
          _policy.redirect(AuthState(status: status), Uri.parse(_profile))!,
        );
        expect(redirect.path, AppRoutes.authStatus);
        expect(redirect.queryParameters['from'], _profile);
        expect(_policy.redirect(AuthState(status: status), redirect), isNull);
        final next = Uri.parse(
          _policy.redirect(
            const AuthState(status: AuthStatus.signedOut),
            redirect,
          )!,
        );
        expect(next.path, AppRoutes.auth);
        expect(next.queryParameters['from'], _profile);
      }
    },
  );

  test(
    'OTP needs a challenge and keeps the original deep link through entry',
    () {
      final phone = Uri(
        path: AppRoutes.auth,
        queryParameters: {'from': _profile},
      );
      final challenge = OtpChallenge(
        id: 'challenge',
        phoneE164: '+963941234567',
        expiresAt: DateTime.utc(2030),
        resendAt: DateTime.utc(2030),
        attemptsRemaining: 5,
      );
      expect(
        _policy.redirect(
          const AuthState(status: AuthStatus.signedOut),
          Uri.parse(AppRoutes.otp),
        ),
        AppRoutes.auth,
      );
      expect(
        _policy.redirect(
          const AuthState(status: AuthStatus.awaitingOtp),
          Uri.parse(AppRoutes.otp),
        ),
        AppRoutes.auth,
      );
      final state = AuthState(
        status: AuthStatus.awaitingOtp,
        challenge: challenge,
      );
      final otp = Uri.parse(_policy.redirect(state, phone)!);
      expect(otp.path, AppRoutes.otp);
      expect(otp.queryParameters['from'], _profile);
      expect(_policy.redirect(state, otp), isNull);
      expect(
        _policy.redirect(
          const AuthState(status: AuthStatus.authenticated),
          otp,
        ),
        _profile,
      );
    },
  );

  test(
    'completed entry leaves auth pages but never promotes local or guest access',
    () {
      for (final status in [
        AuthStatus.guest,
        AuthStatus.localAccess,
        AuthStatus.authenticated,
      ]) {
        for (final path in [
          AppRoutes.auth,
          AppRoutes.otp,
          AppRoutes.authStatus,
        ]) {
          expect(
            _policy.redirect(AuthState(status: status), Uri.parse(path)),
            AppRoutes.home,
          );
          final login = Uri(path: path, queryParameters: {'from': _profile});
          final resumed = _policy.redirect(AuthState(status: status), login)!;
          final result = _policy.redirect(
            AuthState(status: status),
            Uri.parse(resumed),
          );
          expect(
            result,
            status == AuthStatus.authenticated ? isNull : AppRoutes.home,
          );
        }
      }
    },
  );

  for (final from in [
    'https://example.com/profile',
    '//example.com/profile',
    'profile',
    AppRoutes.auth,
    '${AppRoutes.otp}?from=$_profile',
    '/%5Cexample.com',
    '/%2Fexample.com',
    '/auth%2Fotp',
    '/%00profile',
    'http://[',
  ]) {
    test('untrusted or looping return URL is ignored: $from', () {
      final login = Uri(path: AppRoutes.auth, queryParameters: {'from': from});
      expect(
        _policy.redirect(
          const AuthState(status: AuthStatus.authenticated),
          login,
        ),
        AppRoutes.home,
      );
    });
  }

  test('all role and route combinations settle without a redirect loop', () {
    final challenge = OtpChallenge(
      id: 'challenge',
      phoneE164: '+963941234567',
      expiresAt: DateTime.utc(2030),
      resendAt: DateTime.utc(2030),
      attemptsRemaining: 5,
    );
    for (final status in AuthStatus.values) {
      for (final path in [
        AppRoutes.home,
        _search,
        _profile,
        AppRoutes.auth,
        AppRoutes.otp,
        AppRoutes.authStatus,
      ]) {
        final state = AuthState(
          status: status,
          challenge: status == AuthStatus.awaitingOtp ? challenge : null,
        );
        var current = Uri.parse(path);
        final visited = <String>{};
        for (var i = 0; i < 5; i++) {
          expect(
            visited.add(current.toString()),
            isTrue,
            reason: '$status / $path loops at $current',
          );
          final next = _policy.redirect(state, current);
          if (next == null) break;
          current = Uri.parse(next);
        }
        expect(
          _policy.redirect(state, current),
          isNull,
          reason: '$status / $path did not settle',
        );
      }
    }
  });
}
