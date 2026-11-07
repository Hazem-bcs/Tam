import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/home/data/mock/mock_home_repository.dart';
import 'package:tam_customer/features/home/presentation/pages/home_page.dart';

import 'home_test_support.dart';

const capture = bool.fromEnvironment('CAPTURE_HOME_GOLDENS');

Future<ByteData> _loadFont(String path) async =>
    ByteData.sublistView(await File(path).readAsBytes());

ThemeData _captureTheme() {
  final base = AppTheme.light;
  final scheme = base.colorScheme;
  return base.copyWith(
    textTheme: base.textTheme.apply(fontFamily: 'GoldenReadable'),
    textButtonTheme: TextButtonThemeData(
      style: base.textButtonTheme.style?.copyWith(
        textStyle: WidgetStatePropertyAll(
          base.textTheme.labelLarge?.copyWith(fontFamily: 'GoldenReadable'),
        ),
      ),
    ),
    navigationBarTheme: base.navigationBarTheme.copyWith(
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => base.textTheme.labelMedium?.copyWith(
          fontFamily: 'GoldenReadable',
          color: states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    if (!capture) return;
    // Fonts used for *local screenshots only*, not bundled/distributed.
    final font = FontLoader('GoldenReadable')
      ..addFont(
        _loadFont('/usr/share/fonts/truetype/noto/NotoSansArabic-Regular.ttf'),
      );
    final icons = FontLoader('MaterialIcons')
      ..addFont(
        _loadFont(
          '/home/hazem/development/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
        ),
      );
    await Future.wait([font.load(), icons.load()]);
  });

  for (final config in [
    (width: 320.0, locale: 'ar', scale: 2.0),
    (width: 390.0, locale: 'ar', scale: 1.0),
    (width: 390.0, locale: 'en', scale: 1.0),
    (width: 800.0, locale: 'ar', scale: 1.0),
  ]) {
    testWidgets(
      'visual layout ${config.width.toInt()} ${config.locale} x${config.scale}',
      (tester) async {
        tester.view.physicalSize = Size(config.width, 900);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = config.scale;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pumpHome(
          tester,
          repository: const MockHomeRepository(latency: Duration.zero),
          navigation: RecordingHomeNavigation(),
          language: config.locale,
          renderTheme: capture ? _captureTheme() : null,
        );
        expect(tester.takeException(), isNull);
        if (capture) {
          await expectLater(
            find.byType(HomePage),
            matchesGoldenFile(
              'goldens/home-${config.locale}-${config.width.toInt()}-x${config.scale.toInt()}.png',
            ),
          );
        }
      },
    );
  }
}
