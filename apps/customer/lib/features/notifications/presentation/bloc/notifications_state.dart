import 'package:equatable/equatable.dart';

import '../../domain/customer_notification.dart';
import '../../domain/notifications_repository.dart';

enum NotificationsLoadStatus { initial, loading, ready, error }

const _notProvided = Object();

final class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsLoadStatus.initial,
    this.items = const [],
    this.nextCursor,
    this.unreadCount,
    this.refreshing = false,
    this.loadingMore = false,
    this.markingAll = false,
    this.pendingReadIds = const {},
    this.error,
    this.moreError,
    this.mutationError,
  });

  final NotificationsLoadStatus status;
  final List<CustomerNotification> items;
  final String? nextCursor;
  final int? unreadCount;
  final bool refreshing;
  final bool loadingMore;
  final bool markingAll;
  final Set<String> pendingReadIds;
  final NotificationsFailureCode? error;
  final NotificationsFailureCode? moreError;
  final NotificationsFailureCode? mutationError;

  bool get hasMore => nextCursor != null;
  bool get isBusy =>
      refreshing ||
      loadingMore ||
      markingAll ||
      status == NotificationsLoadStatus.loading;

  NotificationsState copyWith({
    NotificationsLoadStatus? status,
    List<CustomerNotification>? items,
    Object? nextCursor = _notProvided,
    Object? unreadCount = _notProvided,
    bool? refreshing,
    bool? loadingMore,
    bool? markingAll,
    Set<String>? pendingReadIds,
    Object? error = _notProvided,
    Object? moreError = _notProvided,
    Object? mutationError = _notProvided,
  }) => NotificationsState(
    status: status ?? this.status,
    items: items ?? this.items,
    nextCursor: identical(nextCursor, _notProvided)
        ? this.nextCursor
        : nextCursor as String?,
    unreadCount: identical(unreadCount, _notProvided)
        ? this.unreadCount
        : unreadCount as int?,
    refreshing: refreshing ?? this.refreshing,
    loadingMore: loadingMore ?? this.loadingMore,
    markingAll: markingAll ?? this.markingAll,
    pendingReadIds: pendingReadIds ?? this.pendingReadIds,
    error: identical(error, _notProvided)
        ? this.error
        : error as NotificationsFailureCode?,
    moreError: identical(moreError, _notProvided)
        ? this.moreError
        : moreError as NotificationsFailureCode?,
    mutationError: identical(mutationError, _notProvided)
        ? this.mutationError
        : mutationError as NotificationsFailureCode?,
  );

  @override
  List<Object?> get props => [
    status,
    items,
    nextCursor,
    unreadCount,
    refreshing,
    loadingMore,
    markingAll,
    pendingReadIds,
    error,
    moreError,
    mutationError,
  ];
}
