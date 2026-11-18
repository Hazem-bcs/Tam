import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_journey_shell.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

void main() {
  for (final size in [
    const Size(320, 740),
    const Size(844, 390),
    const Size(800, 1000),
  ]) {
    testWidgets(
      'keyboard unfolds editable panel while map viewport stays mounted $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        final focus = FocusNode();
        final controller = TextEditingController(text: 'دمشق');
        addTearDown(focus.dispose);
        addTearDown(controller.dispose);
        var submitted = false;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            locale: const Locale('ar'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                disableAnimations: true,
                textScaler: const TextScaler.linear(2),
              ),
              child: child!,
            ),
            home: Scaffold(
              resizeToAvoidBottomInset: false,
              body: RideJourneyShell(
                header: const Text('الوجهة'),
                mapBuilder: (_) =>
                    const SizedBox.expand(key: Key('map-viewport')),
                stageKey: 'places',
                collapsedLabel: 'الوجهة',
                preferredExtent: .7,
                panel: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        key: const Key('location-field'),
                        focusNode: focus,
                        controller: controller,
                      ),
                      const SizedBox(height: 200),
                      FilledButton(
                        key: const Key('location-action'),
                        onPressed: () => submitted = true,
                        child: const Text('تأكيد'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final viewport = tester.element(find.byKey(const Key('map-viewport')));
        final originalSize = tester.getSize(
          find.byKey(const Key('map-viewport')),
        );
        await tester.tap(find.byKey(const Key('ride-sheet-toggle')));
        await tester.pumpAndSettle();
        focus.requestFocus();
        tester.view.viewInsets = const FakeViewPadding(bottom: 220);
        await tester.pumpAndSettle();
        final input = find.byKey(const Key('location-field'));
        await tester.ensureVisible(input);
        await tester.enterText(input, 'دمشق الجديدة');
        await tester.pumpAndSettle();
        final action = find.byKey(const Key('location-action'));
        await tester.ensureVisible(action);
        await tester.pumpAndSettle();
        expect(
          tester.getBottomRight(action).dy,
          lessThanOrEqualTo(size.height - 220),
        );
        await tester.tap(action);
        expect(submitted, isTrue);
        expect(controller.text, 'دمشق الجديدة');
        expect(
          tester.element(find.byKey(const Key('map-viewport'))),
          same(viewport),
        );
        expect(
          tester.getSize(find.byKey(const Key('map-viewport'))),
          originalSize,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
