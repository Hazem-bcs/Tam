import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tam_customer/app/theme/app_theme.dart';

Future<void> loadPreviewFonts({required bool enabled}) async {
  if (!enabled) return;
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  final fonts = <String, List<String>>{
    'TamPreviewArabic': [
      'assets/fonts/NotoSansArabic-Regular.ttf',
      '/usr/share/fonts/truetype/noto/NotoSansArabic-Regular.ttf',
    ],
    'TamPreviewLatin': [
      'assets/fonts/NotoSans-Regular.ttf',
      '/usr/share/fonts/truetype/noto/NotoSans-Regular.ttf',
    ],
    'MaterialIcons': [
      if (flutterRoot != null)
        '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
      '/home/hazem/development/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ],
  };
  for (final font in fonts.entries) {
    final candidates = font.value.where((path) => File(path).existsSync());
    if (candidates.isEmpty) {
      if (font.key == 'MaterialIcons') continue;
      throw StateError('Missing bundled preview font: ${font.key}');
    }
    final file = File(candidates.first);
    await (FontLoader(
      font.key,
    )..addFont(file.readAsBytes().then(ByteData.sublistView))).load();
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
    snackBarTheme: base.snackBarTheme.copyWith(
      contentTextStyle: font(
        base.snackBarTheme.contentTextStyle ?? base.textTheme.bodyMedium,
      ),
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
