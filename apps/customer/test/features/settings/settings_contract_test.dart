import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/settings/data/mock/mock_settings_repository.dart';
import 'package:tam_customer/features/settings/data/mock/settings_fixtures.dart';
import 'package:tam_customer/features/settings/data/settings_wire_mapper.dart';

Map<String, dynamic> example(String name) =>
    jsonDecode(
          File(
            '../../docs/api/settings/examples/$name.json',
          ).readAsStringSync(),
        )
        as Map<String, dynamic>;

Iterable<Map<String, dynamic>> requests(List<dynamic> items) sync* {
  for (final value in items.cast<Map<String, dynamic>>()) {
    if (value.containsKey('item')) {
      yield* requests(value['item'] as List<dynamic>);
    } else {
      yield value;
    }
  }
}

void main() {
  test('backend GET examples match source fixtures and strict parsing', () {
    final profile =
        example('profile-get-success')['data'] as Map<String, dynamic>;
    final preferences =
        example('preferences-get-success')['data'] as Map<String, dynamic>;
    expect(profile, SettingsFixtures.profile);
    expect(preferences, SettingsFixtures.preferences);
    expect(
      SettingsWireMapper.profileJson(SettingsWireMapper.profile(profile)),
      profile,
    );
    expect(
      SettingsWireMapper.preferencesJson(
        SettingsWireMapper.preferences(preferences),
      ),
      preferences,
    );
  });

  test('PATCH examples produce the same canonical values in mock', () async {
    final repository = MockSettingsRepository();
    final name = example('profile-patch-request')['display_name'] as String;
    final profile = await repository.updateDisplayName(name);
    final preferences = await repository.updatePreferences(
      SettingsWireMapper.preferences(example('preferences-patch-request')),
    );
    expect(
      SettingsWireMapper.profileJson(profile),
      example('profile-patch-success')['data'],
    );
    expect(
      SettingsWireMapper.preferencesJson(preferences),
      example('preferences-patch-success')['data'],
    );
  });

  test(
    'every Postman operation has parseable success and specified errors',
    () {
      final collection =
          jsonDecode(
                File(
                  '../../docs/api/settings/settings-v1.postman_collection.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      final operations = requests(collection['item'] as List<dynamic>).toList();
      expect(operations, hasLength(4));
      for (final item in operations) {
        final request = item['request'] as Map<String, dynamic>;
        final path = (request['url'] as Map<String, dynamic>)['raw'] as String;
        final responses = (item['response'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
        expect(
          responses.map((r) => r['code']),
          containsAll([200, 401, 403, 500, 503]),
        );
        if (request['method'] == 'PATCH') {
          expect(responses.map((r) => r['code']), contains(422));
        }
        for (final response in responses) {
          final payload =
              jsonDecode(response['body'] as String) as Map<String, dynamic>;
          if (response['code'] == 200) {
            final data = payload['data'] as Map<String, dynamic>;
            if (path.endsWith('/profile')) {
              SettingsWireMapper.profile(data);
            } else {
              SettingsWireMapper.preferences(data);
            }
          } else {
            final error = payload['error'] as Map<String, dynamic>;
            final message = error['message'] as Map<String, dynamic>;
            expect(error['code'], isNotEmpty);
            expect(message['ar'], isNotEmpty);
            expect(message['en'], isNotEmpty);
            if (response['code'] == 422 && path.endsWith('/preferences')) {
              expect(payload, example('preferences-validation-error'));
            }
          }
        }
      }
    },
  );
}
