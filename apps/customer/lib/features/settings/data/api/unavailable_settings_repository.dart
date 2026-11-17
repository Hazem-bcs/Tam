import 'dart:typed_data';

import 'package:tam_customer/features/settings/domain/settings_models.dart';
import 'package:tam_customer/features/settings/domain/settings_repository.dart';

/// API mode fails honestly until authenticated HTTP wiring is approved.
final class UnavailableSettingsRepository implements SettingsRepository {
  const UnavailableSettingsRepository();

  Never _unavailable() =>
      throw const SettingsFailure(SettingsFailureCode.serviceUnavailable);

  @override
  Future<SettingsProfile> loadProfile() async => _unavailable();

  @override
  Future<SettingsPreferences> loadPreferences() async => _unavailable();

  @override
  Future<SettingsProfile> updateDisplayName(
    String name, {
    Uint8List? avatarBytes,
  }) async => _unavailable();

  @override
  Future<SettingsPreferences> updatePreferences(
    SettingsPreferences preferences,
  ) async => _unavailable();
}
