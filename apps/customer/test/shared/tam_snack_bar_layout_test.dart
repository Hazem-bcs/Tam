import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_snack_bar.dart';

import '../support/preview_fonts.dart';

void main() {
  const preview = bool.fromEnvironment('SNACKBAR_PREVIEW');
  setUpAll(() async {
    await loadPreviewFonts(enabled: true);
  });
  for (final variant in [
    ('arabic-phone', const Size(390, 844), 'ar', 1.0, 0.0, false),
    ('english-small-keyboard', const Size(320, 780), 'en', 2.0, 260.0, true),
    ('arabic-tablet', const Size(800, 980), 'ar', 2.0, 0.0, true),
    ('english-landscape', const Size(800, 360), 'en', 1.0, 0.0, false),
  ]) {
    testWidgets('responsive notice ${variant.$1}', (tester) async {
      if (preview) debugDisableShadows = false;
      addTearDown(() => debugDisableShadows = true);
      tester.view.physicalSize = variant.$2;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final capture = GlobalKey();
      late BuildContext surface;
      await tester.pumpWidget(
        RepaintBoundary(
          key: capture,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: previewTheme(),
            locale: Locale(variant.$3),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(variant.$4),
                viewInsets: EdgeInsets.only(bottom: variant.$5),
              ),
              child: child!,
            ),
            home: Scaffold(
              appBar: AppBar(
                title: Text(
                  variant.$3 == 'ar' ? 'تفاصيل طلب الدعم' : 'Support request',
                ),
              ),
              body: Builder(
                builder: (context) {
                  surface = context;
                  return const SizedBox.expand();
                },
              ),
            ),
          ),
        ),
      );
      TamSnackBar.show(
        surface,
        message: variant.$3 == 'ar'
            ? 'تم إنشاء طلب الدعم بنجاح'
            : 'Your request was saved. You can follow its status here.',
        tone: TamSnackBarTone.success,
        action: variant.$6
            ? SnackBarAction(
                label: variant.$3 == 'ar' ? 'عرض التفاصيل' : 'View details',
                onPressed: () {},
              )
            : null,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);
      final rect = tester.getRect(
        find
            .descendant(
              of: find.byType(SnackBar),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(rect.width, lessThanOrEqualTo(560));
      expect(rect.bottom, lessThanOrEqualTo(variant.$2.height - variant.$5));
      expect(rect.top, greaterThanOrEqualTo(0));
      if (preview) {
        await tester.runAsync(() async {
          final boundary =
              capture.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 2);
          try {
            final data = await image.toByteData(format: ui.ImageByteFormat.png);
            await Directory(
              '/tmp/tam-snackbar-previews',
            ).create(recursive: true);
            await File(
              '/tmp/tam-snackbar-previews/${variant.$1}.png',
            ).writeAsBytes(data!.buffer.asUint8List());
          } finally {
            image.dispose();
          }
        });
      }
      debugDisableShadows = true;
    });
  }
}
