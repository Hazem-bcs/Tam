import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/notifications/data/mock/notifications_fixture.dart';
import 'package:tam_customer/features/notifications/data/notifications_codec.dart';

void main() {
  test('codec rejects normalized invalid dates and blank required text', () {
    for (final invalidDate in [
      '2026-02-30T12:00:00Z',
      '2026-11-07T25:00:00Z',
    ]) {
      final item = Map<String, dynamic>.from(mockNotificationsFixture.first)
        ..['created_at'] = invalidDate;
      expect(() => NotificationsCodec.item(item), throwsFormatException);
      expect(
        () => NotificationsCodec.readAll({
          'data': {'unread_count': 0, 'read_at': invalidDate},
        }),
        throwsFormatException,
      );
    }
    for (final field in ['title', 'body']) {
      final item = Map<String, dynamic>.from(mockNotificationsFixture.first)
        ..[field] = {'ar': ' ', 'en': 'Valid'};
      expect(() => NotificationsCodec.item(item), throwsFormatException);
    }
    final item = Map<String, dynamic>.from(mockNotificationsFixture.first)
      ..['id'] = ' ';
    expect(() => NotificationsCodec.item(item), throwsFormatException);
  });

  test('nullable contract fields must still be present', () {
    final item = Map<String, dynamic>.from(mockNotificationsFixture.first)
      ..remove('read_at');
    expect(() => NotificationsCodec.item(item), throwsFormatException);
    expect(
      () => NotificationsCodec.page({'data': [], 'meta': <String, dynamic>{}}),
      throwsFormatException,
    );
  });
}
