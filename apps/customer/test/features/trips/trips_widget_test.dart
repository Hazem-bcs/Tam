import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/features/trips/data/mock/mock_trips_repository.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trip_details_cubit.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trips_list_cubit.dart';
import 'package:tam_customer/features/trips/presentation/pages/trip_details_page.dart';
import 'package:tam_customer/features/trips/presentation/pages/trips_list_page.dart';
import 'package:tam_customer/features/trips/trips_entry.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/data/mock/seed_trips.dart';
import 'package:tam_customer/shared/domain/trip.dart';

void _viewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _app(Widget child, {String language = 'ar', double scale = 1}) =>
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

void main() {
  testWidgets('Arabic list filters and refresh show correct local history', (
    tester,
  ) async {
    _viewport(tester, const Size(390, 844));
    final store = MockTripStore(seed: seedMockTrips());
    addTearDown(store.dispose);
    final nav = _NavigationSpy();
    await tester.pumpWidget(
      _app(
        BlocProvider(
          create: (_) => TripsListCubit(MockTripsRepository(store)),
          child: TripsListPage(navigation: nav),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('المزة'), findsWidgets);
    await tester.tap(find.byKey(const Key('trips-filter-active')));
    await tester.pumpAndSettle();
    expect(find.text('لا توجد رحلات هنا'), findsOneWidget);
    final newTrip = store.create(
      seedMockTrips().first.booking,
      idempotencyKey: 'new',
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('المزة'), findsWidgets);
    await tester.tap(find.byKey(ValueKey(newTrip.id)));
    expect(nav.lastTripId, newTrip.id);
    store.cancel(newTrip.id);
    await tester.pumpAndSettle();
    expect(find.text('لا توجد رحلات هنا'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('completed detail rebook passes only locations, no new booking', (
    tester,
  ) async {
    _viewport(tester, const Size(390, 844));
    final store = MockTripStore(seed: seedMockTrips());
    addTearDown(store.dispose);
    final nav = _NavigationSpy();
    await tester.pumpWidget(
      _app(
        BlocProvider(
          create: (_) =>
              TripDetailsCubit(MockTripsRepository(store), 'mock-history-001'),
          child: TripDetailsPage(navigation: nav),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('مكتملة'), findsWidgets);
    expect(find.text('إلغاء الرحلة'), findsNothing);
    await tester.tap(find.text('اطلب مجددًا'));
    expect(
      nav.prefill,
      TripPrefill(
        pickup: seedMockTrips().first.booking.pickup,
        destination: seedMockTrips().first.booking.destination,
      ),
    );
    expect(store.trips, hasLength(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancel requires dialog confirmation and updates details', (
    tester,
  ) async {
    _viewport(tester, const Size(390, 844));
    final store = MockTripStore();
    addTearDown(store.dispose);
    final created = store.create(
      seedMockTrips().first.booking,
      idempotencyKey: 'active',
    );
    await tester.pumpWidget(
      _app(
        BlocProvider(
          create: (_) =>
              TripDetailsCubit(MockTripsRepository(store), created.id),
          child: TripDetailsPage(navigation: _NavigationSpy()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('إلغاء الرحلة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('الاحتفاظ بالرحلة'));
    await tester.pumpAndSettle();
    expect(store.find(created.id)?.status, TripStatus.requested);
    await tester.tap(find.text('إلغاء الرحلة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تأكيد الإلغاء'));
    await tester.pumpAndSettle();
    expect(store.find(created.id)?.status, TripStatus.cancelled);
    expect(find.text('إلغاء الرحلة'), findsNothing);
    expect(find.text('ملغاة'), findsWidgets);
  });

  testWidgets('missing ID and unavailable API are explicit error states', (
    tester,
  ) async {
    _viewport(tester, const Size(390, 844));
    final store = MockTripStore(seed: seedMockTrips());
    addTearDown(store.dispose);
    final nav = _NavigationSpy();
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => buildTripsFeature(
            context,
            navigation: nav,
            dataMode: FeatureDataMode.mock,
            mockTrips: store,
            tripId: 'missing',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('الرحلة غير موجودة'), findsOneWidget);
    await tester.tap(find.text('العودة إلى طلباتي'));
    expect(nav.openedTrips, isTrue);
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => buildTripsFeature(
            context,
            navigation: nav,
            dataMode: FeatureDataMode.api,
            mockTrips: store,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('خدمة الرحلات غير متاحة حاليًا.'), findsOneWidget);
    expect(find.textContaining('المزة'), findsNothing);
  });

  for (final (size, scale, language) in [
    (const Size(320, 700), 2.0, 'ar'),
    (const Size(390, 844), 1.0, 'ar'),
    (const Size(800, 980), 2.0, 'en'),
    (const Size(800, 360), 1.0, 'en'),
  ]) {
    testWidgets('responsive list $size / $language / $scale', (tester) async {
      _viewport(tester, size);
      final store = MockTripStore(seed: seedMockTrips());
      addTearDown(store.dispose);
      await tester.pumpWidget(
        _app(
          BlocProvider(
            create: (_) => TripsListCubit(MockTripsRepository(store)),
            child: TripsListPage(navigation: _NavigationSpy()),
          ),
          language: language,
          scale: scale,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TripsListPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final (size, scale, language) in [
    (const Size(320, 700), 2.0, 'ar'),
    (const Size(390, 844), 1.0, 'ar'),
    (const Size(800, 980), 2.0, 'en'),
    (const Size(800, 360), 1.0, 'en'),
  ]) {
    testWidgets('responsive detail $size / $language / $scale', (tester) async {
      _viewport(tester, size);
      final store = MockTripStore(seed: seedMockTrips());
      addTearDown(store.dispose);
      await tester.pumpWidget(
        _app(
          BlocProvider(
            create: (_) => TripDetailsCubit(
              MockTripsRepository(store),
              'mock-history-001',
            ),
            child: TripDetailsPage(navigation: _NavigationSpy()),
          ),
          language: language,
          scale: scale,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TripDetailsPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

class _NavigationSpy implements CustomerNavigation {
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
