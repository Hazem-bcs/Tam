import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/active_trip/data/mock/active_trip_scenario.dart';
import 'package:tam_customer/features/active_trip/data/unavailable_active_trip_repository.dart';
import 'package:tam_customer/shared/domain/trip.dart';

import '../../support/page_scroll.dart';
import 'active_trip_test_support.dart';
import 'active_trip_widget_support.dart';

void main() {
  setUpAll(loadActiveFonts);
  Future<void> capture(WidgetTester tester, String name) async {
    if (!captureActiveUi) return;
    await expectLater(
      find.byKey(const Key('active-preview')),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  Future<void> visible(WidgetTester tester, Finder target) async {
    await revealPageWidget(tester, target);
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
  }

  testWidgets('cancel requires confirmation and updates the shared trip', (
    tester,
  ) async {
    final fixture = ActiveTripFixture();
    addTearDown(fixture.dispose);
    final id = fixture.book().id;
    await pumpActiveTrip(
      tester,
      repository: fixture.repository,
      now: () => fixture.now,
      tripId: id,
    );
    final cancel = find.byKey(const Key('active-cancel'));
    await visible(tester, cancel);
    await tester.tap(cancel);
    await tester.pumpAndSettle();
    await tester.tap(find.text('متابعة الرحلة').last);
    await tester.pumpAndSettle();
    expect(fixture.store.find(id)!.status, TripStatus.requested);
    await tester.tap(cancel);
    await tester.pumpAndSettle();
    await tester.tap(find.text('تأكيد الإلغاء'));
    await tester.pumpAndSettle();
    expect(fixture.store.find(id)!.status, TripStatus.cancelled);
    await tester.drag(
      find.byKey(const Key('active-trip-scroll')),
      const Offset(0, 1600),
    );
    await tester.pumpAndSettle();
    await capture(tester, 'cancelled-ar-800');
    expect(find.byKey(const Key('active-cancel')), findsNothing);
    await visible(tester, find.byKey(const Key('active-rebook')));
    expect(tester.takeException(), isNull);
  });
  testWidgets('no driver offers a new quote using locations only', (
    tester,
  ) async {
    final fixture = ActiveTripFixture(scenario: ActiveTripScenario.noDriver);
    addTearDown(fixture.dispose);
    final trip = fixture.book();
    fixture.advance(2);
    final nav = ActiveNavigationSpy();
    await pumpActiveTrip(
      tester,
      repository: fixture.repository,
      now: () => fixture.now,
      tripId: trip.id,
      navigation: nav,
    );
    await capture(tester, 'no-driver-ar-800');
    final rebook = find.byKey(const Key('active-rebook'));
    await visible(tester, rebook);
    await tester.tap(rebook);
    expect(nav.prefill!.pickup, trip.booking.pickup);
    expect(nav.prefill!.destination, trip.booking.destination);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'disconnect retains last snapshot and refresh recovers current state',
    (tester) async {
      final fixture = ActiveTripFixture(
        scenario: ActiveTripScenario.disconnect,
        durations: const ActiveTripTimings(),
      );
      addTearDown(fixture.dispose);
      final id = fixture.book().id;
      fixture.advance(17);
      final cubit = await pumpActiveTrip(
        tester,
        repository: fixture.repository,
        now: () => fixture.now,
        tripId: id,
      );
      final old = cubit.state.trip;
      fixture.advance(3);
      await tester.pumpAndSettle();
      expect(cubit.state.offline, isTrue);
      expect(cubit.state.trip, old);
      await tester.drag(
        find.byKey(const Key('active-trip-scroll')),
        const Offset(0, 1600),
      );
      await tester.pumpAndSettle();
      await capture(tester, 'offline-ar-800');
      fixture.advance(15);
      await cubit.refresh();
      await tester.pumpAndSettle();
      expect(cubit.state.offline, isFalse);
      expect(
        cubit.state.trip!.live!.revision,
        greaterThan(old!.live!.revision),
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('empty current and unavailable API have distinct UI states', (
    tester,
  ) async {
    final fixture = ActiveTripFixture();
    addTearDown(fixture.dispose);
    await pumpActiveTrip(
      tester,
      repository: fixture.repository,
      now: () => fixture.now,
    );
    expect(find.text('لا توجد رحلة متاحة للمتابعة الآن.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await pumpActiveTrip(
      tester,
      repository: const UnavailableActiveTripRepository(),
      now: () => fixture.now,
    );
    expect(find.text('خدمة متابعة الرحلة غير متاحة حاليًا.'), findsOneWidget);
  });
  testWidgets('scheduled tracking waits for due time before driver search', (
    tester,
  ) async {
    final fixture = ActiveTripFixture(durations: const ActiveTripTimings());
    addTearDown(fixture.dispose);
    final id = fixture
        .book(scheduledAt: fixture.now.add(const Duration(minutes: 30)))
        .id;
    final cubit = await pumpActiveTrip(
      tester,
      repository: fixture.repository,
      now: () => fixture.now,
      tripId: id,
    );
    expect(cubit.state.trip!.status, TripStatus.scheduled);
    await capture(tester, 'scheduled-ar-800');
    fixture.advance(1800);
    await tester.pumpAndSettle();
    expect(cubit.state.trip!.status, TripStatus.requested);
    await capture(tester, 'dispatched-ar-800');
  });
  for (final stage in [
    (0, 'requested'),
    (12, 'confirmed'),
    (17, 'en-route'),
    (42, 'arrived'),
    (57, 'in-progress'),
    (87, 'completed'),
  ]) {
    testWidgets('render ${stage.$2} at 390dp', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final fixture = ActiveTripFixture(durations: const ActiveTripTimings());
      addTearDown(fixture.dispose);
      final id = fixture.book().id;
      fixture.advance(stage.$1);
      await pumpActiveTrip(
        tester,
        repository: fixture.repository,
        now: () => fixture.now,
        tripId: id,
      );
      await capture(tester, '${stage.$2}-ar-390');
      expect(tester.takeException(), isNull);
    });
  }
  for (final spec in [
    (const Size(320, 780), 'ar', 2.0),
    (const Size(800, 980), 'ar', 1.0),
    (const Size(390, 844), 'en', 1.0),
    (const Size(800, 360), 'en', 2.0),
  ]) {
    testWidgets('driver profile and actions ${spec.$1}/${spec.$2}/${spec.$3}', (
      tester,
    ) async {
      tester.view.physicalSize = spec.$1;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final fixture = ActiveTripFixture();
      addTearDown(fixture.dispose);
      final id = fixture.book().id;
      fixture.advance(3);
      await pumpActiveTrip(
        tester,
        repository: fixture.repository,
        now: () => fixture.now,
        tripId: id,
        locale: spec.$2,
        scale: spec.$3,
      );
      await capture(
        tester,
        'responsive-${spec.$2}-${spec.$1.width.toInt()}-x${spec.$3.toInt()}',
      );
      final driver = find.text(
        spec.$2 == 'ar' ? 'محمد أحمد' : 'Mohammad Ahmad',
      );
      await visible(tester, driver);
      await tester.tap(driver);
      await tester.pumpAndSettle();
      await capture(
        tester,
        'driver-${spec.$2}-${spec.$1.width.toInt()}-x${spec.$3.toInt()}',
      );
      final close = find.text(spec.$2 == 'ar' ? 'إغلاق' : 'Close');
      await tester.ensureVisible(close);
      await tester.pumpAndSettle();
      await tester.tap(close);
      await tester.pumpAndSettle();
      await visible(tester, find.byKey(const Key('active-cancel')));
      await tester.tap(find.byKey(const Key('active-cancel')));
      await tester.pumpAndSettle();
      final confirm = find.text(
        spec.$2 == 'ar' ? 'تأكيد الإلغاء' : 'Confirm cancellation',
      );
      await tester.ensureVisible(confirm);
      await tester.pumpAndSettle();
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(fixture.store.find(id)!.status, TripStatus.cancelled);
      expect(tester.takeException(), isNull);
    });
  }
}
