import 'dart:typed_data';

/// Profile data is independent of Auth identity and its verified phone.
final class SettingsProfile {
  const SettingsProfile({
    required this.displayName,
    this.avatarUrl,
    this.avatarBytes,
  });

  final String displayName;
  final String? avatarUrl;

  /// Session-local image; never serialized as backend identity.
  final Uint8List? avatarBytes;

  SettingsProfile copyWith({
    String? displayName,
    String? avatarUrl,
    Uint8List? avatarBytes,
  }) => SettingsProfile(
    displayName: displayName ?? this.displayName,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    avatarBytes: avatarBytes ?? this.avatarBytes,
  );
}

final class SettingsPreferences {
  const SettingsPreferences({required this.accountNotificationsEnabled});

  final bool accountNotificationsEnabled;

  SettingsPreferences copyWith({bool? accountNotificationsEnabled}) =>
      SettingsPreferences(
        accountNotificationsEnabled:
            accountNotificationsEnabled ?? this.accountNotificationsEnabled,
      );
}

enum SettingsFailureCode { validationError, serviceUnavailable, saveFailed }

final class SettingsFailure implements Exception {
  const SettingsFailure(this.code);
  final SettingsFailureCode code;
}

/// The same validation must be enforced by the eventual server.
abstract final class SettingsNameRules {
  static const minLength = 2;
  static const maxLength = 60;

  static String normalize(String raw) =>
      raw.trim().replaceAll(RegExp(r'\s+'), ' ');

  static bool isValid(String raw) {
    final value = normalize(raw);
    return value.runes.length >= minLength &&
        value.runes.length <= maxLength &&
        !RegExp(r'[\x00-\x1F\x7F]').hasMatch(value);
  }
}
