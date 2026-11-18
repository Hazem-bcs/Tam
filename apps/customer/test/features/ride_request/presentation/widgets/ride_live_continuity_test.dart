import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/active_trip/presentation/bloc/active_trip_cubit.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_journey_panel.dart';
import 'package:tam_customer/features/maps/presentation/widgets/route_map_view.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/features/ride_request/presentation/pages/ride_request_page.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_journey_body.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';

import '../../../../support/preview_fonts.dart';
import '../../../active_trip/active_trip_test_support.dart';

class ContinuityNavigation extends Fake implements CustomerNavigation {
  int activeNavigations = 0;
  @override
  void openActiveTrip({String? id, bool replaceCurrent = false}) {
    activeNavigations++;
  }
}

const captureJourney = bool.fromEnvironment('CAPTURE_RIDE_JOURNEY_UI');
Future<void> capture(WidgetTester tester, String name) async {
  if (!captureJourney) return;
  final context = tester.element(find.byKey(const Key('journey-preview')));
  final images = tester
      .widgetList<Image>(find.byType(Image))
      .map((widget) => widget.image)
      .toList();
  await tester.runAsync(
    () =>
        Future.wait(images.map((provider) => precacheImage(provider, context))),
  );
  await tester.pump();
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('journey-preview')),
    );
    final picture = await boundary.toImage();
    final bytes = await picture.toByteData(format: ui.ImageByteFormat.png);
    picture.dispose();
    final file = File(
      '../../docs/ahmad-ui/deliveries/AUI-09-RIDE-JOURNEY-20261118/$name.png',
    );
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
  });
}

void main() {
  setUpAll(() async {
    await loadPreviewFonts(enabled: captureJourney);
    if (!captureJourney) return;
    for (final family in {
      'TamSansArabic': 'NotoSansArabic',
      'TamSansLatin': 'NotoSans',
    }.entries) {
      final loader = FontLoader(family.key);
      for (final weight in ['Regular', 'Bold']) {
        loader.addFont(
          File(
            'assets/fonts/${family.value}-$weight.ttf',
          ).readAsBytes().then(ByteData.sublistView),
        );
      }
      await loader.load();
    }
  });
  for (final scenario in [
    (390.0, 844.0, 1.0, 'ar'),
    (320.0, 740.0, 2.0, 'ar'),
    (800.0, 1000.0, 1.0, 'en'),
    (844.0, 390.0, 1.0, 'en'),
  ]) {
    testWidgets(
      'booking through all live phases retains map ${scenario.$1} ${scenario.$3}',
      (tester) async {
        tester.view.physicalSize = Size(scenario.$1, scenario.$2);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final fixture = ActiveTripFixture();
        final seed = fixture.book();
        fixture.store.clear();
        final navigation = ContinuityNavigation();
        final draft = RideDraftBloc(
          repository: MockRideRequestRepository(
            trips: fixture.store,
            now: () => fixture.now,
          ),
          now: () => fixture.now,
          prefill: TripPrefill(
            pickup: seed.booking.pickup,
            destination: seed.booking.destination,
          ),
        );
        final active = ActiveTripCubit(
          fixture.repository,
          now: () => fixture.now,
          poll: false,
        );
        await tester.pumpWidget(
          RepaintBoundary(
            key: const Key('journey-preview'),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              locale: Locale(scenario.$4),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  disableAnimations: true,
                  textScaler: TextScaler.linear(scenario.$3),
                ),
                child: child!,
              ),
              home: MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: draft),
                  BlocProvider.value(value: active),
                ],
                child: RideRequestPage(
                  navigation: navigation,
                  hasActiveTracking: true,
                  simulatedTracking: true,
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        final map = tester.state(find.byType(RouteMapView));
        expect(active.state.phase, ActiveTripPhase.empty);
        await capture(
          tester,
          'selection-${scenario.$1}-${scenario.$3}-${scenario.$4}',
        );
        draft.add(const RideConfirmationRequested());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(active.state.trip?.status, TripStatus.requested);
        expect(find.byType(ActiveJourneyPanel), findsOneWidget);
        expect(tester.state(find.byType(RouteMapView)), same(map));
        expect(navigation.activeNavigations, 0);
        await capture(
          tester,
          'matching-${scenario.$1}-${scenario.$3}-${scenario.$4}',
        );
        for (final phase in [
          (2, TripStatus.confirmed),
          (1, TripStatus.driverEnRoute),
          (4, TripStatus.driverArrived),
          (2, TripStatus.inProgress),
          (5, TripStatus.completed),
        ]) {
          fixture.advance(phase.$1);
          await active.refresh();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          expect(active.state.trip?.status, phase.$2);
          expect(tester.state(find.byType(RouteMapView)), same(map));
          expect(find.byType(RouteMapView), findsOneWidget);
          expect(
            tester
                .widget<RideJourneyBody>(find.byType(RideJourneyBody))
                .active
                ?.trip
                ?.status,
            phase.$2,
          );
          expect(tester.takeException(), isNull);
          if (phase.$2 == TripStatus.inProgress) {
            await capture(
              tester,
              'in-progress-${scenario.$1}-${scenario.$3}-${scenario.$4}',
            );
          }
        }
        expect(fixture.store.trips, hasLength(1));
        await tester.pumpWidget(const SizedBox());
        await tester.runAsync(() async {
          await active.close();
          await draft.close();
          await fixture.dispose();
        });
      },
    );
  }
}
