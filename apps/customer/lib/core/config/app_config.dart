abstract final class AppConfig {
  /// Use --dart-define=API_BASE_URL=https://your-service.example/v1.
  /// Never put privileged server credentials in a mobile binary.
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
}
