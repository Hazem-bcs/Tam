import 'package:flutter/widgets.dart';

/// Local app preference; no backend account is required to change language.
final class AppLocaleController extends ValueNotifier<Locale> {
  AppLocaleController([Locale initial = const Locale('ar')]) : super(initial) {
    _validate(initial);
  }
  void setLocale(Locale locale) {
    _validate(locale);
    value = locale;
  }

  static void _validate(Locale locale) {
    if (!const ['ar', 'en'].contains(locale.languageCode)) {
      throw ArgumentError.value(locale, 'locale', 'Supported locales: ar, en');
    }
  }
}
