import 'package:tam_customer/features/settings/domain/settings_models.dart';

/// Transport parsing shared by deterministic mock fixtures and future HTTP.
abstract final class SettingsWireMapper {
  static SettingsProfile profile(Map<String, Object?> json) {
    final name = json['display_name'];
    final avatar = json['avatar_url'];
    if (name is! String ||
        !SettingsNameRules.isValid(name) ||
        (avatar != null && avatar is! String)) {
      throw const FormatException('Invalid settings profile');
    }
    return SettingsProfile(
      displayName: SettingsNameRules.normalize(name),
      avatarUrl: avatar as String?,
    );
  }

  static SettingsPreferences preferences(Map<String, Object?> json) {
    final enabled = json['account_notifications_enabled'];
    if (enabled is! bool) {
      throw const FormatException('Invalid settings preferences');
    }
    return SettingsPreferences(accountNotificationsEnabled: enabled);
  }

  static Map<String, Object?> profileJson(SettingsProfile profile) => {
    'display_name': profile.displayName,
    'avatar_url': profile.avatarUrl,
  };

  static Map<String, Object?> preferencesJson(SettingsPreferences prefs) => {
    'account_notifications_enabled': prefs.accountNotificationsEnabled,
  };
}
