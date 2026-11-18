import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/active_trip/presentation/widgets/active_driver_details_sheet.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';
import 'package:tam_customer/shared/widgets/tam_vehicle_icon.dart';

void main() {
  Future<void> openSheet(
    WidgetTester tester, {
    bool demo = false,
    String? url,
  }) async {
    final driver = TripDriver(
      id: '1',
      name: 'محمد',
      nameEn: 'Mohammad',
      vehicle: 'كيا',
      vehicleEn: 'Kia',
      plate: '123',
      rating: 4.9,
      vehicleImageUrl: url,
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showActiveDriverDetailsSheet(
                context,
                driver: driver,
                showDemoAvatar: demo,
                onChat: () {},
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('mock driver displays demo car; absent real image shows icon', (
    tester,
  ) async {
    await openSheet(tester, demo: true);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName ==
                'assets/images/ahmad_ui/driver_car_demo.png',
      ),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await openSheet(tester);
    expect(find.byType(TamVehicleIcon), findsOneWidget);
  });

  testWidgets('a failed driver car image falls back to the icon', (
    tester,
  ) async {
    await openSheet(tester, url: 'https://example.invalid/car.png');
    await tester.pumpAndSettle();
    expect(find.byType(TamVehicleIcon), findsOneWidget);
  });
}
