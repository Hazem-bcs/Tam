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
  void openCompletion(String tripId) {}
  @override
  void openSupport({String? tripId}) {}
  @override
  void openTerms() {}
  @override
  void openPrivacy() {}
  @override
  void openChat(String tripId) {}
  @override
  void openActiveTrip({String? id, bool replaceCurrent = false}) {}
  @override
  void openAccountPhone() {}
  @override
  void openAccountDeletion() {}
  @override
  void openDriverContact(String tripId, String driverId) {}
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
    debugShowCheckedModeBanner: false,
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
        child: Builder(
          builder: (context) => Theme(
            data: AppTheme.account(Theme.of(context)),
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
    filledButtonTheme: FilledButtonThemeData(
      style: base.filledButtonTheme.style?.copyWith(
        textStyle: WidgetStatePropertyAll(
          previewStyle(base.textTheme.labelLarge),
        ),
      ),
    ),
  );
}

File _flutterMaterialFont(String name) {
  var directory = File(Platform.resolvedExecutable).absolute.parent;
  while (true) {
    final file = File('${directory.path}/artifacts/material_fonts/$name');
    if (file.existsSync()) return file;
    if (directory.path == directory.parent.path) break;
    directory = directory.parent;
  }
  throw FileSystemException('Flutter material font not found', name);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    if (const bool.fromEnvironment('CAPTURE_SETTINGS_GOLDENS')) {
      // Load the actual shipped brand fonts to render the same glyphs as Flutter
      // on Android; do not substitute a different host font for the screenshots.
      for (final (name, family) in [
        ('NotoSansArabic-Regular.ttf', 'TamSansArabic'),
        ('NotoSansArabic-Bold.ttf', 'TamSansArabic'),
        ('NotoSans-Regular.ttf', 'TamSansLatin'),
        ('NotoSans-Bold.ttf', 'TamSansLatin'),
      ]) {
        await ui.loadFontFromList(
          await File('assets/fonts/$name').readAsBytes(),
          fontFamily: family,
        );
      }
      await ui.loadFontFromList(
        await _flutterMaterialFont('Roboto-Regular.ttf').readAsBytes(),
        fontFamily: 'Roboto',
      );
      await ui.loadFontFromList(
        await _flutterMaterialFont('MaterialIcons-Regular.otf').readAsBytes(),
        fontFamily: 'MaterialIcons',
      );
    }
  });

  testWidgets('Account headings, row titles and descriptions are distinct', (
    tester,
  ) async {
    final locale = AppLocaleController();
    addTearDown(locale.dispose);
    await tester.pumpWidget(
      testApp(
        locale: locale,
        navigation: FakeNavigation(),
        repository: MockSettingsRepository(),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byKey(const Key('settings-content')));
    final type = Theme.of(context).textTheme;
    expect(type.bodyLarge?.fontFamily, 'TamSansArabic');

    final header = tester.widget<Text>(find.text('الإعدادات'));
    final title = tester.widget<Text>(find.text('اللغة'));
    final detail = tester.widget<Text>(find.text('العربية'));
    expect(header.style?.fontSize, type.titleSmall?.fontSize);
    expect(title.style?.fontSize, 16);
    expect(detail.style?.fontSize, 14);
    expect(header.style?.fontWeight, FontWeight.w700);
    expect(title.style?.fontWeight, FontWeight.w700);
    expect(detail.style?.fontWeight, FontWeight.w400);
    expect(title.style?.color, Theme.of(context).colorScheme.onSurface);
    expect(detail.style?.color, Theme.of(context).colorScheme.onSurfaceVariant);
  });

  testWidgets('Guest profile does not repeat the missing-phone warning', (
    tester,
  ) async {
    final locale = AppLocaleController();
    addTearDown(locale.dispose);
    await tester.pumpWidget(
      testApp(
        locale: locale,
        navigation: FakeNavigation(),
        repository: MockSettingsRepository(),
        phoneE164: null,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('أنت تتصفح كضيف'), findsOneWidget);
    expect(find.text('لا يوجد رقم هاتف لهذه الجلسة'), findsNothing);
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
    expect(find.text('المحفظة'), findsOneWidget);
    expect(find.text('الرصيد غير متاح حاليًا'), findsOneWidget);
    expect(find.text('الوضع الداكن'), findsNothing);

    await tester.tap(find.byTooltip('فتح الإشعارات'));
    expect(navigation.notifications, 1);
  });

  testWidgets(
    'coupon details explain booking entry without activating an offer',
    (tester) async {
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
      await tester.ensureVisible(find.byKey(const Key('settings-coupons')));
      await tester.tap(find.byKey(const Key('settings-coupons')));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(AlertDialog));
      expect(
        find.text(AppLocalizations.of(context).homeCouponInstructions),
        findsOneWidget,
      );
      expect(navigation.home + navigation.trips, 0);
    },
  );

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
    await tester.ensureVisible(find.byKey(const Key('settings-language-tile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-language-tile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-locale-en')));
    await tester.pumpAndSettle();
    expect(locale.value.languageCode, 'en');
    expect(find.text('My account'), findsOneWidget);
    await tester.drag(
      find.byKey(const Key('settings-content')),
      const Offset(0, 1000),
    );
    await tester.pumpAndSettle();
    expect(find.text('+963912345678'), findsOneWidget);
    expect(navigation.home + navigation.trips, 0);
  });

  testWidgets('notification switch saves instantly without a Save button', (
    tester,
  ) async {
    final locale = AppLocaleController();
    addTearDown(locale.dispose);
    final repository = MockSettingsRepository();
    await tester.pumpWidget(
      testApp(
        locale: locale,
        navigation: FakeNavigation(),
        repository: repository,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      (await repository.loadPreferences()).accountNotificationsEnabled,
      true,
    );
    await tester.ensureVisible(
      find.byKey(const Key('settings-notifications-switch')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-notifications-switch')));
    await tester.pumpAndSettle();

    expect(
      (await repository.loadPreferences()).accountNotificationsEnabled,
      false,
    );
    expect(find.text('حفظ تفضيل الإشعارات'), findsNothing);
    final cubit = tester
        .element(find.byType(SettingsPage))
        .read<SettingsCubit>();
    expect(cubit.state.notificationsDirty, false);
    expect(cubit.state.hasUnsavedChanges, false);
  });

  testWidgets('failed immediate save rolls switch back and informs the user', (
    tester,
  ) async {
    final locale = AppLocaleController();
    addTearDown(locale.dispose);
    final repository = MockSettingsRepository()..failNextPreferencesSave = true;
    await tester.pumpWidget(
      testApp(
        locale: locale,
        navigation: FakeNavigation(),
        repository: repository,
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('settings-notifications-switch')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-notifications-switch')));
    await tester.pumpAndSettle();

    expect(
      (await repository.loadPreferences()).accountNotificationsEnabled,
      true,
    );
    final switchWidget = tester.widget<SwitchListTile>(
      find.byKey(const Key('settings-notifications-switch')),
    );
    expect(switchWidget.value, true);
    expect(find.textContaining('تعذر حفظ التغييرات'), findsOneWidget);
    final cubit = tester
        .element(find.byType(SettingsPage))
        .read<SettingsCubit>();
    expect(cubit.state.notificationsDirty, false);

    await tester.ensureVisible(
      find.byKey(const Key('settings-notifications-switch')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-notifications-switch')));
    await tester.pumpAndSettle();
    expect(
      (await repository.loadPreferences()).accountNotificationsEnabled,
      false,
    );
  });

  testWidgets('version information opens a readable disclosure sheet', (
    tester,
  ) async {
    final locale = AppLocaleController();
    addTearDown(locale.dispose);
    await tester.pumpWidget(
      testApp(
        locale: locale,
        navigation: FakeNavigation(),
        repository: MockSettingsRepository(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('settings-content')),
      const Offset(0, -1450),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-version-disclosure')));
    await tester.pumpAndSettle();
    expect(find.text('عن هذه النسخة'), findsWidgets);
    expect(find.textContaining('محاكاة للتطوير'), findsOneWidget);
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
    await tester.tap(find.byKey(const Key('settings-logout-action')));
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

  testWidgets('version sheet remains readable at 320dp with 2x text', (
    tester,
  ) async {
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
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings-version-disclosure')),
      350,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-version-disclosure')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('محاكاة للتطوير'), findsOneWidget);
  });

  testWidgets('visual Arabic version information sheet', (tester) async {
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
    await tester.drag(
      find.byKey(const Key('settings-content')),
      const Offset(0, -1400),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-version-disclosure')));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Overlay).first,
      matchesGoldenFile('goldens/settings_ar_version_sheet.png'),
    );
  });

  testWidgets('visual Arabic account actions below the fold', (tester) async {
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
    await tester.drag(
      find.byKey(const Key('settings-content')),
      const Offset(0, -1300),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings-delete-account')), findsOneWidget);
    await expectLater(
      find.byType(SettingsPage),
      matchesGoldenFile('goldens/settings_ar_actions_scrolled.png'),
    );
  });

  testWidgets('visual Arabic language picker', (tester) async {
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
    final picker = find.byKey(const Key('settings-language-tile'));
    await tester.ensureVisible(picker);
    await tester.pumpAndSettle();
    await tester.tap(picker);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings-locale-ar')), findsOneWidget);
    await expectLater(
      find.byType(Overlay).first,
      matchesGoldenFile('goldens/settings_ar_language_sheet.png'),
    );
  });

  testWidgets('visual Arabic profile editor', (tester) async {
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
    await tester.tap(find.byTooltip('تعديل الاسم'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('settings-name-field')));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(SettingsPage),
      matchesGoldenFile('goldens/settings_ar_profile_editor.png'),
    );
  });

  testWidgets('visual guest account Arabic 390dp', (tester) async {
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
        phoneE164: null,
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(SettingsPage),
      matchesGoldenFile('goldens/settings_ar_guest_390.png'),
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
