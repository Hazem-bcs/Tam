import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/settings/data/api/unavailable_settings_repository.dart';
import 'package:tam_customer/features/settings/data/mock/mock_settings_repository.dart';
import 'package:tam_customer/features/settings/data/settings_wire_mapper.dart';
import 'package:tam_customer/features/settings/domain/settings_models.dart';

void main() {
  group('SettingsNameRules', () {
    test('normalizes whitespace and rejects invalid boundaries', () {
      expect(SettingsNameRules.normalize('  أحمد    محمد  '), 'أحمد محمد');
      expect(SettingsNameRules.isValid(' أ '), false);
      expect(SettingsNameRules.isValid('AB'), true);
      expect(SettingsNameRules.isValid('a' * 60), true);
      expect(SettingsNameRules.isValid('a' * 61), false);
      expect(SettingsNameRules.isValid('a\nB'), true); // normalized spaces
      expect(SettingsNameRules.isValid('a\u0000b'), false);
    });
  });

  group('mock repository', () {
    test('parses contract fixtures and isolates auth identity', () async {
      final repository = MockSettingsRepository();
      final profile = await repository.loadProfile();
      final preferences = await repository.loadPreferences();
      expect(profile.displayName, 'مستخدم تم');
      expect(profile.avatarUrl, isNull);
      expect(preferences.accountNotificationsEnabled, true);
      expect(SettingsWireMapper.profileJson(profile), {
        'display_name': 'مستخدم تم',
        'avatar_url': null,
      });
      expect(SettingsWireMapper.preferencesJson(preferences), {
        'account_notifications_enabled': true,
      });
    });

    test('saves validated name without changing preferences', () async {
      final repository = MockSettingsRepository();
      final result = await repository.updateDisplayName('  Sara   Ali ');
      expect(result.displayName, 'Sara Ali');
      expect((await repository.loadProfile()).displayName, 'Sara Ali');
      expect(
        (await repository.loadPreferences()).accountNotificationsEnabled,
        true,
      );
    });

    test('invalid update never mutates saved profile', () async {
      final repository = MockSettingsRepository();
      await expectLater(
        repository.updateDisplayName('x'),
        throwsA(
          isA<SettingsFailure>().having(
            (e) => e.code,
            'code',
            SettingsFailureCode.validationError,
          ),
        ),
      );
      expect((await repository.loadProfile()).displayName, 'مستخدم تم');
    });

    test(
      'failed name and notification saves are atomic and retryable',
      () async {
        final repository = MockSettingsRepository()
          ..failNextProfileSave = true
          ..failNextPreferencesSave = true;
        await expectLater(
          repository.updateDisplayName('New Name'),
          throwsA(isA<SettingsFailure>()),
        );
        await expectLater(
          repository.updatePreferences(
            const SettingsPreferences(accountNotificationsEnabled: false),
          ),
          throwsA(isA<SettingsFailure>()),
        );
        expect((await repository.loadProfile()).displayName, 'مستخدم تم');
        expect(
          (await repository.loadPreferences()).accountNotificationsEnabled,
          true,
        );
        expect(
          (await repository.updateDisplayName('New Name')).displayName,
          'New Name',
        );
        expect(
          (await repository.updatePreferences(
            const SettingsPreferences(accountNotificationsEnabled: false),
          )).accountNotificationsEnabled,
          false,
        );
      },
    );

    test('load failure can be retried without implicit fallback', () async {
      final repository = MockSettingsRepository()..failNextProfileLoad = true;
      await expectLater(
        repository.loadProfile(),
        throwsA(isA<SettingsFailure>()),
      );
      expect((await repository.loadProfile()).displayName, 'مستخدم تم');
    });

    test('required nullable avatar must be present in profile payload', () {
      expect(
        () => SettingsWireMapper.profile({'display_name': 'Valid Name'}),
        throwsFormatException,
      );
      expect(
        SettingsWireMapper.profile({
          'display_name': 'Valid Name',
          'avatar_url': null,
        }).avatarUrl,
        isNull,
      );
    });

    test('invalid wire payload rejects unexpected types', () {
      expect(
        () => SettingsWireMapper.profile({'display_name': 15}),
        throwsFormatException,
      );
      expect(
        () => SettingsWireMapper.preferences({
          'account_notifications_enabled': 'true',
        }),
        throwsFormatException,
      );
    });
  });

  test('API mode returns explicit SERVICE_UNAVAILABLE without mock', () async {
    const repository = UnavailableSettingsRepository();
    await expectLater(
      repository.loadProfile(),
      throwsA(
        isA<SettingsFailure>().having(
          (e) => e.code,
          'code',
          SettingsFailureCode.serviceUnavailable,
        ),
      ),
    );
    await expectLater(
      repository.updateDisplayName('Some Name'),
      throwsA(isA<SettingsFailure>()),
    );
  });
}
