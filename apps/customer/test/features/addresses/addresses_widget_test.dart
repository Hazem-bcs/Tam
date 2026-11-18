import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/addresses/data/mock/mock_addresses_repository.dart';
import 'package:tam_customer/features/addresses/data/unavailable_addresses_repository.dart';
import 'package:tam_customer/features/addresses/domain/saved_address.dart';
import 'package:tam_customer/features/addresses/presentation/pages/address_editor_page.dart';
import 'package:tam_customer/features/addresses/presentation/pages/addresses_page.dart';
import 'package:tam_customer/features/addresses/presentation/widgets/address_map_preview.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';

import 'addresses_test_support.dart';

void main() {
  setUpAll(loadAddressPreviewFonts);

  testWidgets('tapping saved place selects it; edit only opens via menu', (
    tester,
  ) async {
    final repository = MockAddressesRepository();
    String? edited;
    await pumpAddresses(tester, repository, onEdit: (id) => edited = id);
    final tile = find.byKey(const Key('address-select-address-home-001'));
    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(edited, isNull);
    expect(find.byKey(const Key('address-preferred-check')), findsNothing);
    final confirm = find.byKey(const Key('addresses-confirm-default'));
    expect(confirm, findsOneWidget);

    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('address-preferred-check')), findsOneWidget);
    expect(confirm, findsNothing);

    await tester.tap(find.byKey(const Key('address-menu-address-home-001')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('address-edit-address-home-001')));
    await tester.pumpAndSettle();
    expect(edited, 'address-home-001');
    await tester.pumpWidget(const SizedBox.shrink());
    await repository.dispose();
  });

  testWidgets('default only changes after confirmation, not when previewed', (
    tester,
  ) async {
    final repository = MockAddressesRepository();
    await pumpAddresses(tester, repository);

    await tester.tap(find.byKey(const Key('address-select-address-home-001')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addresses-confirm-default')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('address-select-address-work-002')));
    await tester.pumpAndSettle();
    final home = find.byKey(const Key('address-item-address-home-001'));
    final work = find.byKey(const Key('address-item-address-work-002'));
    expect(
      find.descendant(
        of: home,
        matching: find.byKey(const Key('address-preferred-check')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: work,
        matching: find.byKey(const Key('address-preferred-check')),
      ),
      findsNothing,
    );
    await tester.tap(find.byKey(const Key('addresses-confirm-default')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: home,
        matching: find.byKey(const Key('address-preferred-check')),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: work,
        matching: find.byKey(const Key('address-preferred-check')),
      ),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await repository.dispose();
  });

  testWidgets('editing a saved place preloads name, icon and map point', (
    tester,
  ) async {
    final repository = MockAddressesRepository();
    final cubit = await pumpAddressEditor(
      tester,
      repository,
      id: 'address-home-001',
    );
    expect(cubit.state.name, 'المنزل');
    expect(cubit.state.icon, AddressIcon.home);
    expect(cubit.state.location?.point.latitude, 33.5);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('address-name')))
          .controller
          ?.text,
      'المنزل',
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await repository.dispose();
  });

  testWidgets(
    'delete requires confirmation and failure keeps the address visible',
    (tester) async {
      final repository = MockAddressesRepository();
      final cubit = await pumpAddresses(tester, repository);
      // Edit/delete are now contextual actions behind the address menu.
      await tester.tap(find.byKey(const Key('address-menu-address-home-001')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('address-delete-address-home-001')),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('address-delete-dialog')), findsOneWidget);
      expect(find.byKey(const Key('address-delete-cancel')), findsOneWidget);
      expect(find.byKey(const Key('address-delete-confirm')), findsOneWidget);
      await tester.tap(find.byKey(const Key('address-delete-cancel')));
      await tester.pumpAndSettle();
      expect(cubit.state.items, hasLength(2));
      repository.failOnce(AddressOperation.delete);
      // Edit/delete are now contextual actions behind the address menu.
      await tester.tap(find.byKey(const Key('address-menu-address-home-001')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('address-delete-address-home-001')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('address-delete-confirm')));
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

  testWidgets('save stays disabled until name and map coordinate are valid', (
    tester,
  ) async {
    final repository = MockAddressesRepository();
    final cubit = await pumpAddressEditor(tester, repository);
    final save = find.byKey(const Key('address-save'));
    expect(tester.widget<TamButton>(save).onPressed, isNull);
    expect(find.byKey(const Key('address-map-tap')), findsNothing);
    expect(find.byType(AddressMapPreview), findsOneWidget);

    await tester.enterText(find.byKey(const Key('address-name')), 'مكان جديد');
    await tester.pump();
    expect(tester.widget<TamButton>(save).onPressed, isNull);

    cubit.locationSelected(
      TripLocation(
        label: '33.50000, 36.25000',
        point: GeoPoint(latitude: 33.5, longitude: 36.25),
      ),
    );
    await tester.pump();
    expect(tester.widget<TamButton>(save).onPressed, isNotNull);

    await tester.ensureVisible(find.byKey(const Key('address-icon-gym')));
    await tester.tap(find.byKey(const Key('address-icon-gym')));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(cubit.state.original!.input.icon, AddressIcon.gym);
    expect(
      (await repository.list()).where((a) => a.input.name == 'مكان جديد'),
      hasLength(1),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await repository.dispose();
  });

  testWidgets('place editor never opens the old map selection page', (
    tester,
  ) async {
    final repository = MockAddressesRepository();
    await pumpAddressEditor(tester, repository);
    expect(find.byKey(const Key('address-editor-sheet')), findsOneWidget);
    expect(find.byKey(const Key('address-icons-scroll')), findsOneWidget);
    expect(find.byKey(const Key('address-map-tap')), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await repository.dispose();
  });

  testWidgets('editor follows the map and one-row address icon layout', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = MockAddressesRepository();
    await pumpAddressEditor(tester, repository);
    expect(find.byType(AddressMapPreview), findsOneWidget);
    expect(find.byKey(const Key('address-editor-sheet')), findsOneWidget);
    expect(find.byKey(const Key('address-icons-scroll')), findsOneWidget);
    // On Arabic screens, the map actions follow the reading start (right).
    expect(
      tester.getTopLeft(find.byKey(const Key('address-map-back'))).dx,
      greaterThan(195),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('address-map-locate'))).dx,
      greaterThan(195),
    );

    final home = find.byKey(const Key('address-icon-home'));
    final work = find.byKey(const Key('address-icon-work'));
    final study = find.byKey(const Key('address-icon-study'));
    await tester.ensureVisible(home);
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(home).dy, tester.getTopLeft(work).dy);
    expect(tester.getTopLeft(work).dy, tester.getTopLeft(study).dy);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await repository.dispose();
  });

  testWidgets('details sheet can collapse and expand without leaving map', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = MockAddressesRepository();
    await pumpAddressEditor(tester, repository);
    final surface = find.byKey(const Key('address-sheet-surface'));
    final start = tester.getTopLeft(surface).dy;
    await tester.dragFrom(
      tester.getTopLeft(surface) + const Offset(195, 16),
      const Offset(0, 240),
    );
    await tester.pumpAndSettle();
    final collapsed = tester.getTopLeft(surface).dy;
    expect(collapsed, greaterThan(start));
    await tester.dragFrom(
      tester.getTopLeft(surface) + const Offset(195, 16),
      const Offset(0, -440),
    );
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(surface).dy, lessThan(collapsed));
    expect(find.byType(AddressMapPreview), findsOneWidget);
    // The panel cannot be dragged beyond its content height.
    final expandedTop = tester.getTopLeft(surface).dy;
    await tester.dragFrom(
      tester.getTopLeft(surface) + const Offset(195, 16),
      const Offset(0, -450),
    );
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(surface).dy, closeTo(expandedTop, 1));
    await tester.pumpWidget(const SizedBox.shrink());
    await repository.dispose();
  });

  testWidgets('selected address icon keeps the same size and no checkmark', (
    tester,
  ) async {
    final repository = MockAddressesRepository();
    await pumpAddressEditor(tester, repository);
    final home = find.byKey(const Key('address-icon-home'));
    final work = find.byKey(const Key('address-icon-work'));
    await tester.ensureVisible(work);
    final beforeHome = tester.getSize(home);
    final beforeWork = tester.getSize(work);
    expect(beforeHome, beforeWork);
    await tester.tap(work);
    await tester.pumpAndSettle();
    expect(tester.getSize(home), beforeHome);
    expect(tester.getSize(work), beforeWork);
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await repository.dispose();
  });

  testWidgets('visual empty account and location search states', (
    tester,
  ) async {
    if (!captureAddressUi) return;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final emptyRepository = MockAddressesRepository(seed: []);
    await pumpAddresses(tester, emptyRepository);
    await expectLater(
      find.byType(AddressesPage),
      matchesGoldenFile('goldens/empty-ar-390.png'),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await emptyRepository.dispose();

    final repository = MockAddressesRepository();
    await pumpAddressEditor(tester, repository);
    await expectLater(
      find.byType(AddressEditorPage),
      matchesGoldenFile('goldens/add-ar-390.png'),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await repository.dispose();
  });

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
      expect(find.byType(AddressMapPreview), findsOneWidget);
      tester.view.viewInsets = const FakeViewPadding(bottom: 200);
      await tester.pumpAndSettle();
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
