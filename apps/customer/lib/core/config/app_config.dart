abstract final class AppConfig {
  /// Use --dart-define=API_BASE_URL=https://your-service.example/v1.
  /// Never put privileged server credentials in a mobile binary.
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Temporary local phone entry until the Auth API is connected.
  /// This opens the app without creating an authenticated backend session.
  static const temporaryPhoneEntryEnabled = bool.fromEnvironment(
    'TEMPORARY_PHONE_ENTRY',
    defaultValue: true,
  );
}
