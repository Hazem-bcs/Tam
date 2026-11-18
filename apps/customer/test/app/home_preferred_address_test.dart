import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/features/addresses/presentation/pages/addresses_page.dart';

import 'support/customer_app_harness.dart';

void main() {
  testWidgets('an open address sheet closes when the session ends', (
    tester,
  ) async {
    await launchCustomerApp(tester);
    await enterCustomerSession(tester);
    final auth = customerAuth(tester);
    await tester.tap(find.byKey(const Key('home-default-address')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home-address-sheet')), findsOneWidget);
    await auth.logout();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home-address-sheet')), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('confirmed address and home sheet share the same default', (
    tester,
  ) async {
    await launchCustomerApp(tester);
    await enterCustomerSession(tester);
    final router = customerRouter(tester);
    final bar = find.byKey(const Key('home-default-address'));
    expect(
      find.descendant(of: bar, matching: find.text('حدد عنوانك الافتراضي')),
      findsOneWidget,
    );

    router.push(AppRoutes.addresses);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('address-select-address-work-001')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addresses-confirm-default')));
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: bar, matching: find.text('أبو رمانة، شارع الحمراء')),
      findsOneWidget,
    );

    await tester.tap(bar);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home-address-sheet')), findsOneWidget);
    expect(find.byType(AddressesPage), findsNothing);
    await tester.tap(
      find.byKey(const Key('home-address-option-address-home-001')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home-address-sheet')), findsNothing);
    expect(
      find.descendant(of: bar, matching: find.text('المزة، شارع الجلاء')),
      findsOneWidget,
    );

    await tester.tap(bar);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-manage-addresses')));
    await tester.pumpAndSettle();
    expect(find.byType(AddressesPage), findsOneWidget);
    final homeTile = find.byKey(const Key('address-item-address-home-001'));
    expect(
      find.descendant(
        of: homeTile,
        matching: find.byKey(const Key('address-preferred-check')),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('address-menu-address-home-001')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('address-delete-address-home-001')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف'));
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: bar, matching: find.text('حدد عنوانك الافتراضي')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('preferred address is cleared when the session ends', (
    tester,
  ) async {
    await launchCustomerApp(tester);
    await enterCustomerSession(tester);
    final bar = find.byKey(const Key('home-default-address'));
    await tester.tap(bar);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('home-address-option-address-work-001')),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: bar, matching: find.text('أبو رمانة، شارع الحمراء')),
      findsOneWidget,
    );
    await customerAuth(tester).logout();
    await tester.pumpAndSettle();
    await enterCustomerSession(tester, phone: null);
    expect(
      find.descendant(of: bar, matching: find.text('حدد عنوانك الافتراضي')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
