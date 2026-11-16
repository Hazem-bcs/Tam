import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/trips/data/mock/mock_trips_repository.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trips_list_cubit.dart';
import 'package:tam_customer/features/trips/presentation/pages/trips_list_page.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/data/mock/seed_trips.dart';

import 'support/trips_test_support.dart';

void main() {
  testWidgets(
    'activity screen uses the ambient surface and dark system icons',
    (tester) async {
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

      final page = find.byType(TripsListPage);
      final overlayRegion = tester
          .widget<AnnotatedRegion<SystemUiOverlayStyle>>(
            find.descendant(
              of: page,
              matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
            ),
          );
      final contentSurface = AppTheme.light.colorScheme.surface;
      expect(overlayRegion.value.statusBarColor, contentSurface);
      expect(overlayRegion.value.statusBarIconBrightness, Brightness.dark);
      expect(overlayRegion.value.statusBarBrightness, Brightness.light);
      expect(overlayRegion.value.systemStatusBarContrastEnforced, false);
      expect(
        overlayRegion.value.systemNavigationBarIconBrightness,
        Brightness.dark,
      );

      final scaffold = tester.widget<Scaffold>(
        find.descendant(of: page, matching: find.byType(Scaffold)),
      );
      expect(scaffold.backgroundColor, contentSurface);

      expect(tester.takeException(), isNull);
    },
  );
}
