import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/completion/presentation/widgets/completion_feedback_options.dart';

void main() {
  const positive = ['سائق محترم', 'مركبة نظيفة', 'رحلة مريحة'];
  const critical = ['تأخر الوصول', 'مشكلة بالمركبة', 'تجربة غير مريحة'];

  for (final scenario in [
    (name: 'phone', width: 310.0, scale: 1.0),
    (name: 'small accessibility', width: 240.0, scale: 2.0),
  ]) {
    testWidgets(
      '${scenario.name}: changing rating sentiment preserves option geometry',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        Future<void> show(List<String> labels, bool positive) async {
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scenario.scale)),
                child: child!,
              ),
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: scenario.width,
                    child: CompletionFeedbackOptions(
                      labels: labels,
                      positive: positive,
                      selected: const {},
                      enabled: true,
                      onToggle: (_) {},
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        await show(positive, true);
        final positiveRects = [
          for (var i = 0; i < 3; i++)
            tester.getRect(find.byKey(ValueKey('completion-tag-$i'))),
        ];

        await show(critical, false);
        final criticalRects = [
          for (var i = 0; i < 3; i++)
            tester.getRect(find.byKey(ValueKey('completion-tag-$i'))),
        ];
        expect(criticalRects, positiveRects);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
