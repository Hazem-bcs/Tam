import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/locale/app_locale_controller.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:tam_customer/features/settings/presentation/pages/settings_page.dart';
import 'package:tam_customer/features/settings/settings_entry.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

import 'settings_page_test.dart' show FakeNavigation;

void main() {
  testWidgets('saved settings survive route entry, but not session reset', (
    tester,
  ) async {
    final locale = AppLocaleController();
    addTearDown(locale.dispose);
    Widget app({
      String? phone = '+963912345678',
      FeatureDataMode mode = FeatureDataMode.mock,
    }) => MaterialApp(
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
        builder: (context) => buildSettingsFeature(
          context,
          navigation: FakeNavigation(),
          dataMode: mode,
          locale: locale,
          logout: () async {},
          phoneE164: phone,
        ),
      ),
    );
    SettingsCubit cubit() =>
        tester.element(find.byType(SettingsPage)).read<SettingsCubit>();

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    // Actual app entry must apply the account font while leaving the rest of
    // the global design system untouched.
    final accountContext = tester.element(
      find.byKey(const Key('settings-content')),
    );
    expect(
      Theme.of(accountContext).textTheme.bodyLarge?.fontFamily,
      'TamSansArabic',
    );
    expect(
      Theme.of(accountContext).colorScheme.primary,
      AppTheme.light.colorScheme.primary,
    );
    expect(
      AppTheme.light.textTheme.bodyLarge?.fontFamily,
      isNot('TamSansArabic'),
    );
    cubit().nameChanged('First Account');
    await cubit().saveName();
    cubit().notificationsChanged(false);
    await cubit().savePreferences();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(cubit().state.profile!.displayName, 'First Account');
    expect(cubit().state.preferences!.accountNotificationsEnabled, false);

    resetSettingsFeatureSession(locale);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(cubit().state.profile!.displayName, 'مستخدم تم');
    expect(cubit().state.preferences!.accountNotificationsEnabled, true);

    cubit().nameChanged('Second Account');
    await cubit().saveName();
    await tester.pumpWidget(app(phone: '+963987654321'));
    await tester.pumpAndSettle();
    expect(cubit().state.profile!.displayName, 'مستخدم تم');
    expect(find.text('+963987654321'), findsOneWidget);

    await tester.pumpWidget(app(mode: FeatureDataMode.api));
    await tester.pumpAndSettle();
    expect(cubit().state.isReady, false);
    expect(find.text('مستخدم تم'), findsNothing);
    expect(find.textContaining('غير متاحة'), findsOneWidget);
  });
}
