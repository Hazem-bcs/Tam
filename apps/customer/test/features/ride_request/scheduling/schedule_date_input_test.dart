import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_schedule_dialog.dart';

import 'schedule_widget_support.dart';

void main() {
  testWidgets('date text entry stays usable with keyboard and large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    final bloc = await pumpSchedule(tester, scale: 2);
    final scheduled = find.byKey(const Key('ride-scheduled'));
    await tester.scrollUntilVisible(
      scheduled,
      180,
      scrollable: find
          .descendant(
            of: find.byType(ListView).first,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.ensureVisible(scheduled);
    await tester.pumpAndSettle();
    await tester.tap(scheduled);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('schedule-date')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(DatePickerDialog),
        matching: find.byIcon(Icons.edit_outlined),
      ),
    );
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 200);
    await tester.pumpAndSettle();
    final picker = find.byType(DatePickerDialog);
    final localizations = MaterialLocalizations.of(tester.element(picker));
    await tester.enterText(
      find.descendant(of: picker, matching: find.byType(TextField)),
      localizations.formatCompactDate(DateTime(2026, 11, 10)),
    );
    final saveDate = find.descendant(
      of: picker,
      matching: find.text(localizations.okButtonLabel),
    );
    await tester.ensureVisible(saveDate);
    await tester.pumpAndSettle();
    await tester.tap(saveDate);
    await tester.pumpAndSettle();
    expect(picker, findsNothing);
    final saveSchedule = find.byKey(const Key('schedule-confirm'));
    await tester.ensureVisible(saveSchedule);
    await tester.pumpAndSettle();
    await tester.tap(saveSchedule);
    await tester.pumpAndSettle();
    expect(find.byType(RideScheduleDialog), findsNothing);
    expect(bloc.state.scheduledAt, DateTime.utc(2026, 11, 10, 12, 31));
    expect(tester.takeException(), isNull);
  });
}
