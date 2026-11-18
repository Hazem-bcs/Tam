import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:tam_customer/app/preferences/app_preferences_cubit.dart';

/// Router-compatible view of the persisted, device-local language preference.
final class AppLocaleController extends ValueNotifier<Locale> {
  AppLocaleController([
    Locale initial = const Locale('ar'),
    AppPreferencesCubit? preferences,
  ]) : _preferences = preferences,
       super(initial) {
    _validate(initial);
    if (preferences != null) {
      value = Locale(preferences.state.preferences.languageCode);
      _changes = preferences.stream.listen((state) {
        value = Locale(state.preferences.languageCode);
      });
    }
  }

  final AppPreferencesCubit? _preferences;
  StreamSubscription<AppPreferencesState>? _changes;

  AppPreferencesCubit? get preferences => _preferences;

  Future<bool> setLocale(Locale locale) {
    _validate(locale);
    if (_preferences != null) {
      return _preferences.setLanguage(locale.languageCode);
    }
    value = locale;
    return Future.value(true);
  }

  static void _validate(Locale locale) {
    if (!const ['ar', 'en'].contains(locale.languageCode)) {
      throw ArgumentError.value(locale, 'locale', 'Supported locales: ar, en');
    }
  }

  @override
  void dispose() {
    unawaited(_changes?.cancel());
    super.dispose();
  }
}
