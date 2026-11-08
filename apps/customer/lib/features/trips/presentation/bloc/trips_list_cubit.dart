import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/features/trips/domain/trips_repository.dart';
import 'package:tam_customer/shared/domain/trip.dart';

const _unchanged = Object();

final class TripsListState extends Equatable {
  const TripsListState({
    this.filter = TripsFilter.all,
    this.items = const [],
    this.nextCursor,
    this.isLoading = true,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.errorCode,
    this.moreErrorCode,
  });

  final TripsFilter filter;
  final List<Trip> items;
  final String? nextCursor;
  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? errorCode;
  final String? moreErrorCode;

  TripsListState copyWith({
    TripsFilter? filter,
    List<Trip>? items,
    Object? nextCursor = _unchanged,
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    Object? errorCode = _unchanged,
    Object? moreErrorCode = _unchanged,
  }) => TripsListState(
    filter: filter ?? this.filter,
    items: items ?? this.items,
    nextCursor: identical(nextCursor, _unchanged)
        ? this.nextCursor
        : nextCursor as String?,
    isLoading: isLoading ?? this.isLoading,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    errorCode: identical(errorCode, _unchanged)
        ? this.errorCode
        : errorCode as String?,
    moreErrorCode: identical(moreErrorCode, _unchanged)
        ? this.moreErrorCode
        : moreErrorCode as String?,
  );

  @override
  List<Object?> get props => [
    filter,
    items,
    nextCursor,
    isLoading,
    isRefreshing,
    isLoadingMore,
    errorCode,
    moreErrorCode,
  ];
}

/// Re-queries the same repository on store invalidation; no second trip store.
final class TripsListCubit extends Cubit<TripsListState> {
  TripsListCubit(this._repository) : super(const TripsListState()) {
    _changes = _repository.changes.listen((_) {
      unawaited(refresh(preservePages: true, silent: true));
    });
    unawaited(refresh());
  }

  static const int pageSize = 20;
  final TripsRepository _repository;
  late final StreamSubscription<void> _changes;
  int _pages = 1;
  int _revision = 0;

  Future<void> selectFilter(TripsFilter filter) async {
    if (filter == state.filter) return;
    _pages = 1;
    final revision = ++_revision;
    emit(TripsListState(filter: filter));
    await _reload(revision: revision, targetPages: 1);
  }

  Future<void> refresh({
    bool preservePages = false,
    bool silent = false,
  }) async {
    final revision = ++_revision;
    final pages = preservePages ? _pages : 1;
    if (!preservePages) _pages = 1;
    if (silent) {
      // Keep cached content visible, but never page through an invalid cursor
      // while its replacement snapshot is still loading.
      emit(state.copyWith(isRefreshing: true, isLoadingMore: false));
    } else {
      emit(
        state.copyWith(
          isLoading: state.items.isEmpty,
          isRefreshing: state.items.isNotEmpty,
          isLoadingMore: false,
          errorCode: null,
          moreErrorCode: null,
        ),
      );
    }
    await _reload(revision: revision, targetPages: pages);
  }

  Future<void> _reload({
    required int revision,
    required int targetPages,
  }) async {
    try {
      String? cursor;
      final seen = <String, Trip>{};
      var count = 0;
      for (var index = 0; index < targetPages; index++) {
        final page = await _repository.list(
          filter: state.filter,
          cursor: cursor,
          limit: pageSize,
        );
        if (isClosed || revision != _revision) return;
        for (final trip in page.items) {
          seen[trip.id] = trip;
        }
        count++;
        cursor = page.nextCursor;
        if (cursor == null) break;
      }
      _pages = count;
      emit(
        state.copyWith(
          items: List.unmodifiable(seen.values),
          nextCursor: cursor,
          isLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
          errorCode: null,
          moreErrorCode: null,
        ),
      );
    } on TripsFailure catch (failure) {
      if (isClosed || revision != _revision) return;
      emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
          errorCode: failure.code,
        ),
      );
    }
  }

  Future<void> loadMore() async {
    final cursor = state.nextCursor;
    if (cursor == null ||
        state.isLoading ||
        state.isLoadingMore ||
        state.isRefreshing) {
      return;
    }
    final revision = _revision;
    emit(state.copyWith(isLoadingMore: true, moreErrorCode: null));
    try {
      final page = await _repository.list(
        filter: state.filter,
        cursor: cursor,
        limit: pageSize,
      );
      if (isClosed || revision != _revision) return;
      final seen = <String, Trip>{
        for (final trip in state.items) trip.id: trip,
        for (final trip in page.items) trip.id: trip,
      };
      _pages++;
      emit(
        state.copyWith(
          items: List.unmodifiable(seen.values),
          nextCursor: page.nextCursor,
          isLoadingMore: false,
        ),
      );
    } on TripsFailure catch (failure) {
      if (isClosed || revision != _revision) return;
      emit(state.copyWith(isLoadingMore: false, moreErrorCode: failure.code));
    }
  }

  @override
  Future<void> close() async {
    _revision++;
    await _changes.cancel();
    await super.close();
  }
}
