import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_vehicle_picker.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

void main() {
  for (final language in ['ar', 'en']) {
    testWidgets('vehicle arrows follow visible scroll direction in $language', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          locale: Locale(language),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: RideVehiclePicker(
              selected: RideVehicleClass.standard,
              enabled: true,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final t = AppLocalizations.of(
        tester.element(find.byType(RideVehiclePicker)),
      );
      final next = find.byTooltip(t.rideRequestNextVehicles);
      final previous = find.byTooltip(t.rideRequestPreviousVehicles);
      final icon = tester.widget<Icon>(
        find.descendant(of: next, matching: find.byType(Icon)),
      );
      expect(
        icon.icon,
        Icons.chevron_right,
      ); // Mirrors once automatically in Arabic.
      final first = find.byKey(const Key('ride-vehicle-standard'));
      final start = tester.getCenter(first).dx;
      await tester.tap(next);
      await tester.pumpAndSettle();
      final moved = tester.getCenter(first).dx;
      expect(language == 'ar' ? moved > start : moved < start, isTrue);
      await tester.tap(previous);
      await tester.pumpAndSettle();
      expect(tester.getCenter(first).dx, closeTo(start, .1));
      await tester.pumpWidget(const SizedBox());
    });
  }
}
