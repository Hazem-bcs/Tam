import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/core/config/map_configuration.dart';
import 'package:tam_customer/features/active_trip/presentation/bloc/active_trip_cubit.dart';
import 'package:tam_customer/features/maps/maps_dependencies.dart';
import 'package:tam_customer/features/maps/presentation/maps_scope.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/features/ride_request/presentation/pages/ride_request_page.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

import '../../../active_trip/active_trip_test_support.dart';
import '../../../maps/maps_test_support.dart';
import '../../scheduling/schedule_widget_support.dart';

void main() {
  for (final restoring in [false, true]) {
    testWidgets(
      restoring
          ? 'restored trip does not request a new pickup fix'
          : 'empty current lookup defaults pickup to the device location',
      (tester) async {
        final fixture = ActiveTripFixture();
        if (restoring) fixture.book();
        final gps = LocationProbe();
        final draft = RideDraftBloc(
          repository: MockRideRequestRepository(trips: fixture.store),
        );
        final active = ActiveTripCubit(
          fixture.repository,
          now: () => fixture.now,
          poll: false,
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
            home: MapsScope(
              dependencies: MapsDependencies(
                configuration: const MapConfiguration(),
                repository: MapsProbe(),
                deviceLocation: gps,
              ),
              child: MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: draft),
                  BlocProvider.value(value: active),
                ],
                child: const RideRequestPage(
                  navigation: ScheduleTestNavigation(),
                  hasActiveTracking: true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(gps.calls, restoring ? 0 : 1);
        expect(draft.state.pickup?.point, restoring ? isNull : origin);
        expect(draft.state.pickupFromDevice, !restoring);
        expect(active.state.trip != null, restoring);
        await tester.pumpWidget(const SizedBox());
        await tester.runAsync(() async {
          await draft.close();
          await active.close();
          await fixture.dispose();
        });
      },
    );
  }
}
