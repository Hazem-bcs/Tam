import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_state.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_journey_progress.dart';
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
      locale: const Locale('ar'),
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
            body: SafeArea(child: RideJourneyProgress(state: state)),
          ),
        ),
      ),
    );
  }

  testWidgets('advances with domain state, not artificial UI timers', (
    tester,
  ) async {
    await tester.pumpWidget(harness(const RideDraftState()));
    await tester.pumpAndSettle();
    expect(find.text('نقطة الانطلاق'), findsOneWidget);
    expect(find.text('1/4'), findsOneWidget);
    expect(find.byKey(const Key('ride-stage-progress')), findsOneWidget);

    await tester.pumpWidget(harness(RideDraftState(pickup: pickup)));
    await tester.pumpAndSettle();
    expect(find.text('الوجهة'), findsOneWidget);
    expect(find.text('2/4'), findsOneWidget);

    await tester.pumpWidget(
      harness(RideDraftState(pickup: pickup, destination: destination)),
    );
    await tester.pumpAndSettle();
    expect(find.text('حدد نوع الرحلة'), findsOneWidget);
    expect(find.text('3/4'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion disables progress transitions', (tester) async {
    await tester.pumpWidget(
      harness(RideDraftState(pickup: pickup), reduceMotion: true),
    );
    final segment = tester.widget<AnimatedContainer>(
      find.byKey(const Key('ride-progress-segment-0')),
    );
    expect(segment.duration, Duration.zero);
    expect(tester.takeException(), isNull);
  });
}
