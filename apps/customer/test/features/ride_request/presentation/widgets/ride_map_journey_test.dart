import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/core/config/map_configuration.dart';
import 'package:tam_customer/features/maps/domain/maps_repository.dart';
import 'package:tam_customer/features/maps/maps_dependencies.dart';
import 'package:tam_customer/features/maps/presentation/maps_scope.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/features/ride_request/presentation/pages/ride_request_page.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_map_point_panel.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import '../../../maps/maps_test_support.dart';
import '../../scheduling/schedule_widget_support.dart';

class _Settings implements DeviceLocationSettings {
  @override
  Future<bool> openAppSettings() async => true;
  @override
  Future<bool> openLocationSettings() async => true;
}

void main() {
  Future<RideDraftBloc> launch(
    WidgetTester tester,
    LocationProbe gps, {
    double scale = 1,
  }) async {
    final store = MockTripStore();
    final bloc = RideDraftBloc(
      repository: MockRideRequestRepository(trips: store),
    );
    addTearDown(() async {
      if (!bloc.isClosed) await bloc.close();
      await store.dispose();
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: MapsScope(
          dependencies: MapsDependencies(
            configuration: const MapConfiguration(),
            repository: MapsProbe(),
            deviceLocation: gps,
            locationSettings: _Settings(),
          ),
          child: BlocProvider.value(
            value: bloc,
            child: const RideRequestPage(navigation: ScheduleTestNavigation()),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 350));
    return bloc;
  }

  void phone(WidgetTester tester, {double width = 390}) {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets(
    'GPS pickup, folding without resetting the map, and naming a tapped destination',
    (tester) async {
      phone(tester);
      final bloc = await launch(tester, LocationProbe());
      await tester.pumpAndSettle();
      expect(bloc.state.pickup?.point, origin);
      expect(find.text('موقعي الحالي'), findsOneWidget);
      final mapState = tester.state(find.byType(FlutterMap));
      await tester.tap(find.byKey(const Key('ride-sheet-toggle')));
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(FlutterMap)), same(mapState));
      await tester.tap(find.byKey(const Key('ride-sheet-toggle')));
      await tester.pumpAndSettle();
      final handle = tester.getCenter(
        find.byKey(const Key('ride-sheet-toggle')),
      );
      await tester.dragFrom(Offset(195, handle.dy), const Offset(0, 350));
      await tester.pumpAndSettle();
      expect(find.byTooltip('إظهار تفاصيل المشوار'), findsOneWidget);
      await tester.tapAt(
        tester.getTopLeft(find.byType(FlutterMap)) + const Offset(200, 270),
      );
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      final point = tester
          .widget<RideMapPointPanel>(find.byType(RideMapPointPanel))
          .point;
      await tester.enterText(
        find.byKey(const Key('ride-map-point-description')),
        'بوابة الحديقة',
      );
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('ride-sheet-toggle')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('ride-sheet-toggle')));
      await tester.pumpAndSettle();
      expect(find.text('بوابة الحديقة'), findsOneWidget);
      final destination = find.byKey(const Key('ride-map-use-destination'));
      await tester.ensureVisible(destination);
      await tester.tap(destination);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      expect(bloc.state.destination?.point, point);
      expect(bloc.state.destination?.label, 'بوابة الحديقة');
      expect(bloc.state.pickup?.point, origin);
      expect(bloc.state.confirmedTrip, isNull);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(bloc.close);
    },
  );

  testWidgets(
    'a manual map pickup is not replaced by a late automatic GPS fix',
    (tester) async {
      phone(tester);
      final pending = Completer<GeoPoint>();
      final gps = LocationProbe()..onLocate = () => pending.future;
      final bloc = await launch(tester, gps);
      await tester.tapAt(
        tester.getTopLeft(find.byType(FlutterMap)) + const Offset(200, 260),
      );
      await tester.pump(const Duration(milliseconds: 400));
      final point = tester
          .widget<RideMapPointPanel>(find.byType(RideMapPointPanel))
          .point;
      final pickup = find.byKey(const Key('ride-map-use-pickup'));
      await tester.ensureVisible(pickup);
      await tester.tap(pickup);
      await tester.pumpAndSettle();
      pending.complete(origin);
      await tester.pumpAndSettle();
      expect(bloc.state.pickup?.point, point);
      expect(bloc.state.pickup?.point, isNot(origin));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(bloc.close);
    },
  );

  testWidgets(
    '320dp and large text keep the entry action reachable by scrolling',
    (tester) async {
      phone(tester, width: 320);
      await launch(tester, LocationProbe(), scale: 2);
      await tester.pumpAndSettle();
      final action = find.byKey(const Key('ride-flow-continue'));
      await tester.ensureVisible(action);
      await tester.pumpAndSettle();
      await tester.tap(action);
      await tester.pumpAndSettle();
      expect(find.text('لوين بدك توصل؟'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
