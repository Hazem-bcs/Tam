import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/app.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/features/active_trip/presentation/bloc/active_trip_cubit.dart';
import 'package:tam_customer/features/active_trip/presentation/pages/active_trip_page.dart';
import 'package:tam_customer/features/auth/data/memory_auth_session_store.dart';
import 'package:tam_customer/features/home/presentation/pages/home_page.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/features/ride_request/presentation/pages/ride_request_page.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trip_details_cubit.dart';
import 'package:tam_customer/features/trips/presentation/pages/trip_details_page.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import '../support/fake_auth_repository.dart';
import 'support/customer_app_harness.dart';

void main() {
  testWidgets(
    'booking opens tracking, Home restores it, history cancellation stays in sync',
    (tester) async {
      var now = DateTime.now().toUtc();
      await launchCustomerApp(tester, clock: () => now);
      await enterCustomerSession(tester);
      final router = customerRouter(tester);
      router.push(AppRoutes.rideRequest);
      await tester.pumpAndSettle();
      for (final item in [
        ('حدد مكان الانطلاق', 'المزة، شارع الجلاء'),
        ('إلى أين تريد الذهاب؟', 'أبو رمانة، شارع الحمراء'),
      ]) {
        await tester.tap(find.text(item.$1));
        await tester.pumpAndSettle();
        await tester.tap(find.text(item.$2).last);
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('تأكيد طلب الرحلة'));
      await tester.pumpAndSettle();
      expect(find.byType(ActiveTripPage), findsOneWidget);
      final tracker = tester
          .element(find.byType(ActiveTripPage))
          .read<ActiveTripCubit>();
      final id = tracker.state.trip!.id;
      expect(tracker.state.trip!.status, TripStatus.requested);
      await showCustomerHome(tester, router);
      now = now.add(const Duration(seconds: 18));
      await tester.pump(const Duration(seconds: 18));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('home-active-trip')));
      await tester.pumpAndSettle();
      final restored = tester
          .element(find.byType(ActiveTripPage))
          .read<ActiveTripCubit>();
      expect(restored.state.trip!.id, id);
      expect(restored.state.trip!.status, TripStatus.driverEnRoute);
      await openBookedTripDetails(tester);
      final details = tester
          .element(find.byType(TripDetailsPage))
          .read<TripDetailsCubit>();
      expect(details.state.trip!.id, id);
      await tester.tap(find.text('إلغاء الرحلة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('تأكيد الإلغاء'));
      await tester.pumpAndSettle();
      router.pop();
      await tester.pumpAndSettle();
      expect(restored.state.trip!.status, TripStatus.cancelled);
      final rebook = find.byKey(const Key('active-rebook'));
      await revealPageWidget(tester, rebook);
      await tester.ensureVisible(rebook);
      await tester.pumpAndSettle();
      await tester.tap(rebook);
      await tester.pumpAndSettle();
      final draft = tester
          .element(find.byType(RideRequestPage).last)
          .read<RideDraftBloc>();
      expect(draft.state.confirmedTrip, isNull);
      expect(draft.state.quote, isNotNull);
      expect(draft.state.scheduledAt, isNull);
      await showCustomerHome(tester, router);
      await customerAuth(tester).logout();
      await tester.pumpAndSettle();
      await enterCustomerSession(tester, phone: null);
      router.go(AppRoutes.activeTrip);
      await tester.pumpAndSettle();
      final next = tester
          .element(find.byType(ActiveTripPage))
          .read<ActiveTripCubit>();
      expect(next.state.phase, ActiveTripPhase.empty);
      router.go(AppRoutes.activeTripLocation(id));
      await tester.pumpAndSettle();
      expect(
        tester
            .element(find.byType(ActiveTripPage))
            .read<ActiveTripCubit>()
            .state
            .trip,
        isNull,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    },
  );
  for (final guest in [true, false]) {
    testWidgets(
      'API live routes reject ${guest ? 'guest' : 'localAccess'} even with mock history',
      (tester) async {
        await tester.pumpWidget(
          TamApp(
            authRepository: FakeAuthRepository(latency: Duration.zero),
            sessionStore: MemoryAuthSessionStore(),
            temporaryPhoneEntryEnabled: true,
            dataModes: const FeatureDataModes(
              overrides: {CustomerFeature.activeTrip: FeatureDataMode.api},
            ),
          ),
        );
        await tester.pumpAndSettle();
        await enterCustomerSession(tester, phone: guest ? null : '0941234567');
        final router = customerRouter(tester);
        for (final path in [
          AppRoutes.activeTrip,
          AppRoutes.activeTripLocation('mock-trip-1'),
        ]) {
          router.go(path);
          await tester.pumpAndSettle();
          expect(find.byType(ActiveTripPage), findsNothing);
          expect(find.byType(HomePage), findsOneWidget);
        }
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
