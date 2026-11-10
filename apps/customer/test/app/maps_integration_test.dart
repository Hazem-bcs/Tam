import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/di/service_locator.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/core/config/map_configuration.dart';
import 'package:tam_customer/features/addresses/presentation/bloc/address_editor_cubit.dart';
import 'package:tam_customer/features/addresses/presentation/bloc/addresses_cubit.dart';
import 'package:tam_customer/features/addresses/presentation/pages/address_editor_page.dart';
import 'package:tam_customer/features/addresses/presentation/pages/addresses_page.dart';
import 'package:tam_customer/features/maps/maps_dependencies.dart';
import 'package:tam_customer/features/maps/presentation/pages/map_location_picker_page.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/features/ride_request/presentation/pages/ride_request_page.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';

import '../features/maps/maps_test_support.dart';
import 'support/customer_app_harness.dart';

Future<void> pin(WidgetTester tester, String label) async {
  final map = find.byType(FlutterMap).last;
  await Scrollable.ensureVisible(tester.element(map), alignment: .5);
  await tester.pumpAndSettle();
  await tester.tapAt(tester.getCenter(map));
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
  final field = find.byKey(const Key('map-location-label'));
  await revealPageWidget(tester, field);
  await tester.enterText(field, label);
  tester.testTextInput.hide();
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('map-confirm-location')));
  await tester.pumpAndSettle();
  expect(find.byType(MapLocationPickerPage), findsNothing);
}

void main() {
  testWidgets(
    'logout disposes pending GPS and a new session starts without its point',
    (tester) async {
      final gps = Completer<GeoPoint>();
      final device = LocationProbe()..onLocate = () => gps.future;
      locator.registerSingleton<MapsDependencies>(
        MapsDependencies(
          configuration: const MapConfiguration(),
          repository: MapsProbe(),
          deviceLocation: device,
        ),
      );
      addTearDown(() => locator.unregister<MapsDependencies>());
      await launchCustomerApp(tester);
      await enterCustomerSession(tester);
      final auth = customerAuth(tester);
      customerRouter(tester).push(AppRoutes.rideRequest);
      await tester.pumpAndSettle();
      await tester.tap(find.text('حدد مكان الانطلاق'));
      await tester.pumpAndSettle();
      await revealPageWidget(tester, find.byKey(const Key('ride-pick-on-map')));
      await tester.tap(find.byKey(const Key('ride-pick-on-map')));
      await tester.pumpAndSettle();
      final locate = find.byKey(const Key('map-use-device-location'));
      await revealPageWidget(tester, locate);
      await tester.tap(locate);
      await tester.pump();
      expect(device.calls, 1);
      await auth.logout();
      await tester.pumpAndSettle();
      expect(find.byType(MapLocationPickerPage), findsNothing);
      gps.complete(origin);
      await tester.pumpAndSettle();
      await enterCustomerSession(tester, phone: '0947654321');
      customerRouter(tester).push(AppRoutes.rideRequest);
      await tester.pumpAndSettle();
      final draft = tester
          .element(find.byType(RideRequestPage))
          .read<RideDraftBloc>();
      expect(draft.state.pickup, isNull);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'manual map pin reaches booking draft without a backend or public tiles',
    (tester) async {
      await launchCustomerApp(tester);
      await enterCustomerSession(tester);
      customerRouter(tester).push(AppRoutes.rideRequest);
      await tester.pumpAndSettle();
      await tester.tap(find.text('حدد مكان الانطلاق'));
      await tester.pumpAndSettle();
      await revealPageWidget(tester, find.byKey(const Key('ride-pick-on-map')));
      await tester.tap(find.byKey(const Key('ride-pick-on-map')));
      await tester.pumpAndSettle();
      expect(find.byType(TileLayer), findsNothing);
      await pin(tester, 'المدخل الذي اخترته');
      final draft = tester
          .element(find.byType(RideRequestPage))
          .read<RideDraftBloc>();
      expect(draft.state.pickup!.label, 'المدخل الذي اخترته');
      expect(draft.state.pickup!.point.latitude, closeTo(33.5138, .02));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'a map pin returns to saved address editor and persists exact point',
    (tester) async {
      await launchCustomerApp(tester);
      await enterCustomerSession(tester);
      final router = customerRouter(tester);
      router.push(AppRoutes.addresses);
      await tester.pumpAndSettle();
      router.push(AppRoutes.addAddress);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('address-choose-location')));
      await tester.pumpAndSettle();
      await revealPageWidget(
        tester,
        find.byKey(const Key('address-pick-on-map')),
      );
      await tester.tap(find.byKey(const Key('address-pick-on-map')));
      await tester.pumpAndSettle();
      await pin(tester, 'عنوان على الخريطة');
      final editor = tester
          .element(find.byType(AddressEditorPage))
          .read<AddressEditorCubit>();
      expect(editor.state.location!.label, 'عنوان على الخريطة');
      final point = editor.state.location!.point;
      final name = find.byKey(const Key('address-name'));
      await revealPageWidget(tester, name);
      await tester.enterText(name, 'موقعي');
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      final save = find.byKey(const Key('address-save'));
      await revealPageWidget(tester, save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      final all = tester
          .element(find.byType(AddressesPage))
          .read<AddressesCubit>()
          .state
          .items;
      expect(all.any((a) => a.input.location.point == point), isTrue);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );
}
