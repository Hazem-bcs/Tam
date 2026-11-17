import 'dart:typed_data';

import 'package:tam_customer/features/settings/domain/settings_models.dart';

/// Settings profile is not an AuthUser and must never mutate Auth sessions.
abstract interface class SettingsRepository {
  Future<SettingsProfile> loadProfile();
  Future<SettingsPreferences> loadPreferences();
  Future<SettingsProfile> updateDisplayName(
    String name, {
    Uint8List? avatarBytes,
  });
  Future<SettingsPreferences> updatePreferences(
    SettingsPreferences preferences,
  );
}
