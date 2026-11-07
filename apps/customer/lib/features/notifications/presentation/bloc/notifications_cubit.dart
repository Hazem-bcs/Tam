import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/notifications_repository.dart';
import 'notifications_state.dart';

/// Owns UI orchestration only. All count changes originate at the repository.
final class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repository) : super(const NotificationsState()) {
    _countSubscription = _repository.unreadChanges.listen((count) {
      if (!isClosed) emit(state.copyWith(unreadCount: count));
    });
  }

  final NotificationsRepository _repository;
  late final StreamSubscription<int> _countSubscription;
  int _version = 0;

  NotificationsFailureCode _failure(Object error) =>
      error is NotificationsFailure
      ? error.code
      : NotificationsFailureCode.invalidResponse;

  Future<void> load({bool refresh = false}) async {
    if (state.isBusy || state.pendingReadIds.isNotEmpty) return;
    final version = ++_version;
    final retainsItems =
        refresh && state.status == NotificationsLoadStatus.ready;
    emit(
      state.copyWith(
        status: retainsItems
            ? NotificationsLoadStatus.ready
            : NotificationsLoadStatus.loading,
        refreshing: retainsItems,
        error: null,
        moreError: null,
        mutationError: null,
      ),
    );
    try {
      final batch = await _repository.getPage();
      final count = await _repository.getUnreadCount();
      if (isClosed || version != _version) return;
      emit(
        state.copyWith(
          status: NotificationsLoadStatus.ready,
          refreshing: false,
          items: List.unmodifiable(batch.items),
          nextCursor: batch.nextCursor,
          unreadCount: count,
          error: null,
        ),
      );
    } catch (error) {
      if (isClosed || version != _version) return;
      emit(
        state.copyWith(
          status: retainsItems
              ? NotificationsLoadStatus.ready
              : NotificationsLoadStatus.error,
          refreshing: false,
          error: _failure(error),
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isBusy ||
        state.pendingReadIds.isNotEmpty ||
        state.nextCursor == null ||
        state.status != NotificationsLoadStatus.ready) {
      return;
    }
    final version = ++_version;
    final cursor = state.nextCursor!;
    emit(state.copyWith(loadingMore: true, moreError: null));
    try {
      final page = await _repository.getPage(cursor: cursor);
      if (isClosed || version != _version) return;
      final ids = state.items.map((item) => item.id).toSet();
      final appended = page.items.where((item) => ids.add(item.id));
      emit(
        state.copyWith(
          loadingMore: false,
          items: List.unmodifiable([...state.items, ...appended]),
          nextCursor: page.nextCursor,
        ),
      );
    } catch (error) {
      if (isClosed || version != _version) return;
      emit(state.copyWith(loadingMore: false, moreError: _failure(error)));
    }
  }

  Future<void> markAsRead(String id) async {
    if (state.markingAll || state.pendingReadIds.contains(id)) return;
    final existing = state.items.where((item) => item.id == id).firstOrNull;
    if (existing == null || !existing.isUnread) return;
    ++_version; // Invalidate stale pages that began before a mutation.
    emit(
      state.copyWith(
        refreshing: false,
        loadingMore: false,
        pendingReadIds: {...state.pendingReadIds, id},
        mutationError: null,
      ),
    );
    try {
      final updated = await _repository.markAsRead(id);
      if (isClosed) return;
      emit(
        state.copyWith(
          items: List.unmodifiable([
            for (final item in state.items) item.id == id ? updated : item,
          ]),
          pendingReadIds: {...state.pendingReadIds}..remove(id),
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          pendingReadIds: {...state.pendingReadIds}..remove(id),
          mutationError: _failure(error),
        ),
      );
    }
  }

  Future<void> markAllAsRead() async {
    if (state.markingAll ||
        state.pendingReadIds.isNotEmpty ||
        state.isBusy ||
        state.unreadCount == 0) {
      return;
    }
    ++_version;
    emit(state.copyWith(markingAll: true, mutationError: null));
    try {
      final result = await _repository.markAllAsRead();
      if (isClosed) return;
      emit(
        state.copyWith(
          markingAll: false,
          unreadCount: result.unreadCount,
          items: List.unmodifiable([
            for (final item in state.items)
              item.isUnread ? item.withReadAt(result.readAt) : item,
          ]),
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(markingAll: false, mutationError: _failure(error)));
    }
  }

  @override
  Future<void> close() async {
    ++_version;
    await _countSubscription.cancel();
    await super.close();
  }
}
