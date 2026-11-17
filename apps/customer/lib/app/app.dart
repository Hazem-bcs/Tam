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
import 'package:tam_customer/features/account_management/data/mock/mock_account_management_repository.dart';
import 'package:tam_customer/features/account_management/data/unavailable_account_management_repository.dart';
import 'package:tam_customer/features/active_trip/data/mock/active_trip_scenario.dart';
import 'package:tam_customer/features/active_trip/data/mock/mock_active_trip_repository.dart';
import 'package:tam_customer/features/active_trip/data/unavailable_active_trip_repository.dart';
import 'package:tam_customer/features/active_trip/domain/active_trip_repository.dart';
import 'package:tam_customer/features/addresses/data/mock/mock_addresses_repository.dart';
import 'package:tam_customer/features/addresses/data/ride_address_place_search.dart';
import 'package:tam_customer/features/addresses/data/unavailable_addresses_repository.dart';
import 'package:tam_customer/features/addresses/domain/addresses_repository.dart';
import 'package:tam_customer/features/auth/auth_dependencies.dart';
import 'package:tam_customer/features/auth/domain/auth_repository.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tam_customer/features/chat/data/mock/chat_mock_scenario.dart';
import 'package:tam_customer/features/chat/data/mock/mock_chat_repository.dart';
import 'package:tam_customer/features/chat/data/unavailable_chat_repository.dart';
import 'package:tam_customer/features/chat/domain/chat_repository.dart';
import 'package:tam_customer/features/completion/data/mock/completion_mock_scenario.dart';
import 'package:tam_customer/features/completion/data/mock/mock_completion_repository.dart';
import 'package:tam_customer/features/completion/data/unavailable_completion_repository.dart';
import 'package:tam_customer/features/completion/domain/completion_repository.dart';
import 'package:tam_customer/features/driver_contact/data/driver_phone_dialer.dart';
import 'package:tam_customer/features/driver_contact/data/mock/mock_driver_contact_repository.dart';
import 'package:tam_customer/features/maps/maps_dependencies.dart';
import 'package:tam_customer/features/maps/presentation/maps_scope.dart';
import 'package:tam_customer/features/notifications/data/mock/mock_notifications_repository.dart';
import 'package:tam_customer/features/notifications/data/unavailable_notifications_repository.dart';
import 'package:tam_customer/features/notifications/domain/notifications_repository.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/data/repositories/unavailable_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/domain/repositories/ride_request_repository.dart';
import 'package:tam_customer/features/settings/data/mock/mock_coupon_book.dart';
import 'package:tam_customer/features/settings/presentation/coupon_book_scope.dart';
import 'package:tam_customer/features/settings/settings_entry.dart';
import 'package:tam_customer/features/support/data/mock/mock_support_repository.dart';
import 'package:tam_customer/features/support/data/unavailable_support_repository.dart';
import 'package:tam_customer/features/support/domain/support_repository.dart';
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
  late final MapsDependencies _maps;
  late final MockTripStore _mockTrips;
  final MockCouponBook _couponBook = MockCouponBook();
  late final MockNotificationsRepository _mockNotifications;
  late final MockAddressesRepository _mockAddresses;
  MockActiveTripRepository? _mockActiveTrips;
  MockChatRepository? _mockChat;
  MockCompletionRepository? _mockCompletion;
  MockSupportRepository? _mockSupport;
  MockAccountManagementRepository? _mockAccounts;
  MockDriverContactRepository? _mockContacts;
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
    _maps = locator.isRegistered<MapsDependencies>()
        ? locator<MapsDependencies>()
        : MapsDependencies.configured(AppConfig.maps);
    _mockTrips = MockTripStore(
      seed: seedMockTrips(includeReceiptPreview: true),
      now: widget.clock,
    );
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
    final CompletionRepository completion =
        modes.forFeature(CustomerFeature.completion) == FeatureDataMode.mock
        ? (_mockCompletion = MockCompletionRepository(
            _mockTrips,
            now: widget.clock,
            policy: AppConfig.completionPolicy,
            scenario: CompletionMockScenario.parse(
              AppConfig.completionMockScenario,
            ),
          ))
        : const UnavailableCompletionRepository();
    final SupportRepository support =
        modes.forFeature(CustomerFeature.support) == FeatureDataMode.mock
        ? (_mockSupport = MockSupportRepository(
            _mockTrips,
            now: widget.clock,
            policy: AppConfig.supportPolicy,
            scenario: SupportMockScenario.parse(AppConfig.supportMockScenario),
          ))
        : const UnavailableSupportRepository();
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
    final accounts =
        modes.forFeature(CustomerFeature.accountManagement) ==
            FeatureDataMode.mock
        ? (_mockAccounts = MockAccountManagementRepository(
            _mockTrips,
            phone: () =>
                _auth.state.localPhoneE164 ?? _auth.state.user?.phoneE164,
            now: widget.clock,
            policy: AppConfig.accountPolicy,
            scenario: AppConfig.accountMockScenario,
          ))
        : const UnavailableAccountManagementRepository();
    final contacts =
        modes.forFeature(CustomerFeature.driverContact) == FeatureDataMode.mock
        ? (_mockContacts = MockDriverContactRepository(
            _mockTrips,
            now: widget.clock,
            scenario: AppConfig.driverContactMockScenario,
          ))
        : const UnavailableDriverContactRepository();
    final dialer =
        modes.forFeature(CustomerFeature.driverContact) == FeatureDataMode.mock
        ? const MockPhoneDialer()
        : const DriverPhoneDialer();
    _router = createAppRouter(
      _auth,
      _refresh,
      dataModes: modes,
      notifications: notifications,
      addresses: addresses,
      activeTrips: activeTrips,
      chat: chat,
      completion: completion,
      support: support,
      accounts: accounts,
      contacts: contacts,
      dialer: dialer,
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
        _maps.currentLocation?.setSession(true);
        sessionEntered = true;
      } else if (state.status == AuthStatus.signedOut && sessionEntered) {
        _maps.currentLocation?.setSession(false);
        _mockTrips.resetSession();
        _mockActiveTrips?.resetSession();
        _mockChat?.resetSession();
        _mockCompletion?.resetSession();
        _mockSupport?.resetSession();
        _mockAccounts?.resetSession();
        _mockContacts?.resetSession();
        _mockNotifications.resetSession();
        _mockAddresses.resetSession();
        resetSettingsFeatureSession(_locale);
        _couponBook.resetSession();
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
    if (state == AppLifecycleState.resumed) {
      _maps.currentLocation?.setForeground(true);
      _mockActiveTrips?.advance();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _maps.currentLocation?.setForeground(false);
    }
    if (state == AppLifecycleState.resumed &&
        _auth.state.status == AuthStatus.authenticated) {
      unawaited(_auth.restoreSession());
    }
  }

  @override
  void dispose() {
    _maps.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _router.dispose();
    _refresh.dispose();
    unawaited(_sessionChanges.cancel());
    if (_mockActiveTrips != null) unawaited(_mockActiveTrips!.dispose());
    if (_mockChat != null) unawaited(_mockChat!.dispose());
    if (_mockCompletion != null) unawaited(_mockCompletion!.dispose());
    if (_mockSupport != null) unawaited(_mockSupport!.dispose());
    if (_mockAccounts != null) unawaited(_mockAccounts!.dispose());
    if (_mockContacts != null) unawaited(_mockContacts!.dispose());
    unawaited(_mockTrips.dispose());
    unawaited(_mockNotifications.dispose());
    unawaited(_mockAddresses.dispose());
    resetSettingsFeatureSession(_locale);
    _couponBook.dispose();
    _locale.dispose();
    unawaited(_auth.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CouponBookScope(
      book: _couponBook,
      child: BlocProvider.value(
        value: _auth,
        child: MapsScope(
          dependencies: _maps,
          child: ValueListenableBuilder<Locale>(
            valueListenable: _locale,
            builder: (context, locale, child) => MaterialApp.router(
              debugShowCheckedModeBanner: false,
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context).appName,
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
        ),
      ),
    );
  }
}
