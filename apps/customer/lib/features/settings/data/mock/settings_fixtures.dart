/// Artificial, account-independent fixtures; not credentials or Auth users.
/// Matches docs/api/settings/examples/* success payloads.
abstract final class SettingsFixtures {
  static const profile = <String, Object?>{
    'display_name': 'مستخدم تم',
    'avatar_url': null,
  };
  static const preferences = <String, Object?>{
    'account_notifications_enabled': true,
  };
}
