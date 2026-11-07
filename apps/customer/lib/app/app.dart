import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:tam_customer/app/di/service_locator.dart';
import 'package:tam_customer/app/locale/app_locale_controller.dart';
import 'package:tam_customer/app/router/app_router.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/core/config/app_config.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/features/auth/auth_dependencies.dart';
import 'package:tam_customer/features/auth/domain/auth_repository.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/data/mock/seed_trips.dart';

class TamApp extends StatefulWidget {
  const TamApp({
    super.key,
    this.authRepository,
    this.sessionStore,
    this.temporaryPhoneEntryEnabled,
    this.dataModes,
    this.locale = const Locale('ar'),
  }) : assert((authRepository == null) == (sessionStore == null));

  final AuthRepository? authRepository;
  final AuthSessionStore? sessionStore;
  final bool? temporaryPhoneEntryEnabled;
  final FeatureDataModes? dataModes;
  final Locale locale;

  @override
  State<TamApp> createState() => _TamAppState();
}

class _TamAppState extends State<TamApp> with WidgetsBindingObserver {
  late final AuthCubit _auth;
  late final AuthRouterRefresh _refresh;
  late final GoRouter _router;
  late final AppLocaleController _locale;
  late final MockTripStore _mockTrips;
  late final StreamSubscription<AuthState> _sessionChanges;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final presentation = widget.authRepository == null
        ? locator<AuthPresentationConfig>()
        : const AuthPresentationConfig();
    _auth = AuthCubit(
      widget.authRepository ?? locator<AuthRepository>(),
      widget.sessionStore ?? locator<AuthSessionStore>(),
      temporaryPhoneEntryEnabled:
          widget.temporaryPhoneEntryEnabled ??
          presentation.temporaryPhoneEntryEnabled,
    );
    _refresh = AuthRouterRefresh(_auth);
    _locale = AppLocaleController(widget.locale);
    _mockTrips = MockTripStore(seed: seedMockTrips());
    _router = createAppRouter(
      _auth,
      _refresh,
      dataModes: widget.dataModes ?? AppConfig.featureDataModes,
      mockTrips: _mockTrips,
      locale: _locale,
    );
    var sessionEntered = false;
    _sessionChanges = _auth.stream.listen((state) {
      if (const [
        AuthStatus.authenticated,
        AuthStatus.guest,
        AuthStatus.localAccess,
      ].contains(state.status)) {
        sessionEntered = true;
      } else if (state.status == AuthStatus.signedOut && sessionEntered) {
        _mockTrips.clear();
        sessionEntered = false;
      }
    });
    unawaited(_auth.restoreSession());
  }

  @override
  void didUpdateWidget(covariant TamApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locale != widget.locale) _locale.setLocale(widget.locale);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _auth.state.status == AuthStatus.authenticated) {
      unawaited(_auth.restoreSession());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router.dispose();
    _refresh.dispose();
    unawaited(_sessionChanges.cancel());
    unawaited(_mockTrips.dispose());
    _locale.dispose();
    unawaited(_auth.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _auth,
      child: ValueListenableBuilder<Locale>(
        valueListenable: _locale,
        builder: (context, locale, child) => MaterialApp.router(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context).appName,
          routerConfig: _router,
          theme: AppTheme.light,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
        ),
      ),
    );
  }
}
