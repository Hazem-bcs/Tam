import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/locale/app_locale_controller.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/settings/data/mock/mock_settings_repository.dart';
import 'package:tam_customer/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:tam_customer/features/settings/presentation/pages/settings_page.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/widgets/tam_text_field.dart';

final class FakeNavigation implements CustomerNavigation {
  int home = 0;
  int trips = 0;
  int notifications = 0;
  @override
  void openActiveTrip({String? id}) {}
  @override
  void openHome() => home++;
  @override
  void openRideRequest({TripPrefill? prefill}) {}
  @override
  void openTrips() => trips++;
  @override
  void openTrip(String id) {}
  @override
  void openNotifications() => notifications++;
  @override
  void openAddresses() {}
  @override
  void openSettings() {}
}

Widget testApp({
  required AppLocaleController locale,
  required FakeNavigation navigation,
  required MockSettingsRepository repository,
  Future<void> Function()? logout,
  String? phoneE164 = '+963912345678',
  double textScale = 1,
}) => ValueListenableBuilder<Locale>(
  valueListenable: locale,
  builder: (_, value, _) => MaterialApp(
    theme: const bool.fromEnvironment('CAPTURE_SETTINGS_GOLDENS')
        ? _previewTheme(value)
        : AppTheme.light,
    locale: value,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: BlocProvider(
          create: (_) => SettingsCubit(repository)..load(),
          child: SettingsPage(
            navigation: navigation,
            locale: locale,
            phoneE164: phoneE164,
            logout: logout ?? () async {},
          ),
        ),
      ),
    ),
  ),
);

