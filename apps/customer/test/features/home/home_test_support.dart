import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/home/domain/repositories/home_repository.dart';
import 'package:tam_customer/features/home/presentation/bloc/home_cubit.dart';
import 'package:tam_customer/features/home/presentation/pages/home_page.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';

final class RecordingHomeNavigation implements CustomerNavigation {
  int ride = 0;
  int trips = 0;
  int settings = 0;
  int notifications = 0;
  int home = 0;
  @override
  void openHome() => home++;
  @override
  void openRideRequest({TripPrefill? prefill}) => ride++;
  @override
  void openTrips() => trips++;
  @override
  void openTrip(String id) {}
  @override
  void openNotifications() => notifications++;
  @override
  void openSettings() => settings++;
}

Future<void> pumpHome(
  WidgetTester tester, {
  required HomeRepository repository,
  required RecordingHomeNavigation navigation,
  String language = 'ar',
  String? phone = '+963941234567',
  bool authenticated = true,
  bool guest = false,
  VoidCallback? onLogout,
  ThemeData? renderTheme,
}) async {
  await tester.pumpWidget(
    BlocProvider(
      key: UniqueKey(),
      create: (_) => HomeCubit(repository)..load(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: Locale(language),
        theme: renderTheme ?? AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomePage(
          navigation: navigation,
          phoneE164: phone,
          isAuthenticated: authenticated,
          isGuest: guest,
          logout: () async => onLogout?.call(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
