import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_snack_bar.dart';

void main() {
  late BuildContext surface;
  late GlobalKey<NavigatorState> navigator;
  Future<void> host(
    WidgetTester tester, {
    bool accessible = false,
    bool reduced = false,
  }) async {
    navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        theme: AppTheme.light,
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            accessibleNavigation: accessible,
            disableAnimations: reduced,
          ),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              surface = context;
              return const Text('Page one');
            },
          ),
        ),
      ),
    );
  }

  Future<void> reveal(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  double fraction(WidgetTester tester) => tester
      .widget<CircularProgressIndicator>(
        find.byKey(const Key('tam-snackbar-countdown')),
      )
      .value!;

  testWidgets(
    'countdown begins after entry and expires with the native notice',
    (tester) async {
      await host(tester);
      final notice = TamSnackBar.show(
        surface,
        message: 'تم إنشاء طلب الدعم',
        tone: TamSnackBarTone.success,
      );
      await reveal(tester);
      expect(fraction(tester), closeTo(1, .02));
      await tester.pump(const Duration(seconds: 2));
      expect(fraction(tester), closeTo(.5, .03));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('تم إنشاء طلب الدعم'), findsNothing);
      expect(await notice.closed, SnackBarClosedReason.timeout);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'queue does not consume the next notice countdown before display',
    (tester) async {
      await host(tester);
      TamSnackBar.show(
        surface,
        message: 'First',
        duration: const Duration(seconds: 1),
      );
      TamSnackBar.show(surface, message: 'Second');
      await reveal(tester);
      expect(find.text('Second'), findsNothing);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Second'), findsOneWidget);
      expect(fraction(tester), closeTo(1, .03));
      await tester.pump(const Duration(seconds: 1));
      expect(fraction(tester), closeTo(.75, .03));
    },
  );
  testWidgets('dismiss button closes early and preserves the native reason', (
    tester,
  ) async {
    await host(tester);
    final notice = TamSnackBar.show(surface, message: 'Dismiss');
    await reveal(tester);
    final button = find.byKey(const Key('tam-snackbar-dismiss'));
    expect(tester.getSize(button).width, greaterThanOrEqualTo(48));
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(await notice.closed, SnackBarClosedReason.dismiss);
    expect(find.text('Dismiss'), findsNothing);
  });
  testWidgets('moving to another scaffold does not restart the same deadline', (
    tester,
  ) async {
    await host(tester);
    TamSnackBar.show(surface, message: 'Across pages');
    await reveal(tester);
    await tester.pump(const Duration(seconds: 1));
    navigator.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Page two')),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    final progress = tester
        .widgetList<CircularProgressIndicator>(
          find.byKey(const Key('tam-snackbar-countdown')),
        )
        .map((p) => p.value!);
    expect(progress, isNotEmpty);
    expect(progress.every((value) => value < .8), isTrue);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Across pages'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'action notice persists, keeps its action and has no expiry claim',
    (tester) async {
      await host(tester);
      var calls = 0;
      final notice = TamSnackBar.show(
        surface,
        message: 'Retry',
        tone: TamSnackBarTone.error,
        action: SnackBarAction(
          label: 'إعادة المحاولة',
          onPressed: () => calls++,
        ),
      );
      await reveal(tester);
      expect(find.byKey(const Key('tam-snackbar-countdown')), findsNothing);
      await tester.pump(const Duration(seconds: 8));
      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(await notice.closed, SnackBarClosedReason.action);
    },
  );
  testWidgets('accessible navigation persists with an explicit close control', (
    tester,
  ) async {
    await host(tester, accessible: true);
    TamSnackBar.show(surface, message: 'Accessible');
    await reveal(tester);
    await tester.pump(const Duration(seconds: 8));
    expect(find.text('Accessible'), findsOneWidget);
    expect(find.byKey(const Key('tam-snackbar-countdown')), findsNothing);
    await tester.tap(find.byKey(const Key('tam-snackbar-dismiss')));
    await tester.pumpAndSettle();
    expect(find.text('Accessible'), findsNothing);
  });
  testWidgets(
    'reduced motion removes the animated ring without changing timeout',
    (tester) async {
      await host(tester, reduced: true);
      final notice = TamSnackBar.show(surface, message: 'Reduced motion');
      await reveal(tester);
      expect(find.byKey(const Key('tam-snackbar-countdown')), findsNothing);
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(milliseconds: 350));
      expect(await notice.closed, SnackBarClosedReason.timeout);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('native swipe still dismisses the notice', (tester) async {
    await host(tester);
    final notice = TamSnackBar.show(surface, message: 'Swipe');
    await reveal(tester);
    await tester.fling(find.byType(SnackBar), const Offset(0, 200), 1000);
    await tester.pumpAndSettle();
    expect(await notice.closed, SnackBarClosedReason.swipe);
  });
}
