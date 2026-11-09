import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_schedule_dialog.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_time_dialog.dart';
import 'package:tam_customer/shared/domain/ride_schedule_policy.dart';

import 'schedule_widget_support.dart';

void main() {
  setUpAll(loadScheduleFonts);
  Future<void> open(WidgetTester tester) async {
    final chip = find.byKey(const Key('ride-scheduled'));
    await tester.scrollUntilVisible(
      chip,
      180,
      scrollable: find
          .descendant(
            of: find.byType(ListView).first,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.ensureVisible(chip);
    await tester.pumpAndSettle();
    await tester.tap(chip);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'cancel preserves intent, saving reprices, immediate clears time',
    (tester) async {
      final bloc = await pumpSchedule(tester);
      final firstQuote = bloc.state.quote;
      await open(tester);
      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();
      expect(bloc.state.quote, firstQuote);
      expect(bloc.state.scheduledAt, isNull);
      await open(tester);
      await tester.tap(find.byKey(const Key('schedule-confirm')));
      await tester.pumpAndSettle();
      final time = bloc.state.scheduledAt;
      expect(time, DateTime.utc(2026, 11, 9, 12, 31));
      expect(bloc.state.quote, isNot(firstQuote));
      await open(tester);
      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();
      expect(bloc.state.scheduledAt, time);
      await tester.tap(find.byKey(const Key('ride-immediate')));
      await tester.pumpAndSettle();
      expect(bloc.state.scheduledAt, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('time becoming too soon stays open with accessible validation', (
    tester,
  ) async {
    var now = DateTime.utc(2026, 11, 9, 12);
    await pumpSchedule(tester, now: () => now);
    await open(tester);
    now = now.add(const Duration(minutes: 2));
    await tester.tap(find.byKey(const Key('schedule-confirm')));
    await tester.pumpAndSettle();
    expect(find.byType(RideScheduleDialog), findsOneWidget);
    expect(find.textContaining('الموعد خارج المدى'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'time text input with keyboard keeps the schedule action reachable',
    (tester) async {
      tester.view.physicalSize = const Size(320, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      await pumpSchedule(tester, scale: 2);
      await open(tester);
      await tester.tap(find.byKey(const Key('schedule-time')));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 200);
      await tester.pumpAndSettle();
      if (captureScheduleUi) {
        await expectLater(
          find.byKey(const Key('schedule-preview')),
          matchesGoldenFile('goldens/time-input-ar-320-x2-keyboard.png'),
        );
      }
      final input = find.descendant(
        of: find.byType(RideTimeDialog),
        matching: find.byType(TextField),
      );
      expect(input, findsNWidgets(2));
      await tester.enterText(input.last, '45');
      final ok = find.byKey(const Key('schedule-time-save'));
      await tester.ensureVisible(ok);
      await tester.pumpAndSettle();
      await tester.tap(ok);
      await tester.pumpAndSettle();
      expect(find.byType(RideTimeDialog), findsNothing);
      final confirm = find.byKey(const Key('schedule-confirm'));
      await tester.ensureVisible(confirm);
      await tester.pumpAndSettle();
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(find.byType(RideScheduleDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    '24-hour input validates range and accepts Arabic/Persian digits',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final bloc = await pumpSchedule(tester);
      await open(tester);
      await tester.tap(find.byKey(const Key('schedule-time')));
      await tester.pumpAndSettle();
      if (captureScheduleUi) {
        await expectLater(
          find.byKey(const Key('schedule-preview')),
          matchesGoldenFile('goldens/time-input-ar-390-x1.png'),
        );
      }
      final inputs = find.descendant(
        of: find.byType(RideTimeDialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(inputs.first, '٢٥');
      await tester.tap(find.byKey(const Key('schedule-time-save')));
      await tester.pumpAndSettle();
      expect(find.text('أدخل قيمة صحيحة ضمن المجال.'), findsOneWidget);
      await tester.enterText(inputs.first, '۱۸');
      await tester.enterText(inputs.last, '٤٥');
      await tester.tap(find.byKey(const Key('schedule-time-save')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('schedule-confirm')));
      await tester.pumpAndSettle();
      expect(bloc.state.scheduledAt, DateTime.utc(2026, 11, 9, 15, 45));
      expect(tester.takeException(), isNull);
    },
  );

  for (final spec in [
    (const Size(320, 780), 'ar', 2.0),
    (const Size(390, 844), 'ar', 1.0),
    (const Size(800, 980), 'ar', 1.0),
    (const Size(390, 844), 'en', 1.0),
    (const Size(800, 360), 'en', 2.0),
  ]) {
    testWidgets('schedule picker ${spec.$1} ${spec.$2} x${spec.$3}', (
      tester,
    ) async {
      tester.view.physicalSize = spec.$1;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final bloc = await pumpSchedule(tester, locale: spec.$2, scale: spec.$3);
      await open(tester);
      if (captureScheduleUi) {
        await expectLater(
          find.byKey(const Key('schedule-preview')),
          matchesGoldenFile(
            'goldens/dialog-${spec.$2}-${spec.$1.width.toInt()}-x${spec.$3.toInt()}.png',
          ),
        );
      }
      final date = find.byKey(const Key('schedule-date'));
      await tester.ensureVisible(date);
      await tester.pumpAndSettle();
      await tester.tap(date);
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
      final dateContext = tester.element(find.byType(DatePickerDialog));
      await tester.tap(
        find.text(MaterialLocalizations.of(dateContext).cancelButtonLabel).last,
      );
      await tester.pumpAndSettle();
      final time = find.byKey(const Key('schedule-time'));
      await tester.ensureVisible(time);
      await tester.pumpAndSettle();
      await tester.tap(time);
      await tester.pumpAndSettle();
      expect(find.byType(RideTimeDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
      final cancelTime = find.descendant(
        of: find.byType(RideTimeDialog),
        matching: find.byType(TextButton),
      );
      await tester.ensureVisible(cancelTime);
      await tester.pumpAndSettle();
      await tester.tap(cancelTime);
      await tester.pumpAndSettle();
      final confirm = find.byKey(const Key('schedule-confirm'));
      await tester.ensureVisible(confirm);
      await tester.pumpAndSettle();
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(bloc.state.scheduledAt, isNotNull);
      expect(bloc.canConfirm, isTrue);
      expect(
        const RideSchedulePolicy().allows(
          bloc.state.scheduledAt,
          bloc.currentTime,
        ),
        isTrue,
      );
      if (captureScheduleUi) {
        await expectLater(
          find.byKey(const Key('schedule-preview')),
          matchesGoldenFile(
            'goldens/selection-${spec.$2}-${spec.$1.width.toInt()}-x${spec.$3.toInt()}.png',
          ),
        );
      }
      expect(tester.takeException(), isNull);
    });
  }
}
