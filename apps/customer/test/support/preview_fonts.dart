import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tam_customer/app/theme/app_theme.dart';

Future<void> loadPreviewFonts({required bool enabled}) async {
  if (!enabled) return;
  for (final font in {
    'TamPreviewArabic':
        '/usr/share/fonts/truetype/noto/NotoSansArabic-Regular.ttf',
    'TamPreviewLatin': '/usr/share/fonts/truetype/noto/NotoSans-Regular.ttf',
    'MaterialIcons':
        '/home/hazem/development/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  }.entries) {
    await (FontLoader(font.key)
          ..addFont(File(font.value).readAsBytes().then(ByteData.sublistView)))
        .load();
  }
}

ThemeData previewTheme() {
  final base = AppTheme.light;
  TextStyle? font(TextStyle? style) => style?.copyWith(
    fontFamily: 'TamPreviewArabic',
    fontFamilyFallback: const ['TamPreviewLatin'],
  );
  ButtonStyle? button(ButtonStyle? style) => style?.copyWith(
    textStyle: WidgetStatePropertyAll(font(base.textTheme.labelLarge)),
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: 'TamPreviewArabic',
      fontFamilyFallback: const ['TamPreviewLatin'],
    ),
    appBarTheme: base.appBarTheme.copyWith(
      titleTextStyle: font(base.appBarTheme.titleTextStyle),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      labelStyle: font(base.inputDecorationTheme.labelStyle),
      floatingLabelStyle: font(base.inputDecorationTheme.floatingLabelStyle),
      hintStyle: font(base.inputDecorationTheme.hintStyle),
      helperStyle: font(base.inputDecorationTheme.helperStyle),
      errorStyle: font(base.inputDecorationTheme.errorStyle),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: button(base.filledButtonTheme.style),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: button(base.outlinedButtonTheme.style),
    ),
    textButtonTheme: TextButtonThemeData(
      style: button(base.textButtonTheme.style),
    ),
  );
}
