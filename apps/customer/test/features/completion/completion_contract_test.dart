import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/completion/data/completion_codec.dart';
import 'package:tam_customer/features/completion/data/mock/mock_completion_repository.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/data/mock/seed_trips.dart';
import 'completion_test_support.dart';

void main() {
  final root = Directory('../../docs/api/completion');
  Map<String, dynamic> example(String file) =>
      jsonDecode(File('${root.path}/examples/$file.json').readAsStringSync())
          as Map<String, dynamic>;
  test(
    'unrated and rated examples equal shared fixture and actual mock outputs',
    () async {
      final store = MockTripStore(seed: seedMockTrips());
      final repo = MockCompletionRepository(store, now: () => completionNow);
      final initial = await repo.fetch('mock-history-001');
      expect(CompletionCodec.encode(initial), example('unrated'));
      expect(CompletionCodec.decode(example('unrated')), initial);
      final body = example('submit-request');
      final saved = await repo.submitRating(
        'mock-history-001',
        stars: body['stars'] as int,
        comment: body['comment'] as String,
        idempotencyKey: 'completion-example-key-001',
      );
      expect(CompletionCodec.encode(saved), example('rated'));
      expect(CompletionCodec.decode(example('rated')), saved);
      await repo.dispose();
      await store.dispose();
    },
  );
  test(
    'strict decoder rejects malformed version, identity, timestamp and payload',
    () {
      final mutations = <void Function(Map<String, dynamic>)>[
        (d) => d['version'] = 2,
        (d) => d['revision'] = 0,
        (d) => d['revision'] = 1.5,
        (d) => d.remove('rating'),
        (d) => d['trip']['status'] = 'in_progress',
        (d) => d['rating']['trip_id'] = 'other',
        (d) => d['rating']['id'] = '',
        (d) => d['rating']['idempotency_key'] = ' ',
        (d) => d['rating']['stars'] = 0,
        (d) => d['rating']['stars'] = 6,
        (d) => d['rating']['stars'] = 4.0,
        (d) => d['rating']['comment'] = null,
        (d) => d['rating']['comment'] = ' trailing ',
        (d) => d['rating']['comment'] = '😀' * 501,
        (d) => d['rating']['submitted_at'] = '2026-10-01T00:00:00Z',
        (d) => d['rating']['submitted_at'] = '2026-11-09T12:00:00',
        (d) => d['trip']['fare']['amount_minor'] = -1,
      ];
      for (final mutate in mutations) {
        final envelope = example('rated');
        mutate(envelope['data'] as Map<String, dynamic>);
        expect(() => CompletionCodec.decode(envelope), throwsFormatException);
      }
    },
  );
  test('every error example has the shared bilingual envelope', () {
    for (final code in [
      'VALIDATION_ERROR',
      'TRIP_NOT_COMPLETED',
      'RATING_ALREADY_SUBMITTED',
      'IDEMPOTENCY_CONFLICT',
      'UNAUTHENTICATED',
      'FORBIDDEN',
      'TRIP_NOT_FOUND',
      'RATE_LIMITED',
      'SERVICE_UNAVAILABLE',
    ]) {
      expect(CompletionCodec.failure(example(code.toLowerCase())).code, code);
    }
    expect(
      () => CompletionCodec.failure({
        'error': {
          'code': 'X',
          'message': {'en': 'Error'},
        },
      }),
      throwsFormatException,
    );
  });
  test(
    'Postman v2.1 operations, headers, saved successes and errors match examples',
    () {
      final collection =
          jsonDecode(
                File(
                  '${root.path}/completion-v1.postman_collection.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      expect(collection['info']['schema'], contains('/v2.1.0/'));
      expect(collection['auth']['type'], 'bearer');
      final items = collection['item'] as List;
      expect(items.length, 2);
      final codes = <String>{};
      for (final item in items) {
        final request = item['request'];
        final method = request['method'];
        expect(
          request['url']['raw'],
          '{{base_url}}/trips/{{trip_id}}/${method == 'GET' ? 'completion' : 'rating'}',
        );
        if (method == 'POST') {
          expect(
            (request['header'] as List).any(
              (h) => h['key'] == 'Idempotency-Key',
            ),
            isTrue,
          );
          expect(
            jsonDecode(request['body']['raw'] as String),
            example('submit-request'),
          );
        }
        for (final response in item['response'] as List) {
          final body =
              jsonDecode(response['body'] as String) as Map<String, dynamic>;
          if (response['code'] == 200) {
            final completion = CompletionCodec.decode(body);
            expect(CompletionCodec.encode(completion), body);
          } else {
            final failure = CompletionCodec.failure(body);
            codes.add(failure.code);
            expect(body, example(failure.code.toLowerCase()));
          }
        }
      }
      expect(codes.length, 9);
    },
  );
}
