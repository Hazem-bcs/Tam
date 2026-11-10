import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/maps/data/maps_attribution_adapter.dart';
import 'package:tam_customer/features/maps/domain/maps_repository.dart';
import 'package:tam_customer/features/maps/presentation/widgets/map_attribution_link.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

void main() {
  test('license adapter opens only the fixed HTTPS information page', () async {
    Uri? opened;
    final adapter = MapsAttributionAdapter(
      launch: (uri) async {
        opened = uri;
        return true;
      },
    );
    expect(opened, isNull);
    await adapter.open();
    expect(opened.toString(), 'https://www.openstreetmap.org/copyright');
  });
  for (final throwsError in [false, true]) {
    test('license launch failure is explicit (throws=$throwsError)', () async {
      final adapter = MapsAttributionAdapter(
        launch: (_) async {
          if (throwsError) throw StateError('platform unavailable');
          return false;
        },
      );
      await expectLater(adapter.open(), throwsA(isA<MapsFailure>()));
    });
  }
  testWidgets('license opens on tap and reports failure accessibly', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MapAttributionLink(
            onOpen: () async {
              calls++;
              throw const MapsFailure('ATTRIBUTION_UNAVAILABLE');
            },
          ),
        ),
      ),
    );
    expect(calls, 0);
    final link = find.byKey(const Key('map-attribution'));
    expect(tester.getSize(link).height, greaterThanOrEqualTo(48));
    await tester.tap(link);
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(
      find.text('Could not open map license information. Please try again.'),
      findsOneWidget,
    );
  });
  for (final language in ['ar', 'en']) {
    testWidgets(
      '$language attribution collapses after reading and can reopen',
      (tester) async {
        var calls = 0;
        tester.view.physicalSize = const Size(320, 740);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            locale: Locale(language),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: Scaffold(
              body: MapAttributionLink(onOpen: () async => calls++),
            ),
          ),
        );
        final text = find.byKey(const Key('map-attribution'));
        final toggle = find.byKey(const Key('map-attribution-toggle'));
        await tester.pump(const Duration(milliseconds: 4900));
        expect(text, findsOneWidget);
        await tester.pump(const Duration(milliseconds: 100));
        expect(text, findsNothing);
        expect(tester.getSize(toggle).width, greaterThanOrEqualTo(48));
        await tester.tap(toggle);
        await tester.pump();
        expect(text, findsOneWidget);
        await tester.tap(text);
        await tester.pump();
        expect(calls, 1);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 6));
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('accessible navigation keeps the attribution readable', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(accessibleNavigation: true),
          child: child!,
        ),
        home: const Scaffold(body: MapAttributionLink()),
      ),
    );
    await tester.pump(const Duration(seconds: 6));
    expect(find.byKey(const Key('map-attribution')), findsOneWidget);
  });
}
