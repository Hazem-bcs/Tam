import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/features/trips/data/mock/mock_trips_repository.dart';
import 'package:tam_customer/features/trips/domain/trips_repository.dart';
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
  testWidgets('changing the direct trip ID replaces the old details cubit', (
    tester,
  ) async {
    final store = MockTripStore(seed: seedMockTrips());
    addTearDown(store.dispose);
    Widget screen(String id) => tripsTestApp(
      Builder(
        builder: (context) => buildTripsFeature(
          context,
          navigation: TripsNavigationSpy(),
          dataMode: FeatureDataMode.mock,
          mockTrips: store,
          tripId: id,
        ),
      ),
    );
    await tester.pumpWidget(screen('mock-history-001'));
    await tester.pumpAndSettle();
    expect(find.textContaining('mock-history-001'), findsOneWidget);
    await tester.pumpWidget(screen('mock-history-002'));
    await tester.pumpAndSettle();
    expect(find.textContaining('mock-history-002'), findsOneWidget);
    expect(find.textContaining('mock-history-001'), findsNothing);
  });

  testWidgets('failed refresh reports an error alongside cached trips', (
    tester,
  ) async {
    final store = MockTripStore(seed: seedMockTrips());
    addTearDown(store.dispose);
    final repo = _RefreshFailureRepository(MockTripsRepository(store));
    final cubit = TripsListCubit(repo);
    await tester.pumpWidget(
      tripsTestApp(
        BlocProvider.value(
          value: cubit,
          child: TripsListPage(navigation: TripsNavigationSpy()),
        ),
      ),
    );
    addTearDown(cubit.close);
    await tester.pumpAndSettle();
    repo.fail = true;
    await cubit.refresh();
    await tester.pumpAndSettle();
    expect(find.text('خدمة الرحلات غير متاحة حاليًا.'), findsOneWidget);
    expect(find.textContaining('المزة'), findsWidgets);
  });

  testWidgets('failed details reload reports an error alongside cached trip', (
    tester,
  ) async {
    final store = MockTripStore(seed: seedMockTrips());
    addTearDown(store.dispose);
    final repo = _RefreshFailureRepository(MockTripsRepository(store));
    final cubit = TripDetailsCubit(repo, 'mock-history-001');
    addTearDown(cubit.close);
    await tester.pumpWidget(
      tripsTestApp(
        BlocProvider.value(
          value: cubit,
          child: TripDetailsPage(navigation: TripsNavigationSpy()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    repo.fail = true;
    await cubit.reload();
    await tester.pumpAndSettle();
    expect(find.text('خدمة الرحلات غير متاحة حاليًا.'), findsOneWidget);
    expect(find.textContaining('mock-history-001'), findsOneWidget);
  });

  testWidgets('empty and unavailable list fit a 320dp phone at 2x text', (
    tester,
  ) async {
    tripsViewport(tester, const Size(320, 700));
    final store = MockTripStore();
    addTearDown(store.dispose);
    for (final mode in FeatureDataMode.values) {
      await tester.pumpWidget(
        tripsTestApp(
          Builder(
            builder: (context) => buildTripsFeature(
              context,
              navigation: TripsNavigationSpy(),
              dataMode: mode,
              mockTrips: store,
            ),
          ),
          scale: 2,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}

class _RefreshFailureRepository implements TripsRepository {
  _RefreshFailureRepository(this.delegate);
  final TripsRepository delegate;
  bool fail = false;
  @override
  Stream<void> get changes => delegate.changes;
  @override
  Future<Trip?> find(String tripId) {
    if (fail) throw const TripsFailure('SERVICE_UNAVAILABLE');
    return delegate.find(tripId);
  }

  @override
  Future<Trip> cancel(String tripId) => delegate.cancel(tripId);
  @override
  Future<TripsPage> list({
    TripsFilter filter = TripsFilter.all,
    String? cursor,
    int limit = 20,
  }) {
    if (fail) throw const TripsFailure('SERVICE_UNAVAILABLE');
    return delegate.list(filter: filter, cursor: cursor, limit: limit);
  }
}
