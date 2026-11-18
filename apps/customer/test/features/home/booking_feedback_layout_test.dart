import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_matching_pulse.dart';
import 'package:tam_customer/features/home/presentation/bloc/home_upcoming_trips_cubit.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_upcoming_trips.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_vehicle_picker.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/ride_schedule_policy.dart';

import '../../support/preview_fonts.dart';
import '../active_trip/active_trip_test_support.dart';

const capture = bool.fromEnvironment('CAPTURE_BOOKING_FEEDBACK');

Future<void> capturePreview(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('feedback-preview')),
    );
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final output = File(
      '../../docs/engineering/deliveries/CF-BOOKING/$name.png',
    );
    await output.parent.create(recursive: true);
    await output.writeAsBytes(bytes!.buffer.asUint8List());
  });
}

void main() {
  setUpAll(() => loadPreviewFonts(enabled: capture));
  for (final scenario in [
    ('ar', 320.0, 740.0, 2.0),
    ('en', 390.0, 844.0, 1.0),
    ('ar', 800.0, 1000.0, 1.0),
    ('en', 844.0, 390.0, 2.0),
  ]) {
    testWidgets(
      'upcoming ids and accessible vehicle discovery ${scenario.$1} ${scenario.$2}',
      (tester) async {
        tester.view.physicalSize = Size(scenario.$2, scenario.$3);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final fixture = ActiveTripFixture();
        final tomorrow = fixture.book(
          scheduledAt: fixture.now.add(const Duration(days: 1)),
        );
        final second = fixture.book(
          scheduledAt: fixture.now.add(const Duration(days: 2)),
        );
        final cubit = HomeUpcomingTripsCubit(fixture.repository);
        String? opened;
        RideVehicleClass? selected;
        await tester.pumpWidget(
          RepaintBoundary(
            key: const Key('feedback-preview'),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: capture ? previewTheme() : AppTheme.light,
              locale: Locale(scenario.$1),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  disableAnimations: true,
                  textScaler: TextScaler.linear(scenario.$4),
                ),
                child: child!,
              ),
              home: BlocProvider.value(
                value: cubit,
                child: Scaffold(
                  body: SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          HomeUpcomingTrips(
                            onOpen: (id) => opened = id,
                            schedulePolicy: const RideSchedulePolicy(),
                          ),
                          RideVehiclePicker(
                            showHeading: false,
                            selected: RideVehicleClass.standard,
                            enabled: true,
                            onSelected: (vehicle) => selected = vehicle,
                          ),
                          const ActiveMatchingPulse(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (capture) {
          await capturePreview(
            tester,
            'upcoming-${scenario.$1}-${scenario.$2.toInt()}-x${scenario.$4.toInt()}',
          );
        }
        final firstCard = find.byKey(ValueKey('home-upcoming-${tomorrow.id}'));
        final secondCard = find.byKey(ValueKey('home-upcoming-${second.id}'));
        expect(
          tester.getTopLeft(firstCard).dy,
          lessThan(tester.getTopLeft(secondCard).dy),
        );
        await tester.ensureVisible(secondCard);
        await tester.tap(secondCard);
        expect(opened, second.id);
        final localizations = AppLocalizations.of(
          tester.element(find.byType(HomeUpcomingTrips)),
        );
        final next = find.byTooltip(localizations.rideRequestNextVehicles);
        await tester.ensureVisible(next);
        await tester.tap(next);
        await tester.pumpAndSettle();
        final bike = find.byKey(const Key('ride-vehicle-motorbike'));
        await tester.ensureVisible(bike);
        await tester.pumpAndSettle();
        await tester.tap(bike);
        expect(selected, RideVehicleClass.motorbike);
        final pulse = find.byType(ActiveMatchingPulse);
        await tester.ensureVisible(pulse);
        await tester.pumpAndSettle();
        expect(tester.binding.transientCallbackCount, 0);
        expect(tester.takeException(), isNull);
        if (capture) {
          await capturePreview(
            tester,
            'feedback-${scenario.$1}-${scenario.$2.toInt()}-x${scenario.$4.toInt()}',
          );
        }
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.runAsync(() async {
          await cubit.close();
          await fixture.dispose();
        });
      },
    );
  }
}
