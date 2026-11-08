import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/trips/domain/trips_repository.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trip_details_cubit.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trips_list_cubit.dart';
import 'package:tam_customer/shared/data/mock/seed_trips.dart';
import 'package:tam_customer/shared/domain/trip.dart';

void main() {
  test('an older details read cannot undo a successful cancellation', () async {
    final repo = _ControlledRepository();
    final cubit = TripDetailsCubit(repo, repo.trip.id);
    addTearDown(cubit.close);
    repo.reads.single.complete(repo.trip);
    await Future<void>.delayed(Duration.zero);
    final pendingRead = cubit.reload();
    final staleRead = repo.reads.last;
    expect(await cubit.cancel(), isTrue);
    staleRead.complete(repo.trip);
    await pendingRead;
    expect(cubit.state.trip?.status, TripStatus.cancelled);
    expect(cubit.state.isLoading, isFalse);
  });

  test('late filter response cannot overwrite the selected filter', () async {
    final repo = _ControlledRepository();
    final cubit = TripsListCubit(repo);
    addTearDown(cubit.close);
    final initial = repo.pages.single;
    final selected = cubit.selectFilter(TripsFilter.cancelled);
    repo.pages.last.complete(const TripsPage(items: [], nextCursor: null));
    await selected;
    initial.complete(TripsPage(items: [repo.trip], nextCursor: null));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.filter, TripsFilter.cancelled);
    expect(cubit.state.items, isEmpty);
  });

  test(
    'store invalidation blocks loading an obsolete next-page cursor',
    () async {
      final changes = StreamController<void>.broadcast(sync: true);
      addTearDown(changes.close);
      final repo = _ControlledRepository()..invalidations = changes.stream;
      final cubit = TripsListCubit(repo);
      addTearDown(cubit.close);
      repo.pages.single.complete(
        TripsPage(items: [repo.trip], nextCursor: 'old-cursor'),
      );
      await Future<void>.delayed(Duration.zero);
      changes.add(null);
      final more = cubit.loadMore();
      expect(
        repo.pages,
        hasLength(2),
      ); // Initial page plus invalidation reload only.
      repo.pages.last.complete(TripsPage(items: [repo.trip], nextCursor: null));
      await more;
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.nextCursor, isNull);
    },
  );

  test('closing while a request is pending ignores late completions', () async {
    final repo = _ControlledRepository();
    final cubit = TripDetailsCubit(repo, repo.trip.id);
    await cubit.close();
    repo.reads.single.complete(repo.trip);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.isClosed, isTrue);
  });
}

class _ControlledRepository implements TripsRepository {
  final trip = seedMockTrips().first.withStatus(TripStatus.requested);
  final reads = <Completer<Trip?>>[];
  final pages = <Completer<TripsPage>>[];

  Stream<void>? invalidations;
  @override
  Stream<void> get changes => invalidations ?? const Stream.empty();

  @override
  Future<Trip?> find(String tripId) {
    final pending = Completer<Trip?>();
    reads.add(pending);
    return pending.future;
  }

  @override
  Future<TripsPage> list({
    TripsFilter filter = TripsFilter.all,
    String? cursor,
    int limit = 20,
  }) {
    final pending = Completer<TripsPage>();
    pages.add(pending);
    return pending.future;
  }

  @override
  Future<Trip> cancel(String tripId) async =>
      trip.withStatus(TripStatus.cancelled);
}
