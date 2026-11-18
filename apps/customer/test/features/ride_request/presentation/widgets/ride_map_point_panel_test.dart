import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_map_point_panel.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';

void main() {
  for (final pickup in [true, false]) {
    testWidgets('map confirmation uses the edited endpoint: pickup=$pickup', (
      tester,
    ) async {
      TripLocation? chosenPickup, chosenDestination;
      final point = GeoPoint(latitude: 33.5, longitude: 36.3);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: RideMapPointPanel(
              point: point,
              address: 'عنوان مختار',
              resolving: false,
              initialPickup: pickup,
              onPickup: (value) => chosenPickup = value,
              onDestination: (value) => chosenDestination = value,
              onClose: () {},
            ),
          ),
        ),
      );
      expect(find.byKey(const Key('ride-map-role-pickup')), findsNothing);
      expect(find.byKey(const Key('ride-map-role-destination')), findsNothing);
      expect(find.byKey(const Key('ride-map-add-description')), findsOneWidget);
      await tester.tap(
        find.byKey(
          Key(pickup ? 'ride-map-use-pickup' : 'ride-map-use-destination'),
        ),
      );
      expect((pickup ? chosenPickup : chosenDestination)?.point, point);
      expect((pickup ? chosenDestination : chosenPickup), isNull);
    });
  }
}
