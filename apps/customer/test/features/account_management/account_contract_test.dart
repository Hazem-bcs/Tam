import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/account_management/data/account_wire_mapper.dart';
import 'package:tam_customer/features/account_management/data/mock/mock_account_management_repository.dart';
import 'package:tam_customer/features/account_management/domain/account_management_repository.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'account_test_support.dart';

Map<String, dynamic> example(String name) =>
    jsonDecode(
          File(
            '../../docs/api/account_management/examples/$name.json',
          ).readAsStringSync(),
        )
        as Map<String, dynamic>;
void main() {
  for (final purpose in ['change_phone', 'delete_account']) {
    test('$purpose examples match actual mock and strict mapper', () async {
      final trips = MockTripStore();
      final repo = MockAccountManagementRepository(
        trips,
        phone: () => '+963912345678',
        now: () => accountNow,
      );
      addTearDown(trips.dispose);
      addTearDown(repo.dispose);
      final actual = await repo.eligibility(),
          expected = AccountWireMapper.eligibility(example('eligibility'));
      expect(actual.phoneE164, expected.phoneE164);
      expect(actual.activeTripIds, expected.activeTripIds);
      final body = example('$purpose-request');
      final challenge = await repo.start(
        action: purpose == 'change_phone'
            ? AccountAction.changePhone
            : AccountAction.deleteAccount,
        operationId: body['operation_id'] as String,
        newPhoneE164: body['new_phone_e164'] as String?,
      );
      expect(
        AccountWireMapper.challenge(example('$purpose-challenge')),
        challenge,
      );
      expect(
        AccountWireMapper.recoveryToken(example('$purpose-challenge')),
        hasLength(64),
      );
      final receipt = await repo.confirm(
        challengeId: challenge.id,
        operationId: operationId,
        code: '123456',
      );
      expect(AccountWireMapper.receipt(example('$purpose-completed')), receipt);
      expect(AccountWireMapper.receipt(example('operation-pending')), isNull);
    });
  }
  test(
    'mapper rejects invalid phone, UTC, purpose, identity types and mixed envelopes',
    () {
      for (final mutate in <void Function(Map<String, dynamic>)>[
        (d) => d['revision'] = 0,
        (d) => d['attempts_remaining'] = 6,
        (d) => d['purpose'] = 'login',
        (d) => d['operation_id'] = 'short',
        (d) => d['phone_e164'] = '0944444444',
        (d) => d['expires_at'] = '2026-02-31T12:05:00Z',
        (d) => d['resend_at'] = d['expires_at'],
      ]) {
        final value = example('change_phone-challenge');
        mutate(value['data'] as Map<String, dynamic>);
        expect(() => AccountWireMapper.challenge(value), throwsFormatException);
      }
      expect(
        () => AccountWireMapper.receipt({'data': null, 'error': {}}),
        throwsFormatException,
      );
      final bad = example('change_phone-challenge');
      bad['data']['recovery_token'] = 'unsafe';
      expect(() => AccountWireMapper.recoveryToken(bad), throwsFormatException);
    },
  );
  test(
    'Postman source contains seven documented operations and scoped receipt auth',
    () {
      final collection = jsonDecode(
        File(
          '../../docs/api/account_management/account_management-v1.postman_collection.json',
        ).readAsStringSync(),
      );
      expect(collection['auth']['type'], 'bearer');
      expect(collection['item'], hasLength(7));
      for (final item in collection['item'] as List) {
        final request = item['request'];
        final path = request['url']['raw'] as String;
        if (path.contains('/account/operations/')) {
          expect(request['auth']['type'], 'noauth');
        }
        if (path.contains('/confirm') ||
            path.contains('/account/operations/')) {
          expect(
            (request['header'] as List).any(
              (h) => h['key'] == 'X-Operation-Token',
            ),
            isTrue,
          );
        }
        for (final response in item['response'] as List) {
          final body =
              jsonDecode(response['body'] as String) as Map<String, dynamic>;
          if (response['code'] == 200) {
            if (path.endsWith('/eligibility')) {
              AccountWireMapper.eligibility(body);
            } else if (path.endsWith('/challenges') ||
                path.endsWith('/resend')) {
              AccountWireMapper.challenge(body);
            } else {
              AccountWireMapper.receipt(body);
            }
          } else {
            expect(AccountWireMapper.failure(body).code, response['name']);
          }
        }
      }
    },
  );
}
