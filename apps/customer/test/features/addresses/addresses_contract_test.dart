import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/addresses/data/addresses_codec.dart';
import 'package:tam_customer/features/addresses/data/mock/addresses_fixture.dart';
import 'package:tam_customer/features/addresses/data/mock/mock_addresses_repository.dart';

void main() {
  Map<String, dynamic> example(String name) =>
      jsonDecode(
            File(
              '../../docs/api/addresses/examples/$name.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;

  test('examples parse and match actual mock CRUD fixtures', () async {
    expect(example('addresses-success')['data'], addressesFixture);
    expect(AddressesCodec.list(example('addresses-empty')), isEmpty);
    expect(
      AddressesCodec.response(example('address-detail')),
      seedAddresses().first,
    );
    final repository = MockAddressesRepository(
      clock: () => DateTime.utc(2026, 11, 8, 10),
    );
    addTearDown(repository.dispose);
    final created = await repository.create(
      AddressesCodec.input(example('create-request')),
      operationId: 'key',
    );
    expect(created, AddressesCodec.response(example('create-success')));
    final updated = await repository.update(
      'address-home-001',
      AddressesCodec.input(example('update-request')),
    );
    expect(updated, AddressesCodec.response(example('update-success')));
  });

  test('Postman v2.1 includes CRUD and reused places with safe variables', () {
    final collection =
        jsonDecode(
              File(
                '../../docs/api/addresses/addresses-v1.postman_collection.json',
              ).readAsStringSync(),
            )
            as Map;
    expect(
      collection['info']['schema'],
      'https://schema.getpostman.com/json/collection/v2.1.0/collection.json',
    );
    expect(collection['auth']['type'], 'bearer');
    final items = collection['item'] as List;
    expect(items, hasLength(6));
    for (final item in items) {
      expect(item['request']['url']['raw'], startsWith('{{base_url}}/'));
      for (final response in item['response'] as List) {
        if (response['code'] == 204) {
          expect(response['body'], isEmpty);
        } else {
          final body = jsonDecode(response['body'] as String) as Map;
          expect(body.containsKey('data') || body.containsKey('error'), true);
          if (body.containsKey('error')) {
            expect(body['error']['code'], isNotEmpty);
            expect(body['error']['message']['ar'], isNotEmpty);
            expect(body['error']['message']['en'], isNotEmpty);
          }
        }
      }
    }
  });
}
