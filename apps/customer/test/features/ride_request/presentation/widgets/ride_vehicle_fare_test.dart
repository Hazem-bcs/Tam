import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_animated_fare.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import '../../../../support/page_scroll.dart';
import '../../scheduling/schedule_widget_support.dart';

const capture = bool.fromEnvironment('CAPTURE_RIDE_FARE_UI');
void main() {
  setUpAll(loadScheduleFonts);
  void size(WidgetTester tester, double width, double height) {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
  }

  Future<void> tap(WidgetTester tester, String key) async {
    final target = find.byKey(Key(key));
    await revealPageWidget(tester, target);
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> picture(WidgetTester tester, String name) async {
    if (!capture) return;
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const Key('schedule-preview')),
      );
      final image = await boundary.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      final file = File(
        '../../docs/engineering/deliveries/TAM-RIDE-VEHICLE-FARE-20261117/$name.png',
      );
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
    });
  }

  testWidgets(
    'wallet, valid coupon and vehicle changes book once from one sheet',
    (tester) async {
      size(tester, 390, 900);
      final bloc = await pumpSchedule(tester);
      expect(bloc.state.vehicleQuotes, hasLength(4));
      await tap(tester, 'ride-payment-wallet');
      expect(bloc.state.paymentMethod, TripPaymentMethod.wallet);
      final input = find.byKey(const Key('ride-coupon-input'));
      await revealPageWidget(tester, input);
      await tester.enterText(input, 'TAM10');
      await tap(tester, 'ride-coupon-apply');
      expect(bloc.state.quote!.fare.amountMinor, 24300);
      expect(find.byKey(const Key('ride-coupon-applied')), findsOneWidget);
      await tap(tester, 'ride-vehicle-comfort');
      expect(bloc.state.quote!.fare.amountMinor, 33300);
      await picture(tester, 'wallet-coupon-ar-390');
      await tap(tester, 'ride-flow-continue');
      expect(bloc.state.status, RideFlowStatus.booked);
      expect(
        bloc.state.confirmedTrip!.booking.paymentMethod,
        TripPaymentMethod.wallet,
      );
      expect(bloc.state.confirmedTrip!.booking.couponCode, 'TAM10');
      expect(bloc.state.confirmedTrip!.booking.fare.amountMinor, 33300);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    },
  );
  testWidgets(
    'invalid coupon blocks submission and explicit removal restores price',
    (tester) async {
      size(tester, 390, 900);
      final bloc = await pumpSchedule(tester, locale: 'en');
      final input = find.byKey(const Key('ride-coupon-input'));
      await revealPageWidget(tester, input);
      await tester.enterText(input, 'BAD');
      await tap(tester, 'ride-coupon-apply');
      expect(bloc.state.errorCode, 'COUPON_INVALID');
      expect(bloc.canConfirm, isFalse);
      await picture(tester, 'invalid-coupon-en-390');
      bloc.add(const RideCouponRemoved());
      await tester.pumpAndSettle();
      expect(bloc.state.quote!.fare.amountMinor, 27000);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    },
  );
  for (final scenario in [
    ('ar', 320.0, 740.0, 1.0, false),
    ('ar', 320.0, 740.0, 2.0, true),
    ('en', 390.0, 844.0, 1.0, false),
    ('en', 800.0, 1000.0, 2.0, false),
    ('en', 844.0, 390.0, 1.0, true),
  ]) {
    testWidgets(
      'fare layout ${scenario.$1} ${scenario.$2} scale ${scenario.$4} keyboard ${scenario.$5}',
      (tester) async {
        size(tester, scenario.$2, scenario.$3);
        await pumpSchedule(tester, locale: scenario.$1, scale: scenario.$4);
        await revealPageWidget(
          tester,
          find.byKey(const Key('ride-vehicle-scroll')),
        );
        final scroll = tester.state<ScrollableState>(
          find
              .descendant(
                of: find.byKey(const Key('ride-vehicle-scroll')),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        if (scenario.$2 <= 390) {
          expect(scroll.position.maxScrollExtent, greaterThan(0));
        }
        await picture(
          tester,
          'selection-${scenario.$1}-${scenario.$2.toInt()}-x${scenario.$4.toInt()}',
        );
        final input = find.byKey(const Key('ride-coupon-input'));
        await revealPageWidget(tester, input);
        if (scenario.$5) {
          await tester.tap(input);
          tester.view.viewInsets = const FakeViewPadding(bottom: 220);
          await tester.pumpAndSettle();
          await revealPageWidget(tester, input);
          await tester.enterText(input, 'TAM10');
          await tester.pumpAndSettle();
          await picture(
            tester,
            'keyboard-${scenario.$1}-${scenario.$2.toInt()}-x${scenario.$4.toInt()}',
          );
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pump();
      },
    );
  }
  testWidgets(
    'fare counts in both directions, resumes from its current number, and honors reduced motion',
    (tester) async {
      Future<void> show(int amount, {bool reduce = false}) => tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: reduce),
            child: Scaffold(
              body: RideAnimatedFare(
                value: Money(amountMinor: amount),
                loading: false,
              ),
            ),
          ),
        ),
      );
      int number() => int.parse(
        tester
            .widget<Text>(find.byKey(const Key('ride-animated-fare')))
            .data!
            .replaceAll(RegExp('[^0-9]'), ''),
      );
      await show(15000);
      await show(25000);
      await tester.pump(const Duration(milliseconds: 200));
      final midway = number();
      expect(midway, inExclusiveRange(15000, 25000));
      await show(10000);
      expect(number(), midway);
      await tester.pump(const Duration(milliseconds: 200));
      expect(number(), inExclusiveRange(10000, midway));
      await tester.pumpAndSettle();
      expect(number(), 10000);
      await show(30000, reduce: true);
      await tester.pump();
      expect(number(), 30000);
    },
  );
}
