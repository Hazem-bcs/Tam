import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/addresses/data/mock/mock_addresses_repository.dart';
import 'package:tam_customer/features/addresses/data/unavailable_addresses_repository.dart';
import 'package:tam_customer/features/addresses/presentation/bloc/addresses_cubit.dart';
import 'package:tam_customer/features/addresses/presentation/bloc/preferred_address_selection.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_preferred_address_bar.dart';

import 'addresses_test_support.dart';

void main() {
  for (final spec in [
    (const Size(320, 640), 'ar', 2.0),
    (const Size(800, 400), 'en', 2.0),
  ]) {
    testWidgets('address sheet fits ${spec.$1} ${spec.$2} at ${spec.$3}', (
      tester,
    ) async {
      tester.view.physicalSize = spec.$1;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = MockAddressesRepository();
      final selection = PreferredAddressSelection();
      addTearDown(repo.dispose);
      addTearDown(selection.close);
      await tester.pumpWidget(
        addressTestApp(
          locale: spec.$2,
          scale: spec.$3,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => AddressesCubit(repo)..load()),
              BlocProvider.value(value: selection),
            ],
            child: Scaffold(body: HomePreferredAddressBar(onManage: () {})),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('home-default-address')));
      await tester.pumpAndSettle();
      final option = find.byKey(
        const Key('home-address-option-address-work-001'),
      );
      await tester.ensureVisible(option);
      await tester.pumpAndSettle();
      await tester.tap(option);
      await tester.pumpAndSettle();
      expect(selection.state, 'address-work-001');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('empty and failed address lists remain actionable', (
    tester,
  ) async {
    final repo = MockAddressesRepository(seed: []);
    final selection = PreferredAddressSelection();
    addTearDown(repo.dispose);
    addTearDown(selection.close);
    repo.failOnce(AddressOperation.list);
    var managed = false;
    await tester.pumpWidget(
      addressTestApp(
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => AddressesCubit(repo)..load()),
            BlocProvider.value(value: selection),
          ],
          child: Scaffold(
            body: HomePreferredAddressBar(onManage: () => managed = true),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-default-address')));
    await tester.pumpAndSettle();
    expect(find.text('تعذر إكمال العملية. حاول مجددًا.'), findsWidgets);
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();
    expect(
      find.text('أضف مكانًا لتختاره بسهولة عند طلب رحلة.'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('home-manage-addresses')));
    await tester.pumpAndSettle();
    expect(managed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unavailable address service never displays mock addresses', (
    tester,
  ) async {
    final selection = PreferredAddressSelection()..choose('address-work-001');
    addTearDown(selection.close);
    await tester.pumpWidget(
      addressTestApp(
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  AddressesCubit(const UnavailableAddressesRepository())
                    ..load(),
            ),
            BlocProvider.value(value: selection),
          ],
          child: Scaffold(body: HomePreferredAddressBar(onManage: () {})),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-default-address')));
    await tester.pumpAndSettle();
    expect(
      find.text('خدمة العناوين غير متاحة في وضع API حاليًا.'),
      findsWidgets,
    );
    expect(
      find.byKey(const Key('home-address-option-address-work-001')),
      findsNothing,
    );
    expect(selection.state, 'address-work-001');
    expect(tester.takeException(), isNull);
  });
}
