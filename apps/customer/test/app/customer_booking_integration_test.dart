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
  testWidgets('book, list, cancel and rebook use one shared trip source', (
    tester,
  ) async {
    await launchCustomerApp(tester);
    await enterCustomerSession(tester);
    final router = customerRouter(tester);
    await tester.tap(find.text('حدد نقطة الانطلاق والوجهة لطلب رحلة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حدد مكان الانطلاق'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('المزة، شارع الجلاء'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إلى أين تريد الذهاب؟'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('أبو رمانة، شارع الحمراء'));
    await tester.pumpAndSettle();
    final draft = tester
        .element(find.byType(RideRequestPage))
        .read<RideDraftBloc>();
    expect(draft.state.quote, isNotNull);
    final confirm = find.text('تأكيد طلب الرحلة');
    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    await openBookedTripDetails(tester);
    final details = tester
        .element(find.byType(TripDetailsPage))
        .read<TripDetailsCubit>();
    final booked = details.state.trip!;
    expect(booked.id, startsWith('mock-trip-'));
    expect(booked.status, TripStatus.requested);

    router.push(AppRoutes.trips);
    await tester.pumpAndSettle();
    final trips = tester
        .element(find.byType(TripsListPage))
        .read<TripsListCubit>();
    expect(trips.state.items.where((t) => t.id == booked.id).length, 1);
    router.pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('إلغاء الرحلة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تأكيد الإلغاء'));
    await tester.pumpAndSettle();
    expect(details.state.trip!.status, TripStatus.cancelled);
    await dismissCustomerMessages(tester);
    await tester.tap(find.text('اطلب مجددًا'));
    await tester.pumpAndSettle();
    final rebook = tester
        .element(find.byType(RideRequestPage).last)
        .read<RideDraftBloc>();
    expect(rebook.state.pickup, booked.booking.pickup);
    expect(rebook.state.destination, booked.booking.destination);
    expect(rebook.state.confirmedTrip, isNull);
    expect(rebook.state.quote, isNotNull);

    await showCustomerHome(tester, router);
    await customerAuth(tester).logout();
    await tester.pumpAndSettle();
    await enterCustomerSession(tester);
    router.go(AppRoutes.trips);
    await tester.pumpAndSettle();
    final afterLogout = tester
        .element(find.byType(TripsListPage))
        .read<TripsListCubit>()
        .state
        .items;
    expect(afterLogout.map((trip) => trip.id).toSet(), {
      'mock-history-001',
      'mock-history-002',
    });
    expect(afterLogout.any((trip) => trip.id == booked.id), false);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
