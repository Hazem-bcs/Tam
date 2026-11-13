import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/home/data/mock/mock_home_repository.dart';
import 'package:tam_customer/features/home/presentation/pages/home_page.dart';

import 'home_test_support.dart';

const capture = bool.fromEnvironment('CAPTURE_HOME_GOLDENS');

void main() {
  setUpAll(() async {
    if (!capture) return;
    final font = FontLoader('TamSansArabic')
      ..addFont(rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/NotoSansArabic-Bold.ttf'));
    final latin = FontLoader('TamSansLatin')
      ..addFont(rootBundle.load('assets/fonts/NotoSans-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/NotoSans-Bold.ttf'));
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await Future.wait([font.load(), latin.load(), icons.load()]);
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
          authenticated: false,
          language: config.locale,
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