ThemeData _previewTheme(Locale locale) {
  // Screenshot-only host font fallback; no change to the app's theme.
  final base = AppTheme.light;
  final font = locale.languageCode == 'ar' ? 'Noto Sans Arabic' : 'Roboto';
  final fallback = locale.languageCode == 'ar'
      ? <String>['Roboto']
      : <String>['Noto Sans Arabic'];
  TextStyle? previewStyle(TextStyle? style) =>
      style?.copyWith(fontFamily: font, fontFamilyFallback: fallback);
  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: font,
      fontFamilyFallback: fallback,
    ),
    appBarTheme: base.appBarTheme.copyWith(
      titleTextStyle: previewStyle(base.appBarTheme.titleTextStyle),
    ),
    navigationBarTheme: base.navigationBarTheme.copyWith(
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return previewStyle(base.textTheme.labelMedium)?.copyWith(
          color: states.contains(WidgetState.selected)
              ? base.colorScheme.primary
              : base.colorScheme.onSurfaceVariant,
        );
      }),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: base.outlinedButtonTheme.style?.copyWith(
        textStyle: WidgetStatePropertyAll(
          previewStyle(base.textTheme.labelLarge),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    if (const bool.fromEnvironment('CAPTURE_SETTINGS_GOLDENS')) {
      await ui.loadFontFromList(
        await File(
          '/usr/share/fonts/truetype/noto/NotoSansArabic-Regular.ttf',
        ).readAsBytes(),
        fontFamily: 'Noto Sans Arabic',
      );
      await ui.loadFontFromList(
        await File(
          '/home/hazem/development/flutter/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf',
        ).readAsBytes(),
        fontFamily: 'Roboto',
      );
      await ui.loadFontFromList(
        await File(
          '/home/hazem/development/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
        ).readAsBytes(),
        fontFamily: 'MaterialIcons',
      );
    }
  });

  testWidgets('Arabic profile and read-only injected phone', (tester) async {
    final locale = AppLocaleController();
    addTearDown(locale.dispose);
    final navigation = FakeNavigation();
    await tester.pumpWidget(
      testApp(
        locale: locale,
        navigation: navigation,
        repository: MockSettingsRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('حسابي'), findsOneWidget);
    expect(find.text('+963912345678'), findsOneWidget);
    expect(find.text('مستخدم تم'), findsOneWidget);
    expect(find.text('إشعارات الحساب'), findsOneWidget);
    expect(find.text('المحفظة'), findsNothing);
    expect(find.text('الوضع الداكن'), findsNothing);

    await tester.tap(find.byTooltip('فتح الإشعارات'));
    expect(navigation.notifications, 1);
  });

  testWidgets('language changes immediately without changing phone or route', (
    tester,
  ) async {
    final locale = AppLocaleController();
    addTearDown(locale.dispose);
    final navigation = FakeNavigation();
    await tester.pumpWidget(
      testApp(
        locale: locale,
        navigation: navigation,
        repository: MockSettingsRepository(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-language-tile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-locale-en')));
    await tester.pumpAndSettle();
    expect(locale.value.languageCode, 'en');
    expect(find.text('My account'), findsOneWidget);
    expect(find.text('+963912345678'), findsOneWidget);
    expect(navigation.home + navigation.trips, 0);
  });

  testWidgets('logout uses provided callback only after confirmation', (
    tester,
  ) async {
    final locale = AppLocaleController();
    addTearDown(locale.dispose);
    var calls = 0;
    await tester.pumpWidget(
      testApp(
        locale: locale,
        navigation: FakeNavigation(),
        repository: MockSettingsRepository(),
        logout: () async => calls++,
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('settings-content')),
      const Offset(0, -750),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.logout_outlined));
    await tester.pumpAndSettle();
    expect(calls, 0);
    await tester.tap(find.text('تسجيل الخروج').last);
    await tester.pumpAndSettle();
    expect(calls, 1);
  });

  testWidgets('unsaved name prompts on navigation and retains draft', (
    tester,
  ) async {
    final locale = AppLocaleController();
    addTearDown(locale.dispose);
    final navigation = FakeNavigation();
    await tester.pumpWidget(
      testApp(
        locale: locale,
        navigation: navigation,
        repository: MockSettingsRepository(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('تعديل الاسم'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('settings-name-field')),
      'New Display Name',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('فتح الإشعارات'));
    await tester.pumpAndSettle();
    expect(find.text('تغييرات غير محفوظة'), findsWidgets);
    expect(navigation.notifications, 0);
    await tester.tap(find.text('متابعة التعديل'));
    await tester.pumpAndSettle();
    expect(navigation.notifications, 0);
    expect(find.text('New Display Name'), findsOneWidget);
    await tester.tap(find.byTooltip('فتح الإشعارات'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تجاهل التغييرات'));
    await tester.pumpAndSettle();
    expect(navigation.notifications, 1);
    expect(find.text('New Display Name'), findsNothing);
    final cubit = tester
        .element(find.byType(SettingsPage))
        .read<SettingsCubit>();
    expect(cubit.state.hasUnsavedChanges, false);
    expect(cubit.state.draftName, 'مستخدم تم');
  });

  testWidgets('profile validation, failure and successful retry feedback', (
    tester,
  ) async {
    final locale = AppLocaleController();
    addTearDown(locale.dispose);
    final repository = MockSettingsRepository()..failNextProfileSave = true;
    await tester.pumpWidget(
      testApp(
        locale: locale,
        navigation: FakeNavigation(),
        repository: repository,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('تعديل الاسم'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('settings-name-field')), 'X');
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ الاسم'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TamTextField>(find.byKey(const Key('settings-name-field')))
          .errorText,
      contains('أدخل اسمًا'),
    );
    await tester.enterText(
      find.byKey(const Key('settings-name-field')),
      'Valid Display',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ الاسم'));
    await tester.pumpAndSettle();
    expect(find.textContaining('تعذر حفظ التغييرات'), findsOneWidget);
    await tester.tap(find.text('حفظ الاسم'));
    await tester.pumpAndSettle();
    expect(find.text('Valid Display'), findsWidgets);
    expect((await repository.loadProfile()).displayName, 'Valid Display');
  });

  testWidgets('layout at 320dp RTL and 800dp LTR with large text', (
    tester,
  ) async {
    final locale = AppLocaleController();
    addTearDown(locale.dispose);
    final navigation = FakeNavigation();
    for (final size in const [Size(320, 750), Size(800, 960)]) {
      if (size.width >= 800) locale.setLocale(const Locale('en'));
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(
        testApp(
          locale: locale,
          navigation: navigation,
          repository: MockSettingsRepository(),
          textScale: 2,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byTooltip(size.width >= 800 ? 'Edit name' : 'تعديل الاسم'),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('visual baseline Arabic 320dp with large text', (tester) async {
    if (!const bool.fromEnvironment('CAPTURE_SETTINGS_GOLDENS')) return;
    final locale = AppLocaleController();
    addTearDown(locale.dispose);
    await tester.binding.setSurfaceSize(const Size(320, 750));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      testApp(
        locale: locale,
        navigation: FakeNavigation(),
        repository: MockSettingsRepository(),
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(SettingsPage),
      matchesGoldenFile('goldens/settings_ar_320_large.png'),
    );
  });

  testWidgets('visual baseline English tablet 800dp', (tester) async {
    if (!const bool.fromEnvironment('CAPTURE_SETTINGS_GOLDENS')) return;
    final locale = AppLocaleController(const Locale('en'));
    addTearDown(locale.dispose);
    await tester.binding.setSurfaceSize(const Size(800, 960));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      testApp(
        locale: locale,
        navigation: FakeNavigation(),
        repository: MockSettingsRepository(),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(SettingsPage),
      matchesGoldenFile('goldens/settings_en_800.png'),
    );
  });

  testWidgets('visual baseline Arabic 390dp', (tester) async {
    if (!const bool.fromEnvironment('CAPTURE_SETTINGS_GOLDENS')) return;
    final locale = AppLocaleController();
    addTearDown(locale.dispose);
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      testApp(
        locale: locale,
        navigation: FakeNavigation(),
        repository: MockSettingsRepository(),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(SettingsPage),
      matchesGoldenFile('goldens/settings_ar_390.png'),
    );
  });
}
