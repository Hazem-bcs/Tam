import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/trips/data/mock/mock_trips_repository.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trips_list_cubit.dart';
import 'package:tam_customer/features/trips/presentation/pages/trips_list_page.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_card.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/data/mock/seed_trips.dart';

import 'support/trips_test_support.dart';

void main() {
  testWidgets('activity services stay compact and readable', (tester) async {
    tripsViewport(tester, const Size(390, 844));
    final store = MockTripStore(seed: seedMockTrips());
    addTearDown(store.dispose);
    await tester.pumpWidget(
      tripsTestApp(
        BlocProvider(
          create: (_) => TripsListCubit(MockTripsRepository(store)),
          child: TripsListPage(navigation: TripsNavigationSpy()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final asset in [
      'assets/images/ride_car.webp',
      'assets/images/shopping.webp',
      'assets/images/food.webp',
    ]) {
      final matching = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == asset,
      );
      expect(matching, findsOneWidget);
      final image = tester.widget<Image>(matching);
      expect(image.width, 28);
      expect(image.height, 28);
    }
    expect(
      tester.getSize(find.byKey(const Key('trips-services'))).height,
      lessThanOrEqualTo(64),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('activity cards keep paid fare without redundant labels', (
    tester,
  ) async {
    tripsViewport(tester, const Size(390, 844));
    final trips = seedMockTrips();
    await tester.pumpWidget(
      tripsTestApp(
        Scaffold(
          body: ListView(
            children: [
              TripCard(trip: trips.first, onTap: () {}),
              TripCard(trip: trips.last, onTap: () {}),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('الأجرة'), findsNothing);
    expect(find.text('مبلغ الطلب المسجل'), findsNothing);
    expect(find.textContaining('25,000'), findsOneWidget);
    // A cancelled trip must not imply the recorded estimate was charged.
    expect(find.textContaining('28,000'), findsNothing);
    expect(find.text('التفاصيل'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
