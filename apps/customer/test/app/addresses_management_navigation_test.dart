import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/addresses/presentation/pages/addresses_page.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_place_picker.dart';
import 'support/customer_app_harness.dart';

void main() {
  testWidgets('managing addresses from booking returns to the live picker', (
    tester,
  ) async {
    await launchCustomerApp(tester);
    await enterCustomerSession(tester);
    final entry = find.text('حدد نقطة الانطلاق والوجهة لطلب رحلة');
    await tester.ensureVisible(entry);
    await tester.tap(entry);
    await tester.pumpAndSettle();
    await tester.tap(find.text('حدد مكان الانطلاق'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ride-saved-addresses')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('إدارة العناوين'));
    await tester.tap(find.text('إدارة العناوين'));
    await tester.pumpAndSettle();
    expect(find.byType(AddressesPage), findsOneWidget);
    await tester.tap(find.byKey(const Key('address-delete-address-home-001')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButtonIcon).last);
    await tester.pumpAndSettle();
    expect(find.byType(RidePlacePicker), findsOneWidget);
    expect(
      find.byKey(const Key('saved-address-address-home-001')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('saved-address-address-work-001')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
