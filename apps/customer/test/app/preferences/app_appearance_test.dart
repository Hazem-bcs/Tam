import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/app.dart';
import 'package:tam_customer/app/preferences/app_preferences.dart';
import 'package:tam_customer/app/preferences/app_preferences_cubit.dart';
import 'package:tam_customer/app/preferences/app_text_scaler.dart';
import 'package:tam_customer/app/theme/app_colors.dart';
import 'package:tam_customer/app/theme/app_map_colors.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/auth/data/memory_auth_session_store.dart';
import 'package:tam_customer/features/settings/presentation/widgets/settings_appearance_preferences.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

import '../../support/fake_auth_repository.dart';

final class NonlinearScaler extends TextScaler {
  const NonlinearScaler();
  @override
  double scale(double fontSize) => fontSize < 20 ? fontSize * 3 : fontSize * 2;
  @override
  double get textScaleFactor => 3;
}

double contrast(Color a, Color b) {
  final x = a.computeLuminance();
  final y = b.computeLuminance();
  return ((x > y ? x : y) + .05) / ((x < y ? x : y) + .05);
}

void main() {
  setUpAll(() async {
    if (!const bool.fromEnvironment('CAPTURE_PREFERENCES')) return;
    for (final (file, family) in [
      ('NotoSansArabic-Regular.ttf', 'TamSansArabic'),
      ('NotoSansArabic-Bold.ttf', 'TamSansArabic'),
      ('NotoSans-Regular.ttf', 'TamSansLatin'),
      ('NotoSans-Bold.ttf', 'TamSansLatin'),
    ]) {
      await ui.loadFontFromList(
        await File('assets/fonts/$file').readAsBytes(),
        fontFamily: family,
      );
    }
    var directory = File(Platform.resolvedExecutable).absolute.parent;
    while (true) {
      final icons = File(
        '${directory.path}/artifacts/material_fonts/MaterialIcons-Regular.otf',
      );
      if (icons.existsSync()) {
        await ui.loadFontFromList(
          await icons.readAsBytes(),
          fontFamily: 'MaterialIcons',
        );
        break;
      }
      if (directory.path == directory.parent.path) {
        throw StateError('Missing MaterialIcons font');
      }
      directory = directory.parent;
    }
  });
  test(
    'app size composes with nonlinear device accessibility scaler uncapped',
    () {
      const scaler = AppTextScaler(NonlinearScaler(), 1.3);
      expect(scaler.scale(16), closeTo(62.4, .001));
      expect(scaler.scale(24), closeTo(62.4, .001));
    },
  );

  test(
    'all theme entry points preserve dark semantic foregrounds and maps',
    () {
      for (final theme in [
        AppTheme.dark,
        AppTheme.home(AppTheme.dark),
        AppTheme.account(AppTheme.dark),
        AppTheme.auth(AppTheme.dark),
        AppTheme.rideJourney(AppTheme.dark),
        AppTheme.activity(AppTheme.dark),
      ]) {
        final colors = theme.colorScheme;
        expect(theme.brightness, Brightness.dark);
        for (final (foreground, background) in [
          (colors.onSurface, colors.surface),
          (colors.onSurfaceVariant, colors.surfaceContainerLowest),
          (colors.onPrimary, colors.primary),
          (colors.onPrimaryContainer, colors.primaryContainer),
          (colors.onError, colors.error),
          (colors.onErrorContainer, colors.errorContainer),
        ]) {
          expect(contrast(foreground, background), greaterThanOrEqualTo(4.5));
        }
        expect(theme.extension<AppMapColors>(), AppColors.mapDark);
        final status = theme.extension<AppStatusColors>()!;
        expect(
          contrast(status.onSuccess, status.success),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrast(status.onWarningContainer, status.warningContainer),
          greaterThanOrEqualTo(4.5),
        );
      }
    },
  );

  testWidgets(
    'system appearance follows device changes; explicit light overrides',
    (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await tester.pumpWidget(
        TamApp(
          authRepository: FakeAuthRepository(latency: Duration.zero),
          sessionStore: MemoryAuthSessionStore(),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(MaterialApp));
      final preferences = context.read<AppPreferencesCubit>();
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
        const Locale('ar'),
      );
      final scaffold = tester.element(find.byType(Scaffold).first);
      expect(Theme.of(scaffold).brightness, Brightness.light);
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pumpAndSettle();
      expect(Theme.of(scaffold).brightness, Brightness.dark);
      await preferences.setAppearance(AppAppearance.light);
      await tester.pumpAndSettle();
      expect(Theme.of(scaffold).brightness, Brightness.light);
    },
  );

  for (final (locale, size, brightness, textScale) in [
    ('ar', const Size(320, 700), Brightness.dark, 2.0),
    ('en', const Size(800, 900), Brightness.light, 1.0),
  ]) {
    testWidgets(
      'appearance choices and font sheet fit $locale/$size/$textScale',
      (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final controller = AppPreferencesCubit();
        addTearDown(controller.close);
        final capture = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.account(
              brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
            ),
            locale: Locale(locale),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
            home: RepaintBoundary(
              key: capture,
              child: Scaffold(
                body: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: SingleChildScrollView(
                        child: SettingsAppearancePreferences(
                          controller: controller,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (const bool.fromEnvironment('CAPTURE_PREFERENCES')) {
          await tester.runAsync(() async {
            final boundary =
                capture.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final image = await boundary.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final directory = Directory(
              '../../docs/engineering/deliveries/CF-THEME/evidence',
            )..createSync(recursive: true);
            File(
              '${directory.path}/preferences-$locale.png',
            ).writeAsBytesSync(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        await tester.tap(find.byKey(const Key('settings-font-size')));
        await tester.pumpAndSettle();
        final choice = find.byKey(
          const ValueKey('settings-option-AppFontSize.extraLarge'),
        );
        await tester.ensureVisible(choice);
        await tester.tap(choice);
        await tester.pumpAndSettle();
        expect(controller.state.preferences.fontSize, AppFontSize.extraLarge);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
