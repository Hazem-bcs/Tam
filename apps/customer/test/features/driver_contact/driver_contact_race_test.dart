import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/active_trip/data/mock/mock_active_trip_repository.dart';
import 'package:tam_customer/features/driver_contact/data/mock/mock_driver_contact_repository.dart';
import 'package:tam_customer/features/driver_contact/domain/driver_contact_repository.dart';
import 'package:tam_customer/features/driver_contact/presentation/bloc/driver_contact_cubit.dart';
import 'package:tam_customer/features/driver_contact/presentation/pages/driver_contact_page.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/data/mock/seed_trips.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';
import 'driver_contact_test_support.dart';

void main() {
  for (final change in ['cancel', 'driver', 'progress']) {
    test(
      '$change before fetch continuation respects current contact binding',
      () async {
        var time = contactNow;
        final trips = MockTripStore(now: () => time);
        final engine = MockActiveTripRepository(trips, now: () => time);
        final repository = MockDriverContactRepository(trips, now: () => time);
        final dialer = DialerProbe();
        final trip = trips.create(
          seedMockTrips().first.booking,
          idempotencyKey: 'book',
        );
        time = time.add(const Duration(seconds: 17));
        engine.advance();
        final current = trips.find(trip.id)!;
        final c = DriverContactCubit(
          repository,
          dialer,
          tripId: trip.id,
          driverId: current.live!.driver!.id,
          now: () => time,
        );
        addTearDown(c.close);
        addTearDown(repository.dispose);
        addTearDown(engine.dispose);
        addTearDown(trips.dispose);
        final calling = c.call();
        if (change == 'cancel') {
          trips.cancel(trip.id);
        } else if (change == 'driver') {
          final old = current.live!;
          trips.updateLive(
            current.withLive(
              current.status,
              TripLiveDetails(
                revision: old.revision + 1,
                updatedAt: old.updatedAt,
                statusChangedAt: old.statusChangedAt,
                driver: const TripDriver(
                  id: 'replacement',
                  name: 'سائق',
                  nameEn: 'Driver',
                  vehicle: 'سيارة',
                  vehicleEn: 'Car',
                  plate: '000',
                  rating: 4,
                ),
              ),
            ),
            expectedRevision: old.revision,
          );
        } else {
          time = time.add(const Duration(seconds: 5));
          engine.advance();
        }
        await calling;
        expect(dialer.calls, change == 'progress' ? 1 : 0);
      },
    );
  }
  testWidgets('covering the contact route prevents a delayed dialer launch', (
    tester,
  ) async {
    final repository = ContactProbe();
    final dialer = DialerProbe();
    final reply = Completer<DriverContact>();
    repository.onFetch = () => reply.future;
    final cubit = DriverContactCubit(
      repository,
      dialer,
      tripId: 'trip',
      driverId: 'driver',
      now: () => contactNow,
    );
    addTearDown(cubit.close);
    addTearDown(repository.events.close);
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: nav,
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: BlocProvider.value(
          value: cubit,
          child: DriverContactPage(onBack: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('driver-contact-call')));
    await tester.pump();
    nav.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Another page')),
      ),
    );
    await tester.pumpAndSettle();
    reply.complete(
      DriverContact(
        tripId: 'trip',
        driverId: 'driver',
        phoneE164: '+963900000000',
        expiresAt: contactNow.add(const Duration(minutes: 2)),
      ),
    );
    await tester.pumpAndSettle();
    expect(dialer.calls, 0);
    nav.currentState!.pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('driver-contact-call')));
    await tester.pumpAndSettle();
    expect(dialer.calls, 1);
    await tester.pumpWidget(const SizedBox());
  });
}
