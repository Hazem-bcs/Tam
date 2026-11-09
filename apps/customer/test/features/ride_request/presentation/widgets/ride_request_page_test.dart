import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_places.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/features/ride_request/presentation/pages/ride_request_page.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/trip.dart';

final class _Nav implements CustomerNavigation {
  String? openedTrip;
  @override
  void openActiveTrip({String? id}) => openedTrip = id;
  @override
  void openHome() {}
  @override
  void openRideRequest({TripPrefill? prefill}) {}
  @override
  void openTrips() {}
  @override
  void openTrip(String id) => openedTrip = id;
  @override
  void openNotifications() {}
  @override
  void openAddresses() {}
  @override
  void openSettings() {}
}

void main() {
  setUpAll(() async {
    // Widget-test snapshots run without the host's system font fallback.
    // Load a local test font when present; no production font is bundled.
    final demoFonts = <String, String>{
      'Roboto': '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
      'MaterialIcons': 'build/unit_test_assets/fonts/MaterialIcons-Regular.otf',
    };
    for (final entry in demoFonts.entries) {
      final file = File(entry.value);
      if (file.existsSync()) {
        final loader = FontLoader(entry.key)
          ..addFont(file.readAsBytes().then(ByteData.sublistView));
        await loader.load();
      }
    }
  });

  Future<(MockTripStore, RideDraftBloc, _Nav)> pumpRide(
    WidgetTester tester, {
    required Locale locale,
    TripPrefill? prefill,
    double textScale = 1,
  }) async {
    final store = MockTripStore();
    final bloc = RideDraftBloc(
      repository: MockRideRequestRepository(trips: store),
      prefill: prefill,
    );
    final navigation = _Nav();
    addTearDown(store.dispose);
    await tester.pumpWidget(
      RepaintBoundary(
        key: const Key('ride-screenshot'),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          theme: AppTheme.light,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: BlocProvider.value(
                value: bloc,
                child: RideRequestPage(navigation: navigation),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return (store, bloc, navigation);
  }

  void setSize(WidgetTester tester, double width, double height) {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Future<void> screenshot(WidgetTester tester, String filename) async {
    if (!const bool.fromEnvironment('CAPTURE_RIDE_GOLDENS')) return;
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const Key('ride-screenshot')),
      );
      final picture = await boundary.toImage(pixelRatio: 1);
      final bytes = await picture.toByteData(format: ui.ImageByteFormat.png);
      picture.dispose();
      final path = '../../docs/engineering/deliveries/W1-RIDE/$filename';
      await File(path).writeAsBytes(bytes!.buffer.asUint8List(), flush: true);
    });
  }

  testWidgets('Arabic 390: pick both places, show quote and open saved trip', (
    tester,
  ) async {
    setSize(tester, 390, 844);
    final (store, bloc, nav) = await pumpRide(
      tester,
      locale: const Locale('ar'),
    );
    await tester.tap(find.text('حدد مكان الانطلاق'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('المزة، شارع الجلاء').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('إلى أين تريد الذهاب؟'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('أبو رمانة، شارع الحمراء').last);
    await tester.pumpAndSettle();
    expect(bloc.state.quote?.fare.amountMinor, 27000);
    await screenshot(tester, 'ride-ar-390.png');
    await tester.drag(find.byType(ListView).first, const Offset(0, -700));
    await tester.pumpAndSettle();
    await screenshot(tester, 'ride-ar-390-details.png');
    await tester.tap(find.text('تأكيد طلب الرحلة'));
    await tester.pumpAndSettle();
    expect(nav.openedTrip, isNotNull);
    expect(store.find(nav.openedTrip!), isNotNull);
    expect(store.trips, hasLength(1));
    expect(tester.takeException(), isNull);
    unawaited(bloc.close());
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('English 390: prefill and quote in LTR', (tester) async {
    setSize(tester, 390, 844);
    final (store, bloc, nav) = await pumpRide(
      tester,
      locale: const Locale('en'),
      prefill: TripPrefill(
        pickup: mockRidePlaces[0].location,
        destination: mockRidePlaces[1].location,
      ),
    );
    await tester.pumpAndSettle();
    expect(bloc.state.quote, isNotNull);
    await tester.drag(find.byType(ListView).first, const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Cash'), findsOneWidget);
    await screenshot(tester, 'ride-en-390.png');
    expect(tester.takeException(), isNull);
    expect(store.trips, isEmpty);
    expect(nav.openedTrip, isNull);
    unawaited(bloc.close());
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Tablet 800: responsive quote and classes', (tester) async {
    setSize(tester, 800, 1000);
    final (_, bloc, _) = await pumpRide(
      tester,
      locale: const Locale('ar'),
      prefill: TripPrefill(
        pickup: mockRidePlaces[0].location,
        destination: mockRidePlaces[1].location,
      ),
    );
    await tester.pumpAndSettle();
    expect(bloc.state.quote, isNotNull);
    expect(find.text('عادية'), findsOneWidget);
    await screenshot(tester, 'ride-ar-800.png');
    expect(tester.takeException(), isNull);
    unawaited(bloc.close());
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Small 320, 2x text, keyboard and place search', (tester) async {
    setSize(tester, 320, 740);
    final (_, bloc, _) = await pumpRide(
      tester,
      locale: const Locale('en'),
      textScale: 2,
    );
    await screenshot(tester, 'ride-en-320-scale2.png');
    await tester.tap(find.text('Choose pickup'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Citadel');
    await tester.pumpAndSettle();
    expect(find.text('Aleppo Citadel'), findsOneWidget);
    await tester.tap(find.text('Aleppo Citadel'));
    await tester.pumpAndSettle();
    expect(find.text('Aleppo Citadel'), findsOneWidget);
    expect(tester.takeException(), isNull);
    unawaited(bloc.close());
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
