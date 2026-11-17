import 'dart:typed_data';

import 'package:tam_customer/features/settings/data/mock/settings_fixtures.dart';
import 'package:tam_customer/features/settings/data/settings_wire_mapper.dart';
import 'package:tam_customer/features/settings/domain/settings_models.dart';
import 'package:tam_customer/features/settings/domain/settings_repository.dart';

/// Per-app in-memory mock; no phone, tokens, backend writes or persistence.
final class MockSettingsRepository implements SettingsRepository {
  MockSettingsRepository({
    Map<String, Object?> initialProfile = SettingsFixtures.profile,
    Map<String, Object?> initialPreferences = SettingsFixtures.preferences,
  }) : _profile = SettingsWireMapper.profile(initialProfile),
       _preferences = SettingsWireMapper.preferences(initialPreferences);

  SettingsProfile _profile;
  SettingsPreferences _preferences;

  bool failNextProfileLoad = false;
  bool failNextPreferencesLoad = false;
  bool failNextProfileSave = false;
  bool failNextPreferencesSave = false;

  @override
  Future<SettingsProfile> loadProfile() async {
    if (failNextProfileLoad) {
      failNextProfileLoad = false;
      throw const SettingsFailure(SettingsFailureCode.serviceUnavailable);
    }
    return _profile;
  }

  @override
  Future<SettingsPreferences> loadPreferences() async {
    if (failNextPreferencesLoad) {
      failNextPreferencesLoad = false;
      throw const SettingsFailure(SettingsFailureCode.serviceUnavailable);
    }
    return _preferences;
  }

  @override
  Future<SettingsProfile> updateDisplayName(
    String name, {
    Uint8List? avatarBytes,
  }) async {
    if (!SettingsNameRules.isValid(name) ||
        (avatarBytes != null &&
            (avatarBytes.isEmpty || avatarBytes.length > 5 * 1024 * 1024))) {
      throw const SettingsFailure(SettingsFailureCode.validationError);
    }
    if (failNextProfileSave) {
      failNextProfileSave = false;
      throw const SettingsFailure(SettingsFailureCode.saveFailed);
    }
    _profile = _profile.copyWith(
      displayName: SettingsNameRules.normalize(name),
      avatarBytes: avatarBytes == null
          ? null
          : Uint8List.fromList(avatarBytes).asUnmodifiableView(),
    );
    return _profile;
  }

  @override
  Future<SettingsPreferences> updatePreferences(
    SettingsPreferences preferences,
  ) async {
    if (failNextPreferencesSave) {
      failNextPreferencesSave = false;
      throw const SettingsFailure(SettingsFailureCode.saveFailed);
    }
    _preferences = preferences.copyWith();
    return _preferences;
  }
}
