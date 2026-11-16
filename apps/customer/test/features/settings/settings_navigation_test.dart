import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/locale/app_locale_controller.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/settings/data/mock/mock_settings_repository.dart';
import 'package:tam_customer/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:tam_customer/features/settings/presentation/pages/settings_page.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

import 'settings_page_test.dart' show FakeNavigation, testApp;

void main() {
  testWidgets('system back keeps draft unless user explicitly discards', (
    tester,
  ) async {
    final locale = AppLocaleController();
    addTearDown(locale.dispose);
    final repository = MockSettingsRepository();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              key: const Key('open-settings'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider(
                    create: (_) => SettingsCubit(repository)..load(),
                    child: SettingsPage(
                      navigation: FakeNavigation(),
                      locale: locale,
                      logout: () async {},
                    ),
                  ),
                ),
              ),
              child: const Text('Open settings'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('تعديل الاسم'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('settings-name-field')),
      'Draft Name',
    );
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('تغييرات غير محفوظة'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('متابعة التعديل'));
    await tester.pumpAndSettle();
    expect(find.text('Draft Name'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text('تجاهل التغييرات'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsPage), findsNothing);
    expect((await repository.loadProfile()).displayName, 'مستخدم تم');
  });

  testWidgets('name editor stays scrollable above keyboard on small phone', (
    tester,
  ) async {
    final locale = AppLocaleController();
    addTearDown(locale.dispose);
    await tester.binding.setSurfaceSize(const Size(320, 750));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(
      testApp(
        locale: locale,
        navigation: FakeNavigation(),
        repository: MockSettingsRepository(),
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();
    // The new account header is scrollable. Reach the edit action first when
    // the keyboard occupies much of a compact, large-text viewport.
    await tester.ensureVisible(find.byTooltip('تعديل الاسم'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('تعديل الاسم'));
    await tester.pumpAndSettle();
    final input = find.byKey(const Key('settings-name-field'));
    await tester.ensureVisible(input);
    await tester.enterText(input, 'Long Display Name With Several Words');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('حفظ الاسم'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('حفظ الاسم'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
