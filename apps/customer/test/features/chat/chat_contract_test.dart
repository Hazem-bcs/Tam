import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/chat/data/chat_codec.dart';
import 'package:tam_customer/features/chat/data/mock/mock_chat_repository.dart';
import 'chat_test_support.dart';

Map<String, dynamic> example(String name) =>
    jsonDecode(
          File('../../docs/api/chat/examples/$name.json').readAsStringSync(),
        )
        as Map<String, dynamic>;
void main() {
  test('every documented success/error envelope decodes', () {
    final files = Directory(
      '../../docs/api/chat/examples',
    ).listSync().whereType<File>();
    for (final file in files) {
      final name = file.uri.pathSegments.last;
      final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      if (name.startsWith('messages-')) {
        final page = ChatCodec.page(data);
        expect(page.metadata.tripId, 'trip-1');
      } else if (name.startsWith('send-')) {
        expect(ChatCodec.sent(data).message.sequence, 4);
      } else if (name.startsWith('read-')) {
        expect(ChatCodec.read(data).customerReadThrough, 3);
      } else {
        expect(ChatCodec.failure(data).code, isNotEmpty);
      }
    }
  });
  test('wire fixtures match mock fetch/send/read exactly', () async {
    final store = chatStore();
    final repo = MockChatRepository(store, now: () => chatNow);
    expect(
      ChatCodec.encodePage(await repo.fetch('trip-1')),
      example('messages-success'),
    );
    final sent = await repo.send(
      'trip-1',
      clientMessageId: 'demo-client-message-1',
      body: 'أنا عند المدخل.',
    );
    final expected = ChatCodec.sent(example('send-success'));
    expect(sent.message, expected.message);
    expect(sent.metadata, expected.metadata);
    await repo.dispose();
    final fresh = MockChatRepository(store, now: () => chatNow);
    expect(
      await fresh.markRead('trip-1', 3),
      ChatCodec.read(example('read-success')),
    );
    await fresh.dispose();
    await store.dispose();
  });
  test('Postman saved responses are versioned examples with no secrets', () {
    final collection =
        jsonDecode(
              File(
                '../../docs/api/chat/chat-v1.postman_collection.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    expect(
      collection['info']['schema'],
      'https://schema.getpostman.com/json/collection/v2.1.0/collection.json',
    );
    expect(collection['item'], hasLength(4));
    final token = (collection['variable'] as List).firstWhere(
      (v) => v['key'] == 'access_token',
    );
    expect(token['value'], '');
    for (final item in collection['item']) {
      expect(
        item['request']['url'],
        startsWith('{{base_url}}/trips/{{trip_id}}/chat/'),
      );
      final request = item['request'] as Map<String, dynamic>;
      final identity = (request['header'] as List).singleWhere(
        (header) => header['key'] == 'X-Chat-Driver-Id',
      );
      expect(identity['value'], '{{driver_id}}');
      final initialGet = identical(item, collection['item'][0]);
      expect(identity['disabled'] == true, initialGet);
      for (final response in item['response']) {
        expect(response['originalRequest'], request);
        expect(
          jsonDecode(response['body'] as String),
          example(response['name'] as String),
        );
      }
    }
  });
  test(
    'codec rejects invalid UTC, version, cursor, duplicates and identities',
    () {
      void invalid(void Function(Map<String, dynamic>) mutate) {
        final value = example('messages-success');
        mutate(value);
        expect(() => ChatCodec.page(value), throwsFormatException);
      }

      invalid((j) => j['data']['metadata']['version'] = 2);
      invalid((j) => j['data']['metadata']['revision'] = 0);
      invalid((j) => j['data']['metadata']['can_send'] = 'true');
      invalid((j) => j['data']['metadata']['read_through'] = 9);
      invalid(
        (j) => j['data']['messages'][0]['sent_at'] = '2026-02-30T12:00:00Z',
      );
      invalid(
        (j) =>
            j['data']['messages'][0]['sent_at'] = '2026-11-09T12:00:00+00:00',
      );
      invalid((j) => j['data']['messages'][1]['sequence'] = 1);
      invalid(
        (j) => j['data']['messages'][1]['id'] = j['data']['messages'][0]['id'],
      );
      invalid((j) => j['data']['messages'][1]['client_message_id'] = null);
      invalid(
        (j) => j['data']['messages'][0]['client_message_id'] = 'customer-id',
      );
      invalid((j) => j['data']['messages'][0]['body'] = ' x ');
      invalid(
        (j) =>
            j['data']['messages'][0]['body'] = List.filled(1001, '😀').join(),
      );
      invalid((j) => j['data']['next_before_sequence'] = 3);
      invalid((j) => j['data'].remove('next_before_sequence'));
      invalid(
        (j) =>
            j['data']['messages'] = List.filled(31, j['data']['messages'][0]),
      );
    },
  );
}
