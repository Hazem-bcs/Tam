import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_place_picker.dart';
import 'support/customer_app_harness.dart';

void main() {
  for (final size in const [Size(320, 780), Size(800, 360)]) {
    testWidgets(
      'integrated saved-place picker remains usable at $size with keyboard and 2x text',
      (tester) async {
        await launchCustomerApp(tester);
        await enterCustomerSession(tester);
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpAndSettle();
        final entry = find.text('حدد نقطة الانطلاق والوجهة لطلب رحلة');
        await tester.ensureVisible(entry);
        await tester.tap(entry);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('حدد مكان الانطلاق'));
        await tester.tap(find.text('حدد مكان الانطلاق'));
        await tester.pumpAndSettle();
        tester.view.viewInsets = const FakeViewPadding(bottom: 200);
        await tester.pumpAndSettle();
        expect(find.byType(RidePlacePicker), findsOneWidget);
        expect(tester.takeException(), isNull);
        await revealPageWidget(
          tester,
          find.byKey(const Key('ride-saved-addresses')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('ride-saved-addresses')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final saved = find.byKey(const Key('saved-address-address-home-001'));
        await revealPageWidget(tester, saved);
        await tester.pumpAndSettle();
        expect(saved.hitTestable(), findsOneWidget);
        tester.view.resetViewInsets();
        await tester.pumpAndSettle();
        await tester.tap(saved);
        await tester.pumpAndSettle();
        expect(find.byType(RidePlacePicker), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
