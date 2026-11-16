import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/addresses/addresses_entry.dart';
import 'package:tam_customer/features/addresses/data/mock/mock_addresses_repository.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_places.dart';
import 'package:tam_customer/features/ride_request/domain/repositories/ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_place_picker.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';

class _Search extends Fake implements RideRequestRepository {
  final queries = <String>[];
  Completer<List<RidePlace>>? pending;
  @override
  Future<List<RidePlace>> searchPlaces(String query) async {
    queries.add(query);
    return pending?.future ?? [mockRidePlaces.first];
  }
}

void main() {
  test(
    'clearing search cancels stale results without an empty query request',
    () async {
      final repository = _Search()..pending = Completer<List<RidePlace>>();
      final bloc = RideDraftBloc(repository: repository);
      addTearDown(bloc.close);
      bloc.add(const RidePlaceSearchChanged('place'));
      await bloc.stream.firstWhere((s) => s.searching);
      bloc.add(const RidePlaceSearchChanged('  '));
      await bloc.stream.firstWhere((s) => !s.searching);
      repository.pending!.complete([mockRidePlaces.first]);
      await Future<void>.delayed(Duration.zero);
      expect(repository.queries, ['place']);
      expect(bloc.state.suggestions, isEmpty);
    },
  );

  for (final language in ['ar', 'en']) {
    testWidgets(
      '$language saved shortcuts, search, clear and selection at 320dp/2x/keyboard',
      (tester) async {
        tester.view.physicalSize = const Size(320, 740);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repository = _Search();
        final bloc = RideDraftBloc(repository: repository);
        final addresses = MockAddressesRepository();
        addTearDown(bloc.close);
        addTearDown(addresses.dispose);
        TripLocation? selected;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            locale: Locale(language),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: BlocProvider.value(
              value: bloc,
              child: Scaffold(
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: RidePlacePicker(
                      pickup: false,
                      embedded: true,
                      onSelected: (value) => selected = value,
                      savedAddressPickerBuilder: (onSelected) =>
                          buildSavedAddressPicker(
                            repository: addresses,
                            onSelected: onSelected,
                            onManage: () =>
                                fail('Management must not be offered'),
                            compact: true,
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(repository.queries, isEmpty);
        expect(
          find.byKey(const Key('saved-address-address-home-001')),
          findsOneWidget,
        );
        expect(
          find.text(language == 'ar' ? 'إدارة العناوين' : 'Manage addresses'),
          findsNothing,
        );
        tester.view.viewInsets = const FakeViewPadding(bottom: 260);
        addTearDown(tester.view.resetViewInsets);
        await tester.enterText(find.byType(TextFormField), 'place');
        await tester.pumpAndSettle();
        expect(repository.queries, ['place']);
        expect(
          find.byKey(const Key('saved-address-address-home-001')),
          findsNothing,
        );
        expect(
          find.text(language == 'ar' ? 'شارع الجلاء' : 'Al-Jalaa Street'),
          findsOneWidget,
        );
        await tester.tap(
          find.byTooltip(language == 'ar' ? 'مسح البحث' : 'Clear search'),
        );
        await tester.pumpAndSettle();
        final shortcut = find.byKey(
          const Key('saved-address-address-home-001'),
        );
        await tester.ensureVisible(shortcut);
        await tester.tap(shortcut);
        await tester.pumpAndSettle();
        expect(selected?.label, 'المزة، شارع الجلاء');
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
