import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/home/presentation/bloc/home_unread_count_cubit.dart';
import 'package:tam_customer/features/notifications/data/mock/mock_notifications_repository.dart';
import 'package:tam_customer/features/notifications/data/unavailable_notifications_repository.dart';
import 'package:tam_customer/features/notifications/domain/notifications_repository.dart';

final class _ControlledCount implements NotificationsUnreadCountSource {
  final count = Completer<int>();
  final changes = StreamController<int>.broadcast(sync: true);

  @override
  Future<int> getUnreadCount() => count.future;

  @override
  Stream<int> get unreadChanges => changes.stream;
}

void main() {
  test('an inbox event wins over a stale initial badge request', () async {
    final source = _ControlledCount();
    final cubit = HomeUnreadCountCubit(source);
    final load = cubit.load();
    source.changes.add(2);
    source.count.complete(4);
    await load;
    expect(cubit.state, 2);
    await cubit.close();
    expect(source.changes.hasListener, false);
    await source.changes.close();
  });

  test('API failure leaves the badge unknown without mock fallback', () async {
    final cubit = HomeUnreadCountCubit(
      const UnavailableNotificationsRepository(),
    );
    await cubit.load();
    expect(cubit.state, isNull);
    await cubit.close();
  });

  test('closed badge ignores an outstanding count response', () async {
    final source = _ControlledCount();
    final cubit = HomeUnreadCountCubit(source);
    final load = cubit.load();
    await cubit.close();
    source.count.complete(4);
    await load;
    expect(cubit.state, isNull);
    await source.changes.close();
  });

  test(
    'session reset restores fixtures and publishes the authoritative count',
    () async {
      final repository = MockNotificationsRepository();
      final cubit = HomeUnreadCountCubit(repository);
      await cubit.load();
      await repository.markAllAsRead();
      expect(cubit.state, 0);
      repository.resetSession();
      expect(cubit.state, 4);
      expect((await repository.getPage()).items.first.isUnread, true);
      await cubit.close();
      expect(repository.hasUnreadListeners, false);
      await repository.dispose();
    },
  );
}
