import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/account_management/account_management_entry.dart';
import 'package:tam_customer/features/account_management/data/mock/mock_account_management_repository.dart';
import 'package:tam_customer/features/driver_contact/driver_contact_entry.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';

import '../../support/preview_fonts.dart';
import '../driver_contact/driver_contact_test_support.dart'
    show ContactProbe, DialerProbe;
import 'account_test_support.dart';

const _capture = bool.fromEnvironment('CAPTURE_ACCOUNT_CONTACT_UI');
Future<void> capture(WidgetTester tester, String name) async {
  if (_capture) {
    await expectLater(
      find.byKey(const Key('account-preview')),
      matchesGoldenFile(
        '../../../../../docs/engineering/deliveries/W3-ACCOUNT-CONTACT/screenshots/$name.png',
      ),
    );
  }
}

Future<void> reveal(WidgetTester tester, String key) async {
  await tester.scrollUntilVisible(
    find.byKey(Key(key)),
    160,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => loadPreviewFonts(enabled: _capture));
  for (final lang in ['ar', 'en']) {
    for (final size in [
      const Size(320, 740),
      const Size(390, 844),
      const Size(800, 1000),
      const Size(844, 390),
    ]) {
      for (final action in AccountAction.values) {
        testWidgets(
          '$lang $size $action: keyboard, confirmation and deletion consent usable at 2x',
          (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            addTearDown(tester.view.resetViewInsets);
            final store = MockTripStore();
            final r = MockAccountManagementRepository(
              store,
              phone: () => '+963912345678',
              now: () => accountNow,
            );
            addTearDown(store.dispose);
            addTearDown(r.dispose);
            var completed = 0;
            Widget app(Widget page) => RepaintBoundary(
              key: const Key('account-preview'),
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: _capture ? previewTheme() : AppTheme.light,
                locale: Locale(lang),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(size.width == 390 ? 1 : 2),
                  ),
                  child: child!,
                ),
                home: page,
              ),
            );
            await tester.pumpWidget(
              app(
                buildAccountManagementFeature(
                  repository: r,
                  action: action,
                  now: () => accountNow,
                  onBack: () {},
                  onCompleted: () async {
                    completed++;
                  },
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            await capture(
              tester,
              '${action.name}-$lang-${size.width.toInt()}-start',
            );
            if (action == AccountAction.deleteAccount) {
              await reveal(tester, 'account-consent');
              await tester.tap(find.byKey(const Key('account-consent')));
              await tester.pumpAndSettle();
            } else {
              await reveal(tester, 'account-phone');
              await tester.enterText(
                find.byKey(const Key('account-phone')),
                '0951234567',
              );
            }
            await reveal(tester, 'account-start');
            await tester.tap(find.byKey(const Key('account-start')));
            await tester.pumpAndSettle();
            await reveal(tester, 'account-code');
            await tester.enterText(
              find.byKey(const Key('account-code')),
              '123456',
            );
            tester.view.viewInsets = FakeViewPadding(
              bottom: size.height < 500 ? 100 : 260,
            );
            await tester.pumpAndSettle();
            await reveal(tester, 'account-confirm');
            expect(
              find.byKey(const Key('account-confirm')).hitTestable(),
              findsOneWidget,
            );
            await capture(
              tester,
              '${action.name}-$lang-${size.width.toInt()}-keyboard',
            );
            await tester.tap(find.byKey(const Key('account-confirm')));
            await tester.pumpAndSettle();
            expect(completed, 1);
            expect(tester.takeException(), isNull);
            tester.view.resetViewInsets();
            await tester.pumpWidget(const SizedBox());
            final contacts = ContactProbe();
            addTearDown(contacts.events.close);
            await tester.pumpWidget(
              app(
                buildDriverContactFeature(
                  repository: contacts,
                  dialer: DialerProbe(),
                  tripId: 'trip',
                  driverId: 'driver',
                  now: () => accountNow,
                  onBack: () {},
                ),
              ),
            );
            await tester.pumpAndSettle();
            await reveal(tester, 'driver-contact-call');
            await tester.tap(find.byKey(const Key('driver-contact-call')));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            await capture(tester, 'contact-$lang-${size.width.toInt()}');
            await tester.pumpWidget(const SizedBox());
          },
        );
      }
    }
  }
}
