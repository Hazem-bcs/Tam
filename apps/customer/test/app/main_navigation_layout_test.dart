import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/shell/main_navigation_bar.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

void main() {
  for (final config in [
    (size: const Size(320, 750), locale: 'ar', scale: 2.0),
    (size: const Size(390, 844), locale: 'ar', scale: 1.0),
    (size: const Size(390, 844), locale: 'en', scale: 1.0),
    (size: const Size(800, 1000), locale: 'ar', scale: 1.0),
    (size: const Size(840, 390), locale: 'en', scale: 2.0),
  ]) {
    testWidgets('dock ${config.size} ${config.locale} x${config.scale}', (
      tester,
    ) async {
      tester.view.physicalSize = config.size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = config.scale;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final selections = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          locale: Locale(config.locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: const TextField(),
            bottomNavigationBar: MainNavigationBar(
              selectedIndex: 1,
              onSelected: selections.add,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final rects = [
        for (var i = 0; i < 3; i++)
          tester.getRect(find.byKey(ValueKey('main-tab-$i'))),
      ];
      for (final rect in rects) {
        expect(rect.height, greaterThanOrEqualTo(48));
        expect(rect.width, greaterThanOrEqualTo(48));
      }
      expect(rects[0].width, closeTo(rects[1].width, 1));
      expect(rects[1].width, closeTo(rects[2].width, 1));
      expect(rects[0].top, rects[1].top);
      expect(rects[0].height, rects[1].height);
      expect(
        config.locale == 'ar'
            ? rects[0].left > rects[2].left
            : rects[0].left < rects[2].left,
        isTrue,
      );
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byKey(ValueKey('main-tab-$i')));
      }
      expect(selections, [0, 1, 2]);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
