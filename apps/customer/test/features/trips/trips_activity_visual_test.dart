import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/shell/main_navigation_bar.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/trips/data/mock/mock_trips_repository.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trips_list_cubit.dart';
import 'package:tam_customer/features/trips/presentation/pages/trips_list_page.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/data/mock/seed_trips.dart';

import 'support/trips_test_support.dart';

void main() {
  setUpAll(() async {
    // Flutter's test rasterizer has no system Arabic fallback; load the
    // bundled brand font so the golden validates actual Arabic typography.
    await (FontLoader('TamSansArabic')
          ..addFont(rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf')))
        .load();
    await (FontLoader(
      'TamSansLatin',
    )..addFont(rootBundle.load('assets/fonts/NotoSans-Regular.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

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

  testWidgets('activity visual: Arabic history in the real navigation dock', (
    tester,
  ) async {
    tripsViewport(tester, const Size(390, 844));
    final store = MockTripStore(seed: seedMockTrips());
    addTearDown(store.dispose);

    await tester.pumpWidget(
      tripsTestApp(
        BlocProvider(
          create: (_) => TripsListCubit(MockTripsRepository(store)),
          child: Theme(
            data: AppTheme.activity(AppTheme.light),
            child: Scaffold(
              body: TripsListPage(navigation: TripsNavigationSpy()),
              bottomNavigationBar: MainNavigationBar(
                selectedIndex: 1,
                onSelected: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('آخر مشاويرك'), findsOneWidget);
    expect(find.text('مكتملة'), findsOneWidget);
    expect(find.text('ملغاة'), findsOneWidget);
    await expectLater(
      find.byType(Scaffold).first,
      matchesGoldenFile('goldens/trips-activity-history-ar-390.png'),
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
    await tester.scrollUntilVisible(
      find.byKey(const Key('trips-new-ride')),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('trips-new-ride')));
    await tester.pump();
    expect(navigation.rideRequestOpened, isTrue);
    expect(store.trips, hasLength(2));
    expect(tester.takeException(), isNull);
  });
}
