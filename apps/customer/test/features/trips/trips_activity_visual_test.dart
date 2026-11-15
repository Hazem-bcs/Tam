import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/trips/data/mock/mock_trips_repository.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trips_list_cubit.dart';
import 'package:tam_customer/features/trips/presentation/pages/trips_list_page.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/data/mock/seed_trips.dart';

import 'support/trips_test_support.dart';

void main() {
  testWidgets('activity visual: Arabic phone, active plus history', (
    tester,
  ) async {
    tripsViewport(tester, const Size(390, 844));
    final store = MockTripStore(seed: seedMockTrips());
    addTearDown(store.dispose);
    store.create(
      seedMockTrips().first.booking,
      idempotencyKey: 'golden-active',
    );

    await tester.pumpWidget(
      tripsTestApp(
        BlocProvider(
          create: (_) => TripsListCubit(MockTripsRepository(store)),
          child: TripsListPage(navigation: TripsNavigationSpy()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('نشاطي'), findsWidgets);
    expect(find.text('رحلة جارية'), findsOneWidget);
    expect(find.text('الرحلات'), findsOneWidget);
    await expectLater(
      find.byType(TripsListPage),
      matchesGoldenFile('goldens/trips-activity-ar-390.png'),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('next-journey prompt opens the real booking flow', (
    tester,
  ) async {
    tripsViewport(tester, const Size(390, 844));
    final store = MockTripStore(seed: seedMockTrips());
    addTearDown(store.dispose);
    final navigation = TripsNavigationSpy();
    await tester.pumpWidget(
      tripsTestApp(
        BlocProvider(
          create: (_) => TripsListCubit(MockTripsRepository(store)),
          child: TripsListPage(navigation: navigation),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('trips-new-ride')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('trips-new-ride')));
    await tester.pump();
    expect(navigation.rideRequestOpened, isTrue);
    expect(store.trips, hasLength(2));
    expect(tester.takeException(), isNull);
  });
}
