import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/active_trip/domain/active_trip_repository.dart';
import 'package:tam_customer/features/active_trip/presentation/bloc/active_trip_cubit.dart';
import 'package:tam_customer/features/active_trip/presentation/pages/active_trip_page.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import '../../support/preview_fonts.dart';

const captureActiveUi = bool.fromEnvironment('CAPTURE_ACTIVE_TRIP_UI');
Future<void> loadActiveFonts() => loadPreviewFonts(enabled: captureActiveUi);
Future<ActiveTripCubit> pumpActiveTrip(
  WidgetTester tester, {
  required ActiveTripRepository repository,
  required DateTime Function() now,
  String? tripId,
  String locale = 'ar',
  double scale = 1,
  ActiveNavigationSpy? navigation,
}) async {
  late ActiveTripCubit cubit;
  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('active-preview'),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: captureActiveUi ? previewTheme() : AppTheme.light,
        locale: Locale(locale),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: BlocProvider(
          create: (_) => cubit = ActiveTripCubit(
            repository,
            tripId: tripId,
            now: now,
            poll: false,
          ),
          child: ActiveTripPage(
            navigation: navigation ?? ActiveNavigationSpy(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return cubit;
}

final class ActiveNavigationSpy implements CustomerNavigation {
  TripPrefill? prefill;
  String? detailsId;
  @override
  void openCompletion(String tripId) {}
  @override
  void openSupport({String? tripId}) {}
  @override
  void openTerms() {}
  @override
  void openPrivacy() {}
  @override
  void openChat(String tripId) {}
  @override
  void openActiveTrip({String? id}) {}
  @override
  void openAddresses() {}
  @override
  void openHome() {}
  @override
  void openNotifications() {}
  @override
  void openRideRequest({TripPrefill? prefill}) => this.prefill = prefill;
  @override
  void openSettings() {}
  @override
  void openTrip(String id) => detailsId = id;
  @override
  void openTrips() {}
}
