import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/home/data/mock/mock_home_repository.dart';
import 'package:tam_customer/features/home/domain/entities/home_content.dart';
import 'package:tam_customer/features/home/domain/repositories/home_repository.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_departure_portal.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

import 'home_test_support.dart';

void main() {
  test('Home semantic foregrounds remain readable on the new surfaces', () {
    final colors = AppTheme.home(AppTheme.light).colorScheme;
    for (final pair in [
      (colors.primary, colors.onPrimary),
      (colors.surface, colors.onSurface),
      (colors.surface, colors.onSurfaceVariant),
      (colors.secondaryContainer, colors.onSecondaryContainer),
      (colors.primaryContainer, colors.primary),
      (colors.surfaceContainerLowest, colors.onSurface),
    ]) {
      final a = pair.$1.computeLuminance();
      final b = pair.$2.computeLuminance();
      expect(
        (a > b ? (a + .05) / (b + .05) : (b + .05) / (a + .05)),
        greaterThanOrEqualTo(4.5),
      );
    }
  });

  testWidgets('unavailable ride hides departure action and cannot navigate', (
    tester,
  ) async {
    final nav = RecordingHomeNavigation();
    await pumpHome(
      tester,
      navigation: nav,
      repository: _ContentRepository(
        HomeContent(
          revision: 'unavailable',
          promotions: const [],
          services: const [
            HomeService(id: HomeServiceId.ride, available: false, action: null),
          ],
        ),
      ),
    );
    expect(find.byType(HomeDeparturePortal), findsNothing);
    await tester.tap(find.text('مشوار'));
    expect(nav.ride, 0);
    expect(find.text('قريباً في تم'), findsOneWidget);
  });

  testWidgets(
    'pending load preserves utilities and reveals only real content',
    (tester) async {
      final pending = Completer<HomeContent>();
      final nav = RecordingHomeNavigation();
      await pumpHome(
        tester,
        repository: _PendingRepository(pending.future),
        navigation: nav,
        settle: false,
      );
      expect(find.byType(HomeDeparturePortal), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byKey(const Key('home-notifications')));
      expect(nav.notifications, 1);
      pending.complete(
        await const MockHomeRepository(latency: Duration.zero).load(),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HomeDeparturePortal), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'large English type keeps the primary action reachable in landscape',
    (tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final nav = RecordingHomeNavigation();
      await pumpHome(
        tester,
        repository: const MockHomeRepository(latency: Duration.zero),
        navigation: nav,
        language: 'en',
      );
      final action = find.byKey(const Key('home-ride-entry'));
      await tester.ensureVisible(action);
      await tester.tap(action);
      expect(nav.ride, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('keyboard inset leaves departure action scrollable and usable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    final nav = RecordingHomeNavigation();
    await pumpHome(
      tester,
      repository: const MockHomeRepository(latency: Duration.zero),
      navigation: nav,
    );
    final action = find.byKey(const Key('home-ride-entry'));
    await tester.ensureVisible(action);
    await tester.tap(action);
    expect(nav.ride, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'reduced motion renders the departure action immediately and idles',
    (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.home(AppTheme.light),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: Scaffold(
            body: HomeDeparturePortal(onRideRequest: () => taps++),
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('home-ride-entry')));
      expect(taps, 1);
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}

final class _ContentRepository implements HomeRepository {
  _ContentRepository(this.content);
  final HomeContent content;
  @override
  Future<HomeContent> load() async => content;
}

final class _PendingRepository implements HomeRepository {
  _PendingRepository(this.pending);
  final Future<HomeContent> pending;
  @override
  Future<HomeContent> load() => pending;
}
