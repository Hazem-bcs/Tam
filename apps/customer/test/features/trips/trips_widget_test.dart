import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/features/trips/data/mock/mock_trips_repository.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trip_details_cubit.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trips_list_cubit.dart';
import 'package:tam_customer/features/trips/presentation/pages/trip_details_page.dart';
import 'package:tam_customer/features/trips/presentation/pages/trips_list_page.dart';
import 'package:tam_customer/features/trips/trips_entry.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/data/mock/seed_trips.dart';
import 'package:tam_customer/shared/domain/trip.dart';

import 'support/trips_test_support.dart';

void main() {
  testWidgets('Arabic list filters and refresh show correct local history', (
    tester,
  ) async {
    tripsViewport(tester, const Size(390, 844));
    final store = MockTripStore(seed: seedMockTrips());
    addTearDown(store.dispose);
    final nav = TripsNavigationSpy();
    await tester.pumpWidget(
      tripsTestApp(
        BlocProvider(
          create: (_) => TripsListCubit(MockTripsRepository(store)),
          child: TripsListPage(navigation: nav),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('المزة'), findsWidgets);
    await tester.tap(find.byKey(const Key('trips-filter-control')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('trips-filter-active')));
    await tester.pumpAndSettle();
    expect(find.text('لا توجد رحلات هنا'), findsOneWidget);
    final newTrip = store.create(
      seedMockTrips().first.booking,
      idempotencyKey: 'new',
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('المزة'), findsWidgets);
    await tester.tap(find.byKey(Key('trips-active-${newTrip.id}')));
    expect(nav.lastActiveTripId, newTrip.id);
    store.cancel(newTrip.id);
    await tester.pumpAndSettle();
    expect(find.text('لا توجد رحلات هنا'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('completed detail rebook passes only locations, no new booking', (
    tester,
  ) async {
    tripsViewport(tester, const Size(390, 844));
    final store = MockTripStore(seed: seedMockTrips());
    addTearDown(store.dispose);
    final nav = TripsNavigationSpy();
    await tester.pumpWidget(
      tripsTestApp(
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
    tripsViewport(tester, const Size(390, 844));
    final store = MockTripStore();
    addTearDown(store.dispose);
    final created = store.create(
      seedMockTrips().first.booking,
      idempotencyKey: 'active',
    );
    await tester.pumpWidget(
      tripsTestApp(
        BlocProvider(
          create: (_) =>
              TripDetailsCubit(MockTripsRepository(store), created.id),
          child: TripDetailsPage(navigation: TripsNavigationSpy()),
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
    tripsViewport(tester, const Size(390, 844));
    final store = MockTripStore(seed: seedMockTrips());
    addTearDown(store.dispose);
    final nav = TripsNavigationSpy();
    await tester.pumpWidget(
      tripsTestApp(
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
      tripsTestApp(
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
      tripsViewport(tester, size);
      final store = MockTripStore(seed: seedMockTrips());
      addTearDown(store.dispose);
      await tester.pumpWidget(
        tripsTestApp(
          BlocProvider(
            create: (_) => TripsListCubit(MockTripsRepository(store)),
            child: TripsListPage(navigation: TripsNavigationSpy()),
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
      tripsViewport(tester, size);
      final store = MockTripStore(seed: seedMockTrips());
      addTearDown(store.dispose);
      await tester.pumpWidget(
        tripsTestApp(
          BlocProvider(
            create: (_) => TripDetailsCubit(
              MockTripsRepository(store),
              'mock-history-001',
            ),
            child: TripDetailsPage(navigation: TripsNavigationSpy()),
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
