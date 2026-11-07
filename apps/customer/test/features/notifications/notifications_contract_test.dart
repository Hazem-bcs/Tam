import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/notifications/data/mock/notifications_fixture.dart';
import 'package:tam_customer/features/notifications/data/notifications_codec.dart';

void main() {
  final examples = Directory('../../docs/api/notifications/examples');

  Map<String, dynamic> example(String name) =>
      jsonDecode(File('${examples.path}/$name').readAsStringSync())
          as Map<String, dynamic>;

  test('saved pages match exact mock fixtures and parse in Flutter', () {
    final first = example('notifications-page-1.json');
    final second = example('notifications-page-2.json');
    expect(first['data'], mockNotificationsFixture.take(2).toList());
    expect(second['data'], mockNotificationsFixture.skip(2).take(2).toList());
    expect(NotificationsCodec.page(first).items.length, 2);
    expect(NotificationsCodec.page(second).items.length, 2);
    expect(NotificationsCodec.page(first).nextCursor, isNotNull);
    expect(
      NotificationsCodec.page(example('notifications-empty.json')).items,
      isEmpty,
    );
  });

  test('API counter and mark mutations match domain parsing', () {
    expect(NotificationsCodec.unreadCount(example('unread-count.json')), 4);
    final read = NotificationsCodec.itemResponse(example('mark-read.json'));
    expect(read.id, mockNotificationsFixture.first['id']);
    expect(read.readAt, DateTime.utc(2026, 11, 7, 15));
    final all = NotificationsCodec.readAll(example('mark-all-read.json'));
    expect(all.unreadCount, 0);
    expect(all.readAt, DateTime.utc(2026, 11, 7, 15));
  });

  test('unknown and missing-trip examples contain no navigable target', () {
    expect(
      NotificationsCodec.itemResponse(
        example('unknown-target.json'),
      ).target.canOpen,
      isFalse,
    );
    expect(
      NotificationsCodec.itemResponse(
        example('missing-trip-target.json'),
      ).target.canOpen,
      isFalse,
    );
  });

  test('all sample errors are bilingual and stable', () {
    for (final name in [
      'error-invalid-cursor.json',
      'error-unauthenticated.json',
      'error-not-found.json',
      'error-forbidden.json',
      'error-validation.json',
      'error-service-unavailable.json',
    ]) {
      final error = example(name)['error'] as Map<String, dynamic>;
      expect(error['code'], isA<String>());
      expect((error['message'] as Map)['ar'], isNotEmpty);
      expect((error['message'] as Map)['en'], isNotEmpty);
    }
  });

  test('Postman v2.1 requests and responses are importable-shaped JSON', () {
    final collection =
        jsonDecode(
              File(
                '../../docs/api/notifications/notifications-v1.postman_collection.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    expect(
      (collection['info'] as Map)['schema'],
      'https://schema.getpostman.com/json/collection/v2.1.0/collection.json',
    );
    final items = collection['item'] as List;
    expect(items.length, 5);
    for (final item in items) {
      final request = (item as Map)['request'] as Map;
      expect(request['method'], anyOf('GET', 'POST'));
      expect((request['url'] as Map)['raw'], contains('{{base_url}}'));
      for (final response in item['response'] as List) {
        final json = jsonDecode((response as Map)['body'] as String) as Map;
        expect(json.containsKey('data') || json.containsKey('error'), isTrue);
      }
    }
  });
}
