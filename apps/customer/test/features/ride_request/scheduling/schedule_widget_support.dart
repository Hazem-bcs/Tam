import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_places.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/features/ride_request/presentation/pages/ride_request_page.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/trip.dart';

import '../../../support/preview_fonts.dart';

const captureScheduleUi = bool.fromEnvironment('CAPTURE_SCHEDULE_UI');
Future<void> loadScheduleFonts() =>
    loadPreviewFonts(enabled: captureScheduleUi);

Future<RideDraftBloc> pumpSchedule(
  WidgetTester tester, {
  String locale = 'ar',
  double scale = 1,
  DateTime Function()? now,
}) async {
  final clock = now ?? () => DateTime.utc(2026, 11, 9, 12);
  final store = MockTripStore(now: clock);
  final bloc = RideDraftBloc(
    repository: MockRideRequestRepository(trips: store, now: clock),
    now: clock,
    prefill: TripPrefill(
      pickup: mockRidePlaces[0].location,
      destination: mockRidePlaces[1].location,
    ),
  );
  addTearDown(store.dispose);
  final theme = captureScheduleUi ? previewTheme() : AppTheme.light;
  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('schedule-preview'),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: Locale(locale),
        theme: theme,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: BlocProvider(
          create: (_) => bloc,
          child: const RideRequestPage(navigation: ScheduleTestNavigation()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return bloc;
}

final class ScheduleTestNavigation implements CustomerNavigation {
  const ScheduleTestNavigation();
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
  void openAccountPhone() {}
  @override
  void openAccountDeletion() {}
  @override
  void openDriverContact(String tripId, String driverId) {}
  @override
  void openHome() {}
  @override
  void openNotifications() {}
  @override
  void openRideRequest({TripPrefill? prefill}) {}
  @override
  void openSettings() {}
  @override
  void openTrip(String id) {}
  @override
  void openTrips() {}
}
