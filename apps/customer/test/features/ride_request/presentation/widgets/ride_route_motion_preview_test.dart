import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_state.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_route_motion_preview.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';

void main() {
  final pickup = TripLocation(
    label: 'Pickup place',
    point: GeoPoint(latitude: 36.20, longitude: 37.12),
  );
  final destination = TripLocation(
    label: 'Destination place',
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

  testWidgets('unconfigured maps show truthful pickup/destination summary', (
    tester,
  ) async {
    await tester.pumpWidget(harness(const RideDraftState()));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ride-map-fallback')), findsOneWidget);
    expect(find.text('Pickup place'), findsNothing);

    await tester.pumpWidget(harness(RideDraftState(pickup: pickup)));
    await tester.pumpAndSettle();
    expect(find.text('Pickup place'), findsOneWidget);

    await tester.pumpWidget(
      harness(RideDraftState(pickup: pickup, destination: destination)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Destination place'), findsOneWidget);
    expect(find.byKey(const Key('ride-map-fallback')), findsOneWidget);
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
