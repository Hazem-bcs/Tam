import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/trips/data/mock/mock_trips_repository.dart';
import 'package:tam_customer/features/trips/domain/trips_repository.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trip_details_cubit.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trips_list_cubit.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/data/mock/seed_trips.dart';
import 'package:tam_customer/shared/domain/trip.dart';

void main() {
  test('list subscription follows create/cancel, filter and refresh', () async {
    final store = MockTripStore(seed: seedMockTrips());
    addTearDown(store.dispose);
    final cubit = TripsListCubit(MockTripsRepository(store));
    addTearDown(cubit.close);
    await cubit.refresh();
    expect(cubit.state.items, hasLength(2));
    await cubit.selectFilter(TripsFilter.active);
    expect(cubit.state.items, isEmpty);
    final created = store.create(
      seedMockTrips().first.booking,
      idempotencyKey: 'one',
    );
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.items.single.id, created.id);
    store.cancel(created.id);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.items, isEmpty);
    await cubit.selectFilter(TripsFilter.cancelled);
    expect(cubit.state.items.map((t) => t.id), contains(created.id));
    await cubit.refresh();
    expect(
      cubit.state.items.map((t) => t.id).toSet().length,
      cubit.state.items.length,
    );
  });

  test(
    'pagination loads without duplicates and handles newly inserted trip',
    () async {
      final booking = seedMockTrips().first.booking;
      final store = MockTripStore(
        seed: [
          for (var i = 0; i < 44; i++)
            Trip(
              id: 'trip-$i',
              booking: booking,
              status: TripStatus.completed,
              createdAt: DateTime.utc(2026, 11, 1).add(Duration(minutes: i)),
            ),
        ],
      );
      addTearDown(store.dispose);
      final cubit = TripsListCubit(MockTripsRepository(store));
      addTearDown(cubit.close);
      await cubit.refresh();
      expect(cubit.state.items, hasLength(20));
      await cubit.loadMore();
      expect(cubit.state.items, hasLength(40));
      final justCreated = store.create(booking, idempotencyKey: 'new');
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.items.first.id, justCreated.id);
      expect(
        cubit.state.items.map((e) => e.id).toSet().length,
        cubit.state.items.length,
      );
      await cubit.loadMore();
      expect(cubit.state.nextCursor, isNull);
      expect(cubit.state.items, hasLength(45));
      await cubit.loadMore(); // no-op
      expect(cubit.state.items, hasLength(45));
    },
  );

  test(
    'details watches same source and forbids cancelled/completed cancellation',
    () async {
      final store = MockTripStore(seed: seedMockTrips());
      addTearDown(store.dispose);
      final created = store.create(
        seedMockTrips().first.booking,
        idempotencyKey: 'k1',
      );
      final repo = MockTripsRepository(store);
      final cubit = TripDetailsCubit(repo, created.id);
      addTearDown(cubit.close);
      await cubit.reload();
      expect(cubit.state.trip?.status, TripStatus.requested);
      expect(await cubit.cancel(), isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.trip?.status, TripStatus.cancelled);
      expect(await cubit.cancel(), isFalse);
      final completed = TripDetailsCubit(repo, 'mock-history-001');
      addTearDown(completed.close);
      await completed.reload();
      expect(await completed.cancel(), isFalse);
      expect(completed.state.trip?.status, TripStatus.completed);
    },
  );

  test(
    'direct non-existing ID yields not-found and reacts to store clear',
    () async {
      final store = MockTripStore(seed: seedMockTrips());
      addTearDown(store.dispose);
      final repo = MockTripsRepository(store);
      final missing = TripDetailsCubit(repo, 'missing');
      addTearDown(missing.close);
      await missing.reload();
      expect(missing.state.isNotFound, isTrue);
      final existing = TripDetailsCubit(repo, 'mock-history-001');
      addTearDown(existing.close);
      await existing.reload();
      store.clear();
      await Future<void>.delayed(Duration.zero);
      expect(existing.state.isNotFound, isTrue);
    },
  );

  test(
    'cubits cancel subscriptions on close and tolerate later changes',
    () async {
      final store = MockTripStore(seed: seedMockTrips());
      addTearDown(store.dispose);
      final list = TripsListCubit(MockTripsRepository(store));
      final detail = TripDetailsCubit(
        MockTripsRepository(store),
        'mock-history-001',
      );
      await list.refresh();
      await detail.reload();
      await list.close();
      await detail.close();
      store.clear();
      expect(list.isClosed, isTrue);
      expect(detail.isClosed, isTrue);
    },
  );

  test(
    'explicit domain failures support retry without mock fallback',
    () async {
      final repo = _FailingRepository();
      final list = TripsListCubit(repo);
      addTearDown(list.close);
      await list.refresh();
      expect(list.state.errorCode, 'SERVICE_UNAVAILABLE');
      repo.fail = false;
      await list.refresh();
      expect(list.state.errorCode, isNull);
      expect(list.state.items, isEmpty);
      final detail = TripDetailsCubit(repo, 'any');
      addTearDown(detail.close);
      await detail.reload();
      expect(detail.state.isNotFound, isTrue);
    },
  );

  test('cancel failure keeps original booking and supports retry', () async {
    final store = MockTripStore();
    addTearDown(store.dispose);
    final created = store.create(
      seedMockTrips().first.booking,
      idempotencyKey: 'cancel-retry',
    );
    final repo = _IntermittentTripsRepository(MockTripsRepository(store))
      ..failCancel = true;
    final cubit = TripDetailsCubit(repo, created.id);
    addTearDown(cubit.close);
    await cubit.reload();
    expect(await cubit.cancel(), isFalse);
    expect(cubit.state.actionErrorCode, 'SERVICE_UNAVAILABLE');
    expect(store.find(created.id)?.status, TripStatus.requested);
    repo.failCancel = false;
    expect(await cubit.cancel(), isTrue);
    expect(cubit.state.actionErrorCode, isNull);
    expect(store.find(created.id)?.status, TripStatus.cancelled);
  });

  test(
    'pagination failure retains first page and allows load-more retry',
    () async {
      final booking = seedMockTrips().first.booking;
      final store = MockTripStore(
        seed: [
          for (var i = 0; i < 23; i++)
            Trip(
              id: 'page-$i',
              booking: booking,
              createdAt: DateTime.utc(2026, 11, 1).add(Duration(minutes: i)),
              status: TripStatus.completed,
            ),
        ],
      );
      addTearDown(store.dispose);
      final repo = _IntermittentTripsRepository(MockTripsRepository(store))
        ..failMore = true;
      final cubit = TripsListCubit(repo);
      addTearDown(cubit.close);
      await cubit.refresh();
      expect(cubit.state.items, hasLength(20));
      await cubit.loadMore();
      expect(cubit.state.items, hasLength(20));
      expect(cubit.state.moreErrorCode, 'SERVICE_UNAVAILABLE');
      repo.failMore = false;
      await cubit.loadMore();
      expect(cubit.state.items, hasLength(23));
      expect(cubit.state.nextCursor, isNull);
      expect(cubit.state.moreErrorCode, isNull);
    },
  );
}

