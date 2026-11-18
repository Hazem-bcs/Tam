import 'dart:convert';

import 'package:tam_customer/app/preferences/app_preferences.dart';
import 'package:tam_customer/core/cache/local_cache_store.dart';

/// Versioned device settings; unrelated cached/account data is never cleared.
final class CachedAppPreferencesRepository implements AppPreferencesRepository {
  CachedAppPreferencesRepository(this._store);

  static const storageKey = 'app.preferences';
  final LocalCacheStore _store;
  Map<String, Object?> _stored = {};

  @override
  Future<AppPreferences> load() async {
    final cached = await _store.read(storageKey);
    if (cached == null) return const AppPreferences();
    try {
      final decoded = jsonDecode(cached.value);
      if (decoded is! Map<String, dynamic>) return const AppPreferences();
      _stored = decoded;
    } on FormatException {
      return const AppPreferences();
    }
    // v1 used locale/themeMode/textScale. Valid values survive migration; each
    // malformed/missing field defaults independently, preserving other choices.
    final language = _stored['languageCode'] ?? _stored['locale'];
    final appearance = _stored['appearance'] ?? _stored['themeMode'];
    final font = _stored['fontSize'];
    final legacyScale = _stored['textScale'];
    return AppPreferences(
      languageCode: language == 'en' ? 'en' : 'ar',
      appearance: AppAppearance.values.firstWhere(
        (value) => value.name == appearance,
        orElse: () => AppAppearance.system,
      ),
      fontSize: AppFontSize.values.firstWhere(
        (value) =>
            value.name == font || (font == null && value.factor == legacyScale),
        orElse: () => AppFontSize.standard,
      ),
    );
  }

  @override
  Future<void> save(AppPreferences preferences) async {
    final updated = <String, Object?>{
      ..._stored,
      'version': 2,
      'languageCode': preferences.languageCode,
      'appearance': preferences.appearance.name,
      'fontSize': preferences.fontSize.name,
    };
    await _store.write(storageKey, jsonEncode(updated), DateTime.now().toUtc());
    _stored = updated;
  }
}
