import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/features/notifications/domain/notifications_repository.dart';

/// Inbox mutations are authoritative; a stale initial count cannot replace them.
final class HomeUnreadCountCubit extends Cubit<int?> {
  HomeUnreadCountCubit(this._source) : super(null) {
    _subscription = _source.unreadChanges.listen(
      (count) {
        ++_revision;
        if (!isClosed) emit(count);
      },
      onError: (Object error, StackTrace stack) {
        ++_revision;
        if (!isClosed) emit(null);
      },
    );
  }

  final NotificationsUnreadCountSource _source;
  late final StreamSubscription<int> _subscription;
  int _revision = 0;

  Future<void> load() async {
    final revision = ++_revision;
    try {
      final count = await _source.getUnreadCount();
      if (!isClosed && revision == _revision) emit(count);
    } catch (_) {
      if (!isClosed && revision == _revision) emit(null);
    }
  }

  @override
  Future<void> close() async {
    ++_revision;
    await _subscription.cancel();
    await super.close();
  }
}
