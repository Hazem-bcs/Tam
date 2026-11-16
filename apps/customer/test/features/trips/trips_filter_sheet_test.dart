import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/trips/data/mock/mock_trips_repository.dart';
import 'package:tam_customer/features/trips/domain/trips_repository.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trips_list_cubit.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_status_filter.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/data/mock/seed_trips.dart';

import 'support/trips_test_support.dart';

void main() {
  for (final language in ['ar', 'en']) {
    for (final size in [const Size(320, 700), const Size(800, 1000)]) {
      testWidgets('$language $size filter sheet selects and dismisses safely', (
        tester,
      ) async {
        tripsViewport(tester, size);
        final store = MockTripStore(seed: seedMockTrips());
        final cubit = TripsListCubit(MockTripsRepository(store));
        addTearDown(store.dispose);
        addTearDown(cubit.close);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            locale: Locale(language),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: BlocProvider.value(
              value: cubit,
              child: const Scaffold(body: Center(child: TripStatusFilter())),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final control = find.byKey(const Key('trips-filter-control'));
        await tester.tap(control);
        await tester.pumpAndSettle();
        expect(find.byType(BottomSheet), findsOneWidget);
        expect(
          MediaQuery.textScalerOf(
            tester.element(find.byType(BottomSheet)),
          ).scale(10),
          20,
        );
        expect(find.byType(PopupMenuButton<TripsFilter>), findsNothing);
        for (final filter in TripsFilter.values) {
          final option = find.byKey(Key('trips-filter-${filter.name}'));
          await tester.ensureVisible(option);
          await tester.pumpAndSettle();
          expect(option, findsOneWidget);
          expect(tester.takeException(), isNull);
        }
        await tester.tap(find.byKey(const Key('trips-filter-cancelled')));
        await tester.pumpAndSettle();
        expect(cubit.state.filter, TripsFilter.cancelled);
        expect(cubit.state.items, hasLength(1));
        expect(find.byType(BottomSheet), findsNothing);
        await tester.tap(control);
        await tester.pumpAndSettle();
        final sheetContext = tester.element(find.byType(BottomSheet));
        Navigator.of(sheetContext).pop();
        await tester.pumpAndSettle();
        expect(cubit.state.filter, TripsFilter.cancelled);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
