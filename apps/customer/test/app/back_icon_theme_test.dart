import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_route_header.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

void main() {
  testWidgets('ride route header keeps back and home actions distinct', (
    tester,
  ) async {
    var count = 0;
    Widget routeHeader(bool home) => MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: RideRouteHeader(onBack: () => count++, backToHome: home),
      ),
    );
    await tester.pumpWidget(routeHeader(false));
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    await tester.tap(find.byKey(const Key('ride-flow-back')));
    expect(count, 1);
    await tester.pumpWidget(routeHeader(true));
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    await tester.tap(find.byKey(const Key('ride-flow-back')));
    expect(count, 2);
  });
  for (final direction in TextDirection.values) {
    testWidgets('back icons follow $direction on Android', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light.copyWith(platform: TargetPlatform.android),
          home: Directionality(
            textDirection: direction,
            child: Scaffold(
              body: IconButton(
                onPressed: () => pressed = true,
                icon: const BackButtonIcon(),
              ),
            ),
          ),
        ),
      );
      final icon = find.descendant(
        of: find.byType(BackButtonIcon),
        matching: find.byIcon(Icons.arrow_back_ios_new_rounded),
      );
      expect(icon, findsOneWidget);
      final mirrored = find.descendant(
        of: icon,
        matching: find.byType(Transform),
      );
      if (direction == TextDirection.rtl) {
        expect(mirrored, findsOneWidget);
        expect(tester.widget<Transform>(mirrored).transform.entry(0, 0), -1);
      } else {
        expect(mirrored, findsNothing);
      }
      await tester.tap(find.byType(IconButton));
      expect(pressed, isTrue);
    });
  }

  testWidgets('automatically generated AppBar back button keeps navigation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      Scaffold(appBar: AppBar(title: const Text('Details'))),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
  });
}