class _FailingRepository implements TripsRepository {
  bool fail = true;

  @override
  Stream<void> get changes => const Stream<void>.empty();

  @override
  Future<TripsPage> list({
    TripsFilter filter = TripsFilter.all,
    String? cursor,
    int limit = 20,
  }) async {
    if (fail) throw const TripsFailure('SERVICE_UNAVAILABLE');
    return const TripsPage(items: [], nextCursor: null);
  }

  @override
  Future<Trip?> find(String tripId) async {
    if (fail) throw const TripsFailure('SERVICE_UNAVAILABLE');
    return null;
  }

  @override
  Future<Trip> cancel(String tripId) async =>
      throw const TripsFailure('SERVICE_UNAVAILABLE');
}

class _IntermittentTripsRepository implements TripsRepository {
  _IntermittentTripsRepository(this.delegate);
  final TripsRepository delegate;
  bool failCancel = false;
  bool failMore = false;

  @override
  Stream<void> get changes => delegate.changes;

  @override
  Future<TripsPage> list({
    TripsFilter filter = TripsFilter.all,
    String? cursor,
    int limit = 20,
  }) {
    if (failMore && cursor != null) {
      throw const TripsFailure('SERVICE_UNAVAILABLE');
    }
    return delegate.list(filter: filter, cursor: cursor, limit: limit);
  }

  @override
  Future<Trip?> find(String tripId) => delegate.find(tripId);

  @override
  Future<Trip> cancel(String tripId) {
    if (failCancel) throw const TripsFailure('SERVICE_UNAVAILABLE');
    return delegate.cancel(tripId);
  }
}
