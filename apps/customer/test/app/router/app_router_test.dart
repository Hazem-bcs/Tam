import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tam_customer/app/app.dart';
import 'package:tam_customer/app/router/app_router.dart';
import 'package:tam_customer/app/router/route_access_policy.dart';
import 'package:tam_customer/features/auth/data/memory_auth_session_store.dart';
import 'package:tam_customer/features/auth/domain/auth_models.dart';
import 'package:tam_customer/features/auth/domain/auth_repository.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tam_customer/features/auth/presentation/pages/phone_auth_page.dart';

import '../../support/fake_auth_repository.dart';

abstract final class _Routes {
  static const search = '/search';
  static const searchResult = '/search/:place';
  static const profile = '/profile';
  static const trip = '/ride/:id';
  static const tripLink = '/ride/42?source=deep#fare';
}

void main() {
  for (final status in [
    AuthStatus.guest,
    AuthStatus.localAccess,
    AuthStatus.authenticated,
  ]) {
    testWidgets(
      '$status can push a public page and return without a home redirect',
      (tester) async {
        final h = _Harness(localEntry: status == AuthStatus.localAccess);
        addTearDown(h.dispose);
        await h.enter(status);
        await tester.pumpWidget(h.app);
        await tester.pumpAndSettle();
        unawaited(h.router.push<void>('${_Routes.search}?q=airport#pickup'));
        await tester.pumpAndSettle();
        expect(find.text('search'), findsOneWidget);
        expect(h.location, '${_Routes.search}?q=airport#pickup');
        h.router.pop();
        await tester.pumpAndSettle();
        expect(find.text('home'), findsOneWidget);
        h.router.go('${_Routes.search}/airport');
        await tester.pumpAndSettle();
        expect(find.text('result:airport'), findsOneWidget);
        expect(h.location, '${_Routes.search}/airport');
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets(
      '$status protected deep link enforces real authentication before building',
      (tester) async {
        final h = _Harness(localEntry: status == AuthStatus.localAccess);
        addTearDown(h.dispose);
        await h.enter(status);
        await tester.pumpWidget(h.app);
        await tester.pumpAndSettle();
        h.router.go(_Routes.tripLink);
        await tester.pumpAndSettle();
        if (status == AuthStatus.authenticated) {
          expect(find.text('trip:42'), findsOneWidget);
          expect(h.location, _Routes.tripLink);
          expect(h.protectedBuilds, greaterThan(0));
        } else {
          expect(find.text('home'), findsOneWidget);
          expect(h.protectedBuilds, 0);
          expect(h.auth.state.status, status);
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets(
    'signed out deep link resumes its exact URL after phone and OTP',
    (tester) async {
      final h = _Harness(initialLocation: _Routes.tripLink);
      addTearDown(h.dispose);
      await h.auth.restoreSession();
      await tester.pumpWidget(h.app);
      await tester.pumpAndSettle();
      expect(find.text('phone'), findsOneWidget);
      expect(
        h.router.routeInformationProvider.value.uri.queryParameters['from'],
        _Routes.tripLink,
      );
      await h.auth.requestOtp('0941234567');
      await tester.pumpAndSettle();
      expect(find.text('otp'), findsOneWidget);
      expect(
        h.router.routeInformationProvider.value.uri.queryParameters['from'],
        _Routes.tripLink,
      );
      await h.auth.verifyOtp(h.repository.debugOtpCode!);
      await tester.pumpAndSettle();
      expect(find.text('trip:42'), findsOneWidget);
      expect(h.location, _Routes.tripLink);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final local in [false, true]) {
    testWidgets(
      '${local ? 'local' : 'guest'} entry resumes public deep links without OTP',
      (tester) async {
        const destination =
            '${_Routes.search}?q=%D8%AF%D9%85%D8%B4%D9%82&near=1&near=2#pickup';
        final h = _Harness(localEntry: local, initialLocation: destination);
        addTearDown(h.dispose);
        await h.auth.restoreSession();
        await tester.pumpWidget(h.app);
        await tester.pumpAndSettle();
        expect(find.text('phone'), findsOneWidget);
        if (local) {
          await h.auth.requestOtp('963941234567');
        } else {
          await h.auth.continueAsGuest();
        }
        await tester.pumpAndSettle();
        expect(find.text('search'), findsOneWidget);
        expect(h.location, destination);
        expect(
          h.auth.state.status,
          local ? AuthStatus.localAccess : AuthStatus.guest,
        );
        expect(h.auth.state.user, isNull);
        expect(h.auth.state.challenge, isNull);
        expect(find.text('otp'), findsNothing);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets(
      '${local ? 'local' : 'guest'} entry cannot resume a protected login return',
      (tester) async {
        final h = _Harness(localEntry: local, initialLocation: _Routes.profile);
        addTearDown(h.dispose);
        await h.auth.restoreSession();
        await tester.pumpWidget(h.app);
        await tester.pumpAndSettle();
        if (local) {
          await h.auth.requestOtp('0941234567');
        } else {
          await h.auth.continueAsGuest();
        }
        await tester.pumpAndSettle();
        expect(find.text('home'), findsOneWidget);
        expect(h.protectedBuilds, 0);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets(
    'restoring a saved session resumes the protected startup deep link',
    (tester) async {
      final store = _PendingSessionStore();
      final h = _Harness(store: store, initialLocation: _Routes.profile);
      addTearDown(h.dispose);
      await tester.pumpWidget(h.app);
      await tester.pumpAndSettle();
      expect(find.text('session'), findsOneWidget);
      final restoring = h.auth.restoreSession();
      final challenge = await h.repository.requestOtp(
        phoneE164: '+963941234567',
      );
      final result = await h.repository.verifyOtp(
        challengeId: challenge.id,
        code: h.repository.debugOtpCode!,
      );
      store.pending.complete(result.session);
      await restoring;
      await tester.pumpAndSettle();
      expect(find.text('profile'), findsOneWidget);
      expect(h.location, _Routes.profile);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('unavailable restoration keeps the destination through retry', (
    tester,
  ) async {
    final store = _PendingSessionStore();
    final h = _Harness(store: store, initialLocation: _Routes.search);
    addTearDown(h.dispose);
    await tester.pumpWidget(h.app);
    await tester.pumpAndSettle();
    final restoring = h.auth.restoreSession();
    store.pending.completeError(
      const AuthFailure(
        code: 'NETWORK_UNAVAILABLE',
        message: BilingualMessage(ar: 'غير متصل', en: 'Offline'),
      ),
    );
    await restoring;
    await tester.pumpAndSettle();
    expect(h.auth.state.status, AuthStatus.sessionUnavailable);
    expect(find.text('session'), findsOneWidget);
    expect(
      h.router.routeInformationProvider.value.uri.queryParameters['from'],
      _Routes.search,
    );
    store.pending = Completer<AuthSession?>()..complete(null);
    await h.auth.restoreSession();
    await tester.pumpAndSettle();
    expect(find.text('phone'), findsOneWidget);
    await h.auth.continueAsGuest();
    await tester.pumpAndSettle();
    expect(h.location, _Routes.search);
    expect(find.text('search'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('session refresh keeps the router, public page and form draft', (
    tester,
  ) async {
    final h = _Harness(initialLocation: _Routes.search);
    addTearDown(h.dispose);
    await h.enter(AuthStatus.authenticated);
    final originalRouter = h.router;
    await tester.pumpWidget(h.app);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('search-draft')),
      'Airport terminal',
    );
    await h.auth.restoreSession();
    await tester.pumpAndSettle();
    expect(identical(h.router, originalRouter), isTrue);
    expect(h.location, _Routes.search);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      'Airport terminal',
    );
    unawaited(h.router.push<void>(AppRoutes.home));
    await tester.pumpAndSettle();
    h.router.pop();
    await tester.pumpAndSettle();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      'Airport terminal',
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final status in [
    AuthStatus.guest,
    AuthStatus.localAccess,
    AuthStatus.authenticated,
  ]) {
    testWidgets('$status logout updates the current public/protected route', (
      tester,
    ) async {
      final initial = status == AuthStatus.authenticated
          ? _Routes.profile
          : _Routes.search;
      final h = _Harness(localEntry: status == AuthStatus.localAccess);
      addTearDown(h.dispose);
      await h.enter(status);
      await tester.pumpWidget(h.app);
      await tester.pumpAndSettle();
      unawaited(h.router.push<void>(initial));
      await tester.pumpAndSettle();
      await h.auth.logout();
      await tester.pumpAndSettle();
      expect(find.text('phone'), findsOneWidget);
      expect(h.router.routeInformationProvider.value.uri.path, AppRoutes.auth);
      expect(h.auth.state.status, AuthStatus.signedOut);
      expect(h.router.canPop(), isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets(
    'production router blocks bare OTP and ignores an external return URL',
    (tester) async {
      await tester.pumpWidget(
        TamApp(
          authRepository: FakeAuthRepository(latency: Duration.zero),
          sessionStore: MemoryAuthSessionStore(),
          temporaryPhoneEntryEnabled: true,
        ),
      );
      await tester.pumpAndSettle();
      final router = GoRouter.of(tester.element(find.byType(PhoneAuthPage)));
      router.go(AppRoutes.otp);
      await tester.pumpAndSettle();
      expect(find.byType(PhoneAuthPage), findsOneWidget);
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.auth);
      router.go(
        Uri(
          path: AppRoutes.auth,
          queryParameters: {'from': 'https://example.com/profile'},
        ).toString(),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('auth-phone')), '0941234567');
      await tester.ensureVisible(find.text('متابعة'));
      await tester.tap(find.text('متابعة'));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.home);
      expect(find.text('رقم هاتفك'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}

final class _Harness {
  _Harness({
    bool localEntry = false,
    AuthSessionStore? store,
    String initialLocation = AppRoutes.home,
  }) {
    repository = FakeAuthRepository(latency: Duration.zero);
    auth = AuthCubit(
      repository,
      store ?? MemoryAuthSessionStore(),
      temporaryPhoneEntryEnabled: localEntry,
    );
    refresh = AuthRouterRefresh(auth);
    router = GoRouter(
      initialLocation: initialLocation,
      overridePlatformDefaultLocation: true,
      refreshListenable: refresh,
      redirect: createAuthRedirect(
        auth,
        policy: const RouteAccessPolicy(
          routes: {
            ...RouteAccessPolicy.appRoutes,
            _Routes.search: RouteAccess.public,
            _Routes.searchResult: RouteAccess.public,
            _Routes.profile: RouteAccess.authenticated,
            _Routes.trip: RouteAccess.authenticated,
          },
        ),
      ),
      routes: [
        for (final route in {
          AppRoutes.home: 'home',
          AppRoutes.auth: 'phone',
          AppRoutes.otp: 'otp',
          AppRoutes.authStatus: 'session',
        }.entries)
          GoRoute(
            path: route.key,
            builder: (_, _) => Scaffold(body: Text(route.value)),
          ),
        GoRoute(
          path: _Routes.search,
          builder: (_, _) => const Scaffold(
            body: Column(
              children: [
                Text('search'),
                TextField(key: Key('search-draft')),
              ],
            ),
          ),
        ),
        GoRoute(
          path: _Routes.searchResult,
          builder: (_, state) =>
              Scaffold(body: Text('result:${state.pathParameters['place']}')),
        ),
        GoRoute(
          path: _Routes.profile,
          builder: (_, _) {
            protectedBuilds++;
            return const Scaffold(body: Text('profile'));
          },
        ),
        GoRoute(
          path: _Routes.trip,
          builder: (_, state) {
            protectedBuilds++;
            return Scaffold(body: Text('trip:${state.pathParameters['id']}'));
          },
        ),
      ],
    );
  }

  late final FakeAuthRepository repository;
  late final AuthCubit auth;
  late final AuthRouterRefresh refresh;
  late final GoRouter router;
  int protectedBuilds = 0;
  String get location => router.state.uri.toString();
  Widget get app => MaterialApp.router(routerConfig: router);

  Future<void> enter(AuthStatus status) async {
    await auth.restoreSession();
    if (status == AuthStatus.guest) {
      await auth.continueAsGuest();
    } else {
      await auth.requestOtp('0941234567');
      if (status == AuthStatus.authenticated) {
        await auth.verifyOtp(repository.debugOtpCode!);
      }
    }
  }

  Future<void> dispose() async {
    router.dispose();
    refresh.dispose();
    await auth.close();
  }
}

final class _PendingSessionStore implements AuthSessionStore {
  Completer<AuthSession?> pending = Completer<AuthSession?>();
  @override
  Future<AuthSession?> read() => pending.future;
  @override
  Future<void> write(AuthSession session) async {}
  @override
  Future<void> clear() async {}
}
