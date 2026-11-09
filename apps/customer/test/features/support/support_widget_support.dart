import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import '../../support/preview_fonts.dart';

const captureSupportUi = bool.fromEnvironment('CAPTURE_SUPPORT_UI');
Future<void> loadSupportFonts() => loadPreviewFonts(enabled: captureSupportUi);
Future<void> pumpSupport(
  WidgetTester tester,
  Widget home, {
  String locale = 'ar',
  double scale = 1,
  bool settle = true,
}) async {
  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('support-preview'),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: captureSupportUi ? previewTheme() : AppTheme.light,
        locale: Locale(locale),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: home,
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

Future<void> captureSupport(WidgetTester tester, String name) async {
  if (captureSupportUi) {
    await expectLater(
      find.byKey(const Key('support-preview')),
      matchesGoldenFile(
        '../../../../../docs/engineering/deliveries/W2-SUPPORT/screenshots/$name.png',
      ),
    );
  }
}

Future<void> revealSupport(WidgetTester tester, String key) async {
  await tester.pumpAndSettle();
  final target = find.byKey(Key(key));
  await tester.scrollUntilVisible(
    target,
    160,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}
