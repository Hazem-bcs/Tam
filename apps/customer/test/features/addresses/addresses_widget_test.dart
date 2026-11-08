import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/addresses/data/mock/mock_addresses_repository.dart';
import 'package:tam_customer/features/addresses/data/unavailable_addresses_repository.dart';
import 'package:tam_customer/features/addresses/domain/saved_address.dart';
import 'package:tam_customer/features/addresses/presentation/pages/address_editor_page.dart';
import 'package:tam_customer/features/addresses/presentation/pages/addresses_page.dart';
import 'package:tam_customer/features/addresses/presentation/widgets/address_location_picker.dart';

import 'addresses_test_support.dart';

void main() {
  setUpAll(loadAddressPreviewFonts);

  testWidgets(
    'delete requires confirmation and failure keeps the address visible',
    (tester) async {
      final repository = MockAddressesRepository();
      final cubit = await pumpAddresses(tester, repository);
      await tester.tap(
        find.byKey(const Key('address-delete-address-home-001')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();
      expect(cubit.state.items, hasLength(2));
      repository.failOnce(AddressOperation.delete);
      await tester.tap(
        find.byKey(const Key('address-delete-address-home-001')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('حذف'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('address-item-address-home-001')),
        findsOneWidget,
      );
      expect(find.text('تعذر إكمال العملية. حاول مجددًا.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(repository.hasListeners, false);
      await repository.dispose();
    },
  );

  testWidgets('empty, failed, retry and API unavailable states stay honest', (
    tester,
  ) async {
    final repository = MockAddressesRepository(seed: [])
      ..failOnce(AddressOperation.list);
    await pumpAddresses(tester, repository);
    expect(find.text('تعذر إكمال العملية. حاول مجددًا.'), findsOneWidget);
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();
    expect(find.text('لا توجد عناوين محفوظة بعد'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await repository.dispose();
    await pumpAddresses(tester, const UnavailableAddressesRepository());
    expect(
      find.text('خدمة العناوين غير متاحة في وضع API حاليًا.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('address-item-address-home-001')),
      findsNothing,
    );
  });

  testWidgets(
    'editor selects an existing place, validates and saves icon/name',
    (tester) async {
      final repository = MockAddressesRepository();
      final cubit = await pumpAddressEditor(tester, repository);
      await tester.ensureVisible(find.byKey(const Key('address-save')));
      await tester.tap(find.byKey(const Key('address-save')));
      await tester.pumpAndSettle();
      expect(find.text('اختر موقعًا قبل الحفظ.'), findsOneWidget);
      await tester.ensureVisible(
        find.byKey(const Key('address-choose-location')),
      );
      await tester.tap(find.byKey(const Key('address-choose-location')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('أبو رمانة، شارع الحمراء'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('address-name')),
        'مكان جديد',
      );
      await tester.ensureVisible(find.byKey(const Key('address-icon-gym')));
      await tester.tap(find.byKey(const Key('address-icon-gym')));
      await tester.ensureVisible(find.byKey(const Key('address-save')));
      await tester.tap(find.byKey(const Key('address-save')));
      await tester.pumpAndSettle();
      expect(cubit.state.original!.input.icon, AddressIcon.gym);
      expect(
        (await repository.list()).where((a) => a.input.name == 'مكان جديد'),
        hasLength(1),
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await repository.dispose();
    },
  );

  for (final config in [
    (390.0, 844.0, 'ar', 1.0),
    (390.0, 844.0, 'en', 1.0),
    (800.0, 1000.0, 'ar', 1.0),
    (320.0, 780.0, 'ar', 2.0),
    (800.0, 360.0, 'en', 2.0),
  ]) {
    testWidgets('list and editor fit $config with keyboard and scaled text', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(config.$1, config.$2);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = MockAddressesRepository();
      await pumpAddresses(
        tester,
        repository,
        locale: config.$3,
        scale: config.$4,
      );
      expect(tester.takeException(), isNull);
      if (captureAddressUi) {
        await expectLater(
          find.byType(AddressesPage),
          matchesGoldenFile(
            'goldens/list-${config.$3}-${config.$1.toInt()}-x${config.$4.toInt()}.png',
          ),
        );
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await pumpAddressEditor(
        tester,
        repository,
        id: 'address-home-001',
        locale: config.$3,
        scale: config.$4,
      );
      expect(find.text('المنزل'), findsOneWidget);
      expect(tester.takeException(), isNull);
      if (captureAddressUi) {
        await expectLater(
          find.byType(AddressEditorPage),
          matchesGoldenFile(
            'goldens/editor-${config.$3}-${config.$1.toInt()}-x${config.$4.toInt()}.png',
          ),
        );
      }
      await tester.tap(find.byKey(const Key('address-choose-location')));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 200);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final location = find.descendant(
        of: find.byType(AddressLocationPicker),
        matching: find.text('المزة، شارع الجلاء'),
      );
      await tester.scrollUntilVisible(
        location,
        100,
        scrollable: find
            .descendant(
              of: find.byType(AddressLocationPicker),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      expect(location.hitTestable(), findsOneWidget);
      await tester.tap(location);
      await tester.pumpAndSettle();
      tester.view.resetViewInsets();
      tester.view.viewInsets = const FakeViewPadding(bottom: 200);
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('address-save')));
      expect(
        find.byKey(const Key('address-save')).hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      tester.view.resetViewInsets();
      await tester.pumpWidget(const SizedBox.shrink());
      await repository.dispose();
    });
  }
}
