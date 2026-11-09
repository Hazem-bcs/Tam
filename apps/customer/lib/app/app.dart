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
import 'package:tam_customer/features/active_trip/data/mock/active_trip_scenario.dart';
import 'package:tam_customer/features/active_trip/data/mock/mock_active_trip_repository.dart';
import 'package:tam_customer/features/active_trip/data/unavailable_active_trip_repository.dart';
import 'package:tam_customer/features/active_trip/domain/active_trip_repository.dart';
import 'package:tam_customer/features/chat/domain/chat_repository.dart';
import 'package:tam_customer/features/chat/data/mock/mock_chat_repository.dart';
import 'package:tam_customer/features/chat/data/mock/chat_mock_scenario.dart';
import 'package:tam_customer/features/chat/data/unavailable_chat_repository.dart';
import 'package:tam_customer/features/addresses/data/mock/mock_addresses_repository.dart';
import 'package:tam_customer/features/addresses/data/ride_address_place_search.dart';
import 'package:tam_customer/features/addresses/data/unavailable_addresses_repository.dart';
import 'package:tam_customer/features/addresses/domain/addresses_repository.dart';
import 'package:tam_customer/features/auth/auth_dependencies.dart';
import 'package:tam_customer/features/auth/domain/auth_repository.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tam_customer/features/notifications/data/mock/mock_notifications_repository.dart';
import 'package:tam_customer/features/notifications/data/unavailable_notifications_repository.dart';
import 'package:tam_customer/features/notifications/domain/notifications_repository.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/data/repositories/unavailable_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/domain/repositories/ride_request_repository.dart';
import 'package:tam_customer/features/settings/settings_entry.dart';
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
    this.clock,
    this.locale = const Locale('ar'),
  }) : assert((authRepository == null) == (sessionStore == null));

  final AuthRepository? authRepository;
  final AuthSessionStore? sessionStore;
  final bool? temporaryPhoneEntryEnabled;
  final FeatureDataModes? dataModes;
  final DateTime Function()? clock;
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
  late final MockNotificationsRepository _mockNotifications;
  late final MockAddressesRepository _mockAddresses;
  MockActiveTripRepository? _mockActiveTrips;
  MockChatRepository? _mockChat;
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
    _mockTrips = MockTripStore(seed: seedMockTrips(), now: widget.clock);
    final modes = widget.dataModes ?? AppConfig.featureDataModes;
    final ActiveTripRepository activeTrips =
        modes.forFeature(CustomerFeature.activeTrip) == FeatureDataMode.mock
        ? (_mockActiveTrips = MockActiveTripRepository(
            _mockTrips,
            now: widget.clock,
            scenario: ActiveTripScenario.parse(
              AppConfig.activeTripMockScenario,
            ),
          ))
        : const UnavailableActiveTripRepository();
    final ChatRepository chat =
        modes.forFeature(CustomerFeature.chat) == FeatureDataMode.mock
        ? (_mockChat = MockChatRepository(
            _mockTrips,
            now: widget.clock,
            scenario: ChatMockScenario.parse(AppConfig.chatMockScenario),
            policy: AppConfig.chatPolicy,
          ))
        : const UnavailableChatRepository();
    _mockNotifications = MockNotificationsRepository();
    _mockAddresses = MockAddressesRepository();
    final addressesMode = modes.forFeature(CustomerFeature.addresses);
    final AddressesRepository addresses = addressesMode == FeatureDataMode.mock
        ? _mockAddresses
        : const UnavailableAddressesRepository();
    final RideRequestRepository placeSource =
        addressesMode == FeatureDataMode.mock
        ? MockRideRequestRepository(trips: _mockTrips)
        : const UnavailableRideRequestRepository();
    final NotificationsRepository notifications =
        modes.forFeature(CustomerFeature.notifications) == FeatureDataMode.mock
        ? _mockNotifications
        : const UnavailableNotificationsRepository();
    _router = createAppRouter(
      _auth,
      _refresh,
      dataModes: modes,
      notifications: notifications,
      addresses: addresses,
      activeTrips: activeTrips,
      chat: chat,
      clock: widget.clock,
      addressPlaceSearch: (language) =>
          RideAddressPlaceSearch(placeSource, languageCode: language),
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
        _mockTrips.resetSession();
        _mockActiveTrips?.resetSession();
        _mockChat?.resetSession();
        _mockNotifications.resetSession();
        _mockAddresses.resetSession();
        resetSettingsFeatureSession(_locale);
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
    if (state == AppLifecycleState.resumed) _mockActiveTrips?.advance();
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
    if (_mockActiveTrips != null) unawaited(_mockActiveTrips!.dispose());
    if (_mockChat != null) unawaited(_mockChat!.dispose());
    unawaited(_mockTrips.dispose());
    unawaited(_mockNotifications.dispose());
    unawaited(_mockAddresses.dispose());
    resetSettingsFeatureSession(_locale);
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
