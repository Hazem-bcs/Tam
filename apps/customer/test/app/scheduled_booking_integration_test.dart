import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/features/ride_request/presentation/pages/ride_request_page.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trip_details_cubit.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trips_list_cubit.dart';
import 'package:tam_customer/features/trips/presentation/pages/trip_details_page.dart';
import 'package:tam_customer/features/trips/presentation/pages/trips_list_page.dart';
import 'package:tam_customer/shared/domain/trip.dart';

import 'support/customer_app_harness.dart';

void main() {
  testWidgets(
    'schedule with saved addresses, list, cancel, rebook and logout',
    (tester) async {
      await launchCustomerApp(tester);
      await enterCustomerSession(tester);
      final router = customerRouter(tester);
      await tester.tap(find.text('حدد نقطة الانطلاق والوجهة لطلب رحلة'));
      await tester.pumpAndSettle();
      for (final item in [
        ('حدد مكان الانطلاق', 'saved-address-address-home-001'),
        ('إلى أين تريد الذهاب؟', 'saved-address-address-work-001'),
      ]) {
        await tester.tap(find.text(item.$1));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('ride-saved-addresses')));
        await tester.pumpAndSettle();
        final address = find.byKey(Key(item.$2));
        await tester.ensureVisible(address);
        await tester.tap(address);
        await tester.pumpAndSettle();
      }
      final scheduled = find.byKey(const Key('ride-scheduled'));
      await tester.ensureVisible(scheduled);
      await tester.tap(scheduled);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('schedule-confirm')));
      await tester.pumpAndSettle();
      final bloc = tester
          .element(find.byType(RideRequestPage))
          .read<RideDraftBloc>();
      expect(bloc.state.scheduledAt, isNotNull);
      expect(bloc.state.quote!.scheduledAt, bloc.state.scheduledAt);
      await tester.tap(find.text('تأكيد طلب الرحلة'));
      await tester.pumpAndSettle();
      await openBookedTripDetails(tester);
      final details = tester
          .element(find.byType(TripDetailsPage))
          .read<TripDetailsCubit>();
      final trip = details.state.trip!;
      expect(trip.status, TripStatus.scheduled);
      expect(trip.booking.scheduledAt, isNotNull);
      expect(find.text('موعد الرحلة'), findsOneWidget);
      router.push(AppRoutes.trips);
      await tester.pumpAndSettle();
      final list = tester
          .element(find.byType(TripsListPage))
          .read<TripsListCubit>();
      expect(list.state.items.where((t) => t.id == trip.id).single, trip);
      expect(find.text('مجدولة'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
      await tester.tap(find.text('إلغاء الرحلة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('تأكيد الإلغاء'));
      await tester.pumpAndSettle();
      expect(details.state.trip!.booking.scheduledAt, trip.booking.scheduledAt);
      await dismissCustomerMessages(tester);
      await tester.tap(find.text('اطلب مجددًا'));
      await tester.pumpAndSettle();
      final rebook = tester
          .element(find.byType(RideRequestPage).last)
          .read<RideDraftBloc>();
      expect(rebook.state.scheduledAt, isNull);
      expect(rebook.state.quote!.scheduledAt, isNull);
      expect(rebook.state.pickup, trip.booking.pickup);
      await showCustomerHome(tester, router);
      await customerAuth(tester).logout();
      await tester.pumpAndSettle();
      await enterCustomerSession(tester, phone: null);
      router.go(AppRoutes.trips);
      await tester.pumpAndSettle();
      final after = tester
          .element(find.byType(TripsListPage))
          .read<TripsListCubit>();
      expect(after.state.items.any((item) => item.id == trip.id), isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    },
  );
}
