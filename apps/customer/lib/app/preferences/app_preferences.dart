/// Device-local preferences, independent of authentication and server settings.
enum AppAppearance { system, light, dark }

enum AppFontSize {
  small(0.9),
  standard(1),
  large(1.15),
  extraLarge(1.3);

  const AppFontSize(this.factor);
  final double factor;
}

final class AppPreferences {
  const AppPreferences({
    this.languageCode = 'ar',
    this.appearance = AppAppearance.system,
    this.fontSize = AppFontSize.standard,
  });

  final String languageCode;
  final AppAppearance appearance;
  final AppFontSize fontSize;

  AppPreferences copyWith({
    String? languageCode,
    AppAppearance? appearance,
    AppFontSize? fontSize,
  }) => AppPreferences(
    languageCode: languageCode ?? this.languageCode,
    appearance: appearance ?? this.appearance,
    fontSize: fontSize ?? this.fontSize,
  );
}

abstract interface class AppPreferencesRepository {
  Future<AppPreferences> load();
  Future<void> save(AppPreferences preferences);
}
