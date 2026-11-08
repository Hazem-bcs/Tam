import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';

void tripsViewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget tripsTestApp(Widget child, {String language = 'ar', double scale = 1}) =>
    MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale(language),
      theme: AppTheme.light,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child,
        ),
      ),
    );

class TripsNavigationSpy implements CustomerNavigation {
  String? lastTripId;
  TripPrefill? prefill;
  bool openedTrips = false;

  @override
  void openTrip(String id) => lastTripId = id;
  @override
  void openRideRequest({TripPrefill? prefill}) => this.prefill = prefill;
  @override
  void openTrips() => openedTrips = true;
  @override
  void openHome() {}
  @override
  void openNotifications() {}
  @override
  void openSettings() {}
}
