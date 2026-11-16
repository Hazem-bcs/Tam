import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/addresses/addresses_entry.dart';
import 'package:tam_customer/features/addresses/data/mock/addresses_fixture.dart';
import 'package:tam_customer/features/addresses/domain/addresses_repository.dart';
import 'package:tam_customer/features/addresses/presentation/bloc/address_editor_cubit.dart';
import 'package:tam_customer/features/addresses/presentation/bloc/addresses_cubit.dart';
import 'package:tam_customer/features/addresses/presentation/pages/address_editor_page.dart';
import 'package:tam_customer/features/addresses/presentation/pages/addresses_page.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';

import '../../support/preview_fonts.dart';

const captureAddressUi = bool.fromEnvironment('CAPTURE_ADDRESS_UI');

final class AddressTestPlaces implements AddressPlaceSearch {
  @override
  Future<List<TripLocation>> search(String query) async => seedAddresses()
      .map((item) => item.input.location)
      .where((item) => item.label.contains(query))
      .toList();
}

Future<void> loadAddressPreviewFonts() =>
    loadPreviewFonts(enabled: captureAddressUi);

Widget addressTestApp({
  required Widget child,
  String locale = 'ar',
  double scale = 1,
}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: captureAddressUi ? previewTheme() : AppTheme.light,
  locale: Locale(locale),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: child,
);

Future<AddressesCubit> pumpAddresses(
  WidgetTester tester,
  AddressesRepository repository, {
  String locale = 'ar',
  double scale = 1,
  VoidCallback? onAdd,
}) async {
  await tester.pumpWidget(
    addressTestApp(
      locale: locale,
      scale: scale,
      child: Builder(
        builder: (context) => buildAddressesFeature(
          context,
          repository: repository,
          onAdd: onAdd ?? () {},
          onEdit: (_) {},
          onBack: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return tester.element(find.byType(AddressesPage)).read<AddressesCubit>();
}

Future<AddressEditorCubit> pumpAddressEditor(
  WidgetTester tester,
  AddressesRepository repository, {
  String? id,
  String locale = 'ar',
  double scale = 1,
}) async {
  await tester.pumpWidget(
    addressTestApp(
      locale: locale,
      scale: scale,
      child: Builder(
        builder: (context) => buildAddressEditorFeature(
          context,
          repository: repository,
          places: AddressTestPlaces(),
          id: id,
          onBack: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return tester
      .element(find.byType(AddressEditorPage))
      .read<AddressEditorCubit>();
}
