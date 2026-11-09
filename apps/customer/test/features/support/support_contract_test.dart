import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/support/data/mock/mock_support_repository.dart';
import 'package:tam_customer/features/support/data/support_wire_mapper.dart';
import 'package:tam_customer/features/support/domain/support_repository.dart';
import 'support_test_support.dart';

final _root = Directory('../../docs/api/support');
Map<String, dynamic> example(String name) =>
    jsonDecode(File('${_root.path}/examples/$name.json').readAsStringSync())
        as Map<String, dynamic>;

void expectTicket(SupportTicket actual, SupportTicket expected) {
  expect(
    [
      actual.id,
      actual.clientRequestId,
      actual.categoryId,
      actual.body,
      actual.tripId,
      actual.status,
      actual.createdAt,
      actual.updatedAt,
      actual.revision,
    ],
    [
      expected.id,
      expected.clientRequestId,
      expected.categoryId,
      expected.body,
      expected.tripId,
      expected.status,
      expected.createdAt,
      expected.updatedAt,
      expected.revision,
    ],
  );
}

void main() {
  test(
    'catalog, created ticket and unpublished legal match the actual mock',
    () async {
      final store = supportStore();
      final repo = MockSupportRepository(store, now: () => supportNow);
      addTearDown(repo.dispose);
      addTearDown(store.dispose);
      for (final tripId in [null, 'trip-1']) {
        final actual = await repo.options(tripId: tripId);
        final decoded = SupportWireMapper.options(
          example(tripId == null ? 'options-general' : 'options-trip'),
        );
        expect(decoded.tripId, actual.tripId);
        expect(
          decoded.categories.map(
            (c) => [c.id, c.nameAr, c.nameEn, c.tripRequired],
          ),
          actual.categories.map(
            (c) => [c.id, c.nameAr, c.nameEn, c.tripRequired],
          ),
        );
      }
      final request = example('create-request');
      final created = await repo.create(
        clientRequestId: request['client_request_id'] as String,
        categoryId: request['category_id'] as String,
        body: request['body'] as String,
        tripId: request['trip_id'] as String,
      );
      expectTicket(
        SupportWireMapper.ticket(example('ticket-created')),
        created,
      );
      for (final kind in LegalDocumentKind.values) {
        for (final locale in ['ar', 'en']) {
          expect(
            SupportWireMapper.legal(example('legal-unpublished')),
            await repo.legal(kind, languageCode: locale),
          );
        }
      }
    },
  );
  test(
    'two cursor pages match 25 deterministic mock records without omissions',
    () async {
      final store = supportStore();
      var now = supportNow;
      final repo = MockSupportRepository(store, now: () => now);
      addTearDown(repo.dispose);
      addTearDown(store.dispose);
      expect(SupportWireMapper.page(example('tickets-empty')).tickets, isEmpty);
      for (var i = 1; i <= 25; i++) {
        now = supportNow.add(Duration(seconds: i));
        await repo.create(
          clientRequestId: 'request-${i.toString().padLeft(16, '0')}',
          categoryId: 'general',
          body: 'Issue details $i',
        );
      }
      String? cursor;
      final ids = <String>{};
      for (var page = 1; page <= 2; page++) {
        final actual = await repo.tickets(cursor: cursor);
        final decoded = SupportWireMapper.page(example('tickets-page-$page'));
        expect(decoded.tickets.length, actual.tickets.length);
        expect(decoded.nextCursor, actual.nextCursor);
        for (var i = 0; i < actual.tickets.length; i++) {
          expectTicket(decoded.tickets[i], actual.tickets[i]);
          expect(ids.add(decoded.tickets[i].id), isTrue);
        }
        cursor = actual.nextCursor;
      }
      expect(ids, hasLength(25));
      expect(cursor, isNull);
    },
  );
  test(
    'strict parsing rejects malformed payloads, context, timestamps and pagination',
    () {
      for (final mutate in <void Function(Map<String, dynamic>)>[
        (d) => d['revision'] = 0,
        (d) => d['revision'] = 1.5,
        (d) => d['status'] = 'unknown',
        (d) => d['client_request_id'] = 'short',
        (d) => d['body'] = 'a' * 9,
        (d) => d['body'] = '😀' * 2001,
        (d) => d['body'] = ' untrimmed ',
        (d) => d['updated_at'] = '2026-11-09T11:00:00.000Z',
        (d) => d['created_at'] = '2026-11-09T12:00:00',
        (d) => d['created_at'] = '2026-02-31T12:00:00Z',
        (d) => d['id'] = '',
        (d) => d.remove('trip_id'),
      ]) {
        final json = example('ticket-created');
        mutate(json['data'] as Map<String, dynamic>);
        expect(() => SupportWireMapper.ticket(json), throwsFormatException);
      }
      final options = example('options-trip');
      options['data']['trip_id'] = null;
      expect(() => SupportWireMapper.options(options), throwsFormatException);
      final page = example('tickets-page-1');
      (page['data']['tickets'] as List).removeLast();
      expect(() => SupportWireMapper.page(page), throwsFormatException);
      final order = example('tickets-page-1');
      (order['data']['tickets'] as List).insert(
        0,
        order['data']['tickets'].last,
      );
      expect(() => SupportWireMapper.page(order), throwsFormatException);
      expect(
        () => SupportWireMapper.legal({'data': null, 'error': {}}),
        throwsFormatException,
      );
    },
  );
  test(
    'Postman v2.1 paths, auth, request and saved responses agree with examples',
    () {
      final collection =
          jsonDecode(
                File(
                  '${_root.path}/support-v1.postman_collection.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      expect(collection['info']['schema'], contains('/v2.1.0/'));
      expect(collection['auth']['type'], 'bearer');
      final codes = <String>{};
      final items = collection['item'] as List;
      expect(items, hasLength(7));
      for (final item in items) {
        final request = item['request'];
        final raw = request['url']['raw'] as String;
        final public = raw.contains('/content/legal/');
        expect(raw, startsWith('{{base_url}}/'));
        if (public) {
          expect(request['auth']['type'], 'noauth');
          expect(
            (request['header'] as List).any((h) => h['key'] == 'Authorization'),
            isFalse,
          );
        } else {
          expect(request['auth'], isNull);
        }
        if (request['method'] == 'POST') {
          final body =
              jsonDecode(request['body']['raw'] as String)
                  as Map<String, dynamic>;
          body['client_request_id'] = 'request-0000000001';
          body['trip_id'] = 'trip-1';
          expect(body, example('create-request'));
        }
        for (final response in item['response'] as List) {
          final body =
              jsonDecode(response['body'] as String) as Map<String, dynamic>;
          expect(response['originalRequest'], request);
          if ((response['code'] as int) >= 400) {
            final failure = SupportWireMapper.failure(body);
            codes.add(failure.code);
            expect(body, example(failure.code.toLowerCase()));
            if (public) {
              expect(
                {'UNAUTHENTICATED', 'FORBIDDEN'}.contains(failure.code),
                isFalse,
              );
            }
          } else if (public) {
            expect(SupportWireMapper.legal(body), isNull);
          } else if (raw.contains('/options')) {
            expect(SupportWireMapper.options(body).categories, isNotEmpty);
          } else if (request['method'] == 'POST' ||
              raw.contains('{{ticket_id}}')) {
            expect(SupportWireMapper.ticket(body).id, isNotEmpty);
          } else {
            SupportWireMapper.page(body);
          }
        }
      }
      expect(codes, {
        'UNAUTHENTICATED',
        'FORBIDDEN',
        'TRIP_NOT_FOUND',
        'TICKET_NOT_FOUND',
        'IDEMPOTENCY_CONFLICT',
        'VALIDATION_ERROR',
        'INVALID_CATEGORY',
        'INVALID_CURSOR',
        'RATE_LIMITED',
        'SERVICE_UNAVAILABLE',
      });
    },
  );
}
