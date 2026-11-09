import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/active_trip/data/mock/mock_active_trip_repository.dart';
import 'package:tam_customer/features/driver_contact/data/driver_phone_dialer.dart';
import 'package:tam_customer/features/driver_contact/data/mock/mock_driver_contact_repository.dart';
import 'package:tam_customer/features/driver_contact/domain/driver_contact_repository.dart';
import 'package:tam_customer/features/driver_contact/presentation/bloc/driver_contact_cubit.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/data/mock/seed_trips.dart';

import 'driver_contact_test_support.dart';

void main() {
  test(
    'mock uses shared assignment and disallows cancelled, unknown and foreign driver',
    () async {
      var time = contactNow;
      final trips = MockTripStore(now: () => time);
      final engine = MockActiveTripRepository(trips, now: () => time);
      final r = MockDriverContactRepository(trips, now: () => time);
      addTearDown(r.dispose);
      addTearDown(engine.dispose);
      addTearDown(trips.dispose);
      final trip = trips.create(
        seedMockTrips().first.booking,
        idempotencyKey: 'book',
      );
      await expectLater(
        r.fetch(tripId: trip.id, driverId: 'unknown'),
        throwsA(isA<DriverContactFailure>()),
      );
      time = time.add(const Duration(seconds: 17));
      engine.advance();
      final driver = trips.find(trip.id)!.live!.driver!.id;
      expect(
        (await r.fetch(tripId: trip.id, driverId: driver)).driverId,
        driver,
      );
      await expectLater(
        r.fetch(tripId: trip.id, driverId: 'foreign'),
        throwsA(
          isA<DriverContactFailure>().having(
            (e) => e.code,
            'code',
            'DRIVER_CHANGED',
          ),
        ),
      );
      trips.cancel(trip.id);
      await expectLater(
        r.fetch(tripId: trip.id, driverId: driver),
        throwsA(
          isA<DriverContactFailure>().having(
            (e) => e.code,
            'code',
            'CONTACT_UNAVAILABLE',
          ),
        ),
      );
      expect(
        await const MockPhoneDialer().open('+963900000000'),
        DialerResult.simulated,
      );
    },
  );
  for (final invalid in ['trip', 'driver', 'number', 'expired']) {
    test('invalid $invalid never opens a dialer', () async {
      final r = ContactProbe();
      final d = DialerProbe();
      final c = DriverContactCubit(
        r,
        d,
        tripId: 'trip',
        driverId: 'driver',
        now: () => contactNow,
      );
      addTearDown(c.close);
      addTearDown(r.events.close);
      r.onFetch = () async => DriverContact(
        tripId: invalid == 'trip' ? 'foreign' : 'trip',
        driverId: invalid == 'driver' ? 'foreign' : 'driver',
        phoneE164: invalid == 'number' ? 'tel:javascript:bad' : '+963900000000',
        expiresAt: invalid == 'expired'
            ? contactNow
            : contactNow.add(const Duration(minutes: 2)),
      );
      await c.call();
      expect(d.calls, 0);
      expect(c.state.failure, 'INVALID_RESPONSE');
    });
  }
  for (final boundary in ['reset', 'background', 'close']) {
    test(
      'late contact after $boundary cannot launch, duplicate request blocked',
      () async {
        final r = ContactProbe();
        final d = DialerProbe();
        final c = DriverContactCubit(
          r,
          d,
          tripId: 'trip',
          driverId: 'driver',
          now: () => contactNow,
        );
        addTearDown(r.events.close);
        final reply = Completer<DriverContact>();
        var reads = 0;
        r.onFetch = () {
          reads++;
          return reply.future;
        };
        final pending = c.call();
        await c.call();
        expect(reads, 1);
        if (boundary == 'reset') {
          r.events.add(const DriverContactChange(sessionReset: true));
        } else if (boundary == 'background') {
          c.setActive(false);
        } else {
          await c.close();
        }
        reply.complete(
          DriverContact(
            tripId: 'trip',
            driverId: 'driver',
            phoneE164: '+963900000000',
            expiresAt: contactNow.add(const Duration(minutes: 2)),
          ),
        );
        await pending;
        expect(d.calls, 0);
        if (!c.isClosed) await c.close();
      },
    );
  }
  test(
    'real adapter permits only tel E164, reports unsupported and platform errors',
    () async {
      final launched = <Uri>[];
      final dialer = DriverPhoneDialer(
        launch: (uri) async {
          launched.add(uri);
          return true;
        },
      );
      expect(await dialer.open('+963900000000'), DialerResult.opened);
      expect(launched.single.toString(), 'tel:+963900000000');
      for (final input in [
        'https://example.invalid',
        '+9639;123',
        '+963#123',
        '123',
      ]) {
        await expectLater(
          dialer.open(input),
          throwsA(isA<DriverContactFailure>()),
        );
      }
      expect(launched, hasLength(1));
      await expectLater(
        DriverPhoneDialer(launch: (_) async => false).open('+963900000000'),
        throwsA(isA<DriverContactFailure>()),
      );
      await expectLater(
        DriverPhoneDialer(
          launch: (_) async => throw StateError('unavailable'),
        ).open('+963900000000'),
        throwsA(isA<DriverContactFailure>()),
      );
    },
  );
}
