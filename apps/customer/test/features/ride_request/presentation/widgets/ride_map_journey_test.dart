import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/core/config/map_configuration.dart';
import 'package:tam_customer/features/maps/domain/maps_repository.dart';
import 'package:tam_customer/features/maps/maps_dependencies.dart';
import 'package:tam_customer/features/maps/presentation/maps_scope.dart';
import 'package:tam_customer/features/maps/presentation/widgets/route_map_view.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/features/ride_request/presentation/pages/ride_request_page.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_journey_body.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_journey_stage.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_map_point_panel.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';

import '../../../maps/maps_test_support.dart';
import '../../scheduling/schedule_widget_support.dart';

class _Settings implements DeviceLocationSettings {
  @override
  Future<bool> openAppSettings() async => true;
  @override
  Future<bool> openLocationSettings() async => true;
}

class _BookingNavigation extends Fake implements CustomerNavigation {
  int homes = 0;
  bool replaced = false;
  @override
  void openHome() => homes++;
  @override
  void openActiveTrip({String? id, bool replaceCurrent = false}) {
    replaced = replaceCurrent;
  }
}

void main() {
  Future<RideDraftBloc> launch(
    WidgetTester tester,
    LocationProbe gps, {
    double scale = 1,
    CustomerNavigation? navigation,
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
            child: RideRequestPage(
              navigation: navigation ?? const ScheduleTestNavigation(),
            ),
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
    'map confirmation updates the existing journey without an intermediate empty point',
    (tester) async {
      phone(tester);
      final bloc = await launch(tester, LocationProbe());
      await tester.pumpAndSettle();
      final mapState = tester.state(find.byType(FlutterMap));
      tester
          .widget<RideJourneyBody>(find.byType(RideJourneyBody))
          .onMapPoint(destination);
      await tester.pumpAndSettle();
      final panel = tester.widget<RideMapPointPanel>(
        find.byType(RideMapPointPanel),
      );
      final camera = tester
          .widget<FlutterMap>(find.byType(FlutterMap))
          .mapController!
          .camera;
      final center = camera.center, zoom = camera.zoom;
      panel.onDestination(
        TripLocation(point: destination, label: 'بوابة الحديقة'),
      );
      for (final duration in [
        Duration.zero,
        const Duration(milliseconds: 60),
        const Duration(milliseconds: 300),
      ]) {
        await tester.pump(duration);
        final journey = tester.widget<RideJourneyBody>(
          find.byType(RideJourneyBody),
        );
        if (journey.location.point == null) {
          expect(journey.draft.destination?.point, destination);
        }
        expect(tester.state(find.byType(FlutterMap)), same(mapState));
        final currentCamera = tester
            .widget<FlutterMap>(find.byType(FlutterMap))
            .mapController!
            .camera;
        expect(currentCamera.center, center);
        expect(currentCamera.zoom, zoom);
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();
      expect(bloc.state.destination?.label, 'بوابة الحديقة');
      expect(
        tester.widget<RideJourneyBody>(find.byType(RideJourneyBody)).step,
        RideJourneyStep.entry,
      );
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(bloc.close);
    },
  );

  testWidgets('keyboard keeps map viewport and camera inset stable', (
    tester,
  ) async {
    phone(tester, width: 320);
    await launch(tester, LocationProbe(), scale: 2);
    await tester.pumpAndSettle();
    await tester.tap(find.text('إلى أين تريد الذهاب؟'));
    await tester.pumpAndSettle();
    final map = find.byType(FlutterMap);
    final originalState = tester.state(map);
    final originalSize = tester.getSize(map);
    await tester.enterText(find.byType(TextFormField), 'الجلاء');
    await tester.pumpAndSettle();
    final originalInset = tester
        .widget<RouteMapView>(find.byType(RouteMapView))
        .bottomInset!
        .value;
    addTearDown(tester.view.resetViewInsets);
    for (final height in [80.0, 180.0, 300.0]) {
      tester.view.viewInsets = FakeViewPadding(bottom: height);
      await tester.pumpAndSettle();
      expect(tester.state(map), same(originalState));
      expect(tester.getSize(map), originalSize);
      expect(
        tester
            .widget<RouteMapView>(find.byType(RouteMapView))
            .bottomInset!
            .value,
        originalInset,
      );
      expect(tester.takeException(), isNull);
    }
    await tester.ensureVisible(find.byType(TextFormField));
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text,
      'الجلاء',
    );
    tester.view.viewInsets = const FakeViewPadding();
    await tester.pumpAndSettle();
    expect(tester.getSize(map), originalSize);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

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
          .widget<RideMapPointPanel>(
            find.byType(RideMapPointPanel, skipOffstage: false),
          )
          .point;
      expect(find.byTooltip('طي التفاصيل وتوسيع الخريطة'), findsOneWidget);
      await tester.tap(find.byKey(const Key('ride-map-add-description')));
      await tester.pumpAndSettle();
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
          .widget<RideMapPointPanel>(
            find.byType(RideMapPointPanel, skipOffstage: false),
          )
          .point;
      await tester.tap(find.byKey(const Key('ride-map-role-pickup')));
      await tester.pump(const Duration(milliseconds: 350));
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
    'My Location reports a disabled service even with the panel collapsed',
    (tester) async {
      phone(tester);
      final gps = LocationProbe();
      final bloc = await launch(tester, gps);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('ride-sheet-toggle')));
      await tester.pumpAndSettle();
      gps.onLocate = () async => throw const MapsFailure('LOCATION_DISABLED');
      await tester.tap(find.byKey(const Key('ride-use-device-location')));
      await tester.pumpAndSettle();
      expect(find.text('تشغيل الموقع'), findsOneWidget);
      expect(find.textContaining('خدمة الموقع مغلقة'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(bloc.state.pickup?.point, origin);
      expect(gps.lastRequireFresh, isTrue);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'a denied permission is visible and retry focuses without replacing manual pickup',
    (tester) async {
      phone(tester);
      final gps = LocationProbe();
      final bloc = await launch(tester, gps);
      await tester.pumpAndSettle();
      bloc.add(
        PickupSelected(
          TripLocation(point: destination, label: 'Manual pickup'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('ride-sheet-toggle')));
      await tester.pumpAndSettle();
      gps.onLocate = () async => throw const MapsFailure('LOCATION_DENIED');
      await tester.tap(find.byKey(const Key('ride-use-device-location')));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(SnackBarAction, 'السماح بالموقع'),
        findsOneWidget,
      );
      expect(find.textContaining('لم يُسمح بالوصول للموقع'), findsOneWidget);
      gps.onLocate = () async => origin;
      await tester.tap(find.widgetWithText(SnackBarAction, 'السماح بالموقع'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<RouteMapView>(find.byType(RouteMapView)).focus?.point,
        origin,
      );
      expect(bloc.state.pickup?.point, destination);
      expect(bloc.state.pickupFromDevice, isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  Future<void> review(WidgetTester tester, RideDraftBloc bloc) async {
    bloc.add(
      DestinationSelected(
        TripLocation(label: 'Destination', point: destination),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));
    for (var i = 0; i < 1; i++) {
      final next = find.byKey(const Key('ride-flow-continue'));
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pumpAndSettle();
    }
  }

  testWidgets('back from the combined sheet returns to route planning', (
    tester,
  ) async {
    phone(tester);
    final bloc = await launch(tester, LocationProbe());
    await tester.pumpAndSettle();
    await review(tester, bloc);
    expect(find.text('حدد نوع الرحلة'), findsOneWidget);
    await tester.tap(find.byKey(const Key('ride-sheet-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ride-flow-back')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<RideJourneyBody>(find.byType(RideJourneyBody)).step,
      RideJourneyStep.entry,
    );
    expect(find.byTooltip('طي التفاصيل وتوسيع الخريطة'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(
      tester.widget<RideJourneyBody>(find.byType(RideJourneyBody)).step,
      RideJourneyStep.entry,
    );
    expect(bloc.state.confirmedTrip, isNull);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(bloc.close);
  });

  testWidgets(
    'back can leave an already confirmed draft without changing its trip',
    (tester) async {
      phone(tester);
      final navigation = _BookingNavigation();
      final bloc = await launch(
        tester,
        LocationProbe(),
        navigation: navigation,
      );
      await tester.pumpAndSettle();
      await review(tester, bloc);
      bloc.add(const RideConfirmationRequested());
      await tester.pumpAndSettle();
      final trip = bloc.state.confirmedTrip;
      expect(trip, isNotNull);
      expect(navigation.replaced, isTrue);
      await tester.tap(find.byKey(const Key('ride-flow-back')));
      await tester.pumpAndSettle();
      expect(navigation.homes, 1);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(navigation.homes, 2);
      expect(bloc.state.confirmedTrip, same(trip));
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(bloc.close);
    },
  );

  for (final moved in [false, true]) {
    testWidgets(
      moved
          ? 'movement before confirmation updates pickup and requires another review'
          : 'GPS failure before confirmation stays visible and never books',
      (tester) async {
        phone(tester);
        final gps = LocationProbe();
        final bloc = await launch(tester, gps);
        await tester.pumpAndSettle();
        await review(tester, bloc);
        final updated = GeoPoint(
          latitude: origin.latitude + .002,
          longitude: origin.longitude,
        );
        gps.onLocate = () async {
          if (!moved) throw const MapsFailure('LOCATION_INACCURATE');
          return updated;
        };
        final confirm = find.byKey(const Key('ride-flow-continue'));
        await tester.ensureVisible(confirm);
        await tester.tap(confirm);
        await tester.pumpAndSettle();
        expect(bloc.state.confirmedTrip, isNull);
        expect(bloc.state.pickup?.point, moved ? updated : origin);
        if (moved) {
          expect(
            find.text(
              'تغيّر موقع انطلاقك. حدّثنا المسار، راجع السعر والتفاصيل قبل التأكيد.',
            ),
            findsOneWidget,
          );
        } else {
          expect(find.textContaining('الموقع غير دقيق'), findsWidgets);
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.runAsync(bloc.close);
      },
    );
  }

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
      expect(find.text('إلى أين؟'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
