import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/maps/presentation/widgets/route_map_view.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_state.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_route_motion_preview.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';

void main() {
  final pickup = TripLocation(
    label: 'Pickup',
    point: GeoPoint(latitude: 36.20, longitude: 37.12),
  );
  final destination = TripLocation(
    label: 'Destination',
    point: GeoPoint(latitude: 36.22, longitude: 37.15),
  );

  Widget harness(RideDraftState state, {bool reduceMotion = false}) {
    return MaterialApp(
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
          ).copyWith(disableAnimations: reduceMotion),
          child: Scaffold(
            body: SafeArea(child: RideRouteMotionPreview(state: state)),
          ),
        ),
      ),
    );
  }

  testWidgets('map preview grows only when an actual route is selected', (
    tester,
  ) async {
    await tester.pumpWidget(harness(const RideDraftState()));
    await tester.pumpAndSettle();
    expect(tester.widget<RouteMapView>(find.byType(RouteMapView)).height, 184);

    await tester.pumpWidget(harness(RideDraftState(pickup: pickup)));
    await tester.pumpAndSettle();
    expect(tester.widget<RouteMapView>(find.byType(RouteMapView)).height, 184);

    await tester.pumpWidget(
      harness(RideDraftState(pickup: pickup, destination: destination)),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<RouteMapView>(find.byType(RouteMapView)).height, 248);
    expect(tester.takeException(), isNull);
  });

  testWidgets('respects the disable animations device preference', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(const RideDraftState(), reduceMotion: true),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<AnimatedSize>(find.byKey(const Key('ride-motion-map')))
          .duration,
      Duration.zero,
    );
    expect(tester.takeException(), isNull);
  });
}
