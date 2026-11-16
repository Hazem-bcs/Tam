import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rive/rive.dart' as rive;
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_rive_mascot.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

void main() {
  const layouts = [
    (size: Size(390, 844), scale: 1.0, keyboard: 0.0),
    (size: Size(411, 914), scale: 1.0, keyboard: 300.0),
    (size: Size(320, 600), scale: 1.0, keyboard: 0.0),
    (size: Size(390, 844), scale: 2.0, keyboard: 280.0),
    (size: Size(800, 980), scale: 1.0, keyboard: 0.0),
    (size: Size(800, 360), scale: 2.0, keyboard: 180.0),
  ];
  for (final locale in ['ar', 'en']) {
    for (var index = 0; index < layouts.length; index++) {
      final layout = layouts[index];
      testWidgets('both gloves clear the card / $locale / layout $index', (
        tester,
      ) async {
        tester.view.physicalSize = layout.size;
        tester.view.devicePixelRatio = 1;
        tester.view.viewInsets = FakeViewPadding(bottom: layout.keyboard);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        Offset? previousPosition;
        for (final sad in [true, false]) {
          await tester.runAsync(() async {
            await tester.pumpWidget(
              MaterialApp(
                theme: AppTheme.light,
                locale: Locale(locale),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Builder(
                  builder: (context) => MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      disableAnimations: true,
                      textScaler: TextScaler.linear(layout.scale),
                    ),
                    child: RepaintBoundary(
                      key: const Key('clearance-screen'),
                      child: AuthScaffold(
                        title: AppLocalizations.of(context).authWelcome,
                        description: AppLocalizations.of(
                          context,
                        ).authPhoneDescription,
                        hasError: sad,
                        success: !sad,
                        child: const TextField(),
                      ),
                    ),
                  ),
                ),
              ),
            );
            final builder = tester.widget<rive.RiveWidgetBuilder>(
              find.byType(rive.RiveWidgetBuilder),
            );
            await builder.fileLoader.file().timeout(
              const Duration(seconds: 10),
            );
          });
          await tester.pump();
          await tester.pump();
          final mascot = find.byType(AuthRiveMascot);
          final origin = tester.getTopLeft(mascot);
          if (previousPosition != null) expect(origin, previousPosition);
          previousPosition = origin;
          final cardTop = tester
              .getTopLeft(find.byKey(const Key('auth-form-surface')))
              .dy;
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find
                .ancestor(of: mascot, matching: find.byType(RepaintBoundary))
                .first,
          );
          await tester.runAsync(() async {
            final image = await boundary.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.rawRgba,
            );
            final pixels = bytes!.buffer.asUint8List();
            for (final right in [false, true]) {
              var lowest = -1;
              var glovePixels = 0;
              // Isolate the neutral glove pixels outside the warm face/body.
              // This measures actual exported art, not the widget rectangle.
              for (var y = image.height ~/ 2; y < image.height; y++) {
                for (var x = 0; x < image.width; x++) {
                  if (right ? x < image.width * .69 : x > image.width * .31) {
                    continue;
                  }
                  final offset = (y * image.width + x) * 4;
                  final r = pixels[offset];
                  final g = pixels[offset + 1];
                  final b = pixels[offset + 2];
                  if (pixels[offset + 3] > 200 &&
                      r > 160 &&
                      g > 160 &&
                      b > 160 &&
                      (r - g).abs() < 25 &&
                      (g - b).abs() < 25) {
                    glovePixels++;
                    lowest = y;
                  }
                }
              }
              expect(
                glovePixels,
                greaterThan(20),
                reason: 'Both complete gloves must be present',
              );
              expect(
                cardTop - (origin.dy + lowest + 1),
                greaterThanOrEqualTo(6),
                reason:
                    '${sad ? 'Sad' : 'Happy'} ${right ? 'right' : 'left'} fingertips need breathing space',
              );
            }
            image.dispose();
            final output = Platform.environment['TAM_MASCOT_QA_DIR'];
            if (output != null) {
              final screen = tester.renderObject<RenderRepaintBoundary>(
                find.byKey(const Key('clearance-screen')),
              );
              final snapshot = await screen.toImage();
              final png = await snapshot.toByteData(
                format: ui.ImageByteFormat.png,
              );
              await Directory(output).create(recursive: true);
              await File(
                '$output/$locale-$index-${sad ? 'sad' : 'happy'}.png',
              ).writeAsBytes(png!.buffer.asUint8List());
              snapshot.dispose();
            }
          });
          expect(tester.takeException(), isNull);
        }
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}
