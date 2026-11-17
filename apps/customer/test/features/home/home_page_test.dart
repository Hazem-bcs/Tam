import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/home/data/mock/mock_home_repository.dart';
import 'package:tam_customer/features/home/data/unavailable_home_repository.dart';
import 'package:tam_customer/features/home/presentation/pages/home_page.dart';

import 'home_test_support.dart';

void main() {
  testWidgets(
    'Home header shows session state without repeating phone details',
    (tester) async {
      await pumpHome(
        tester,
        repository: const MockHomeRepository(latency: Duration.zero),
        navigation: RecordingHomeNavigation(),
      );
      expect(find.text('تم تسجيل الدخول'), findsOneWidget);
      expect(find.text('+963941234567'), findsNothing);
    },
  );

  testWidgets(
    'Arabic Home has one ride entry and non-clickable informational content',
    (tester) async {
      final nav = RecordingHomeNavigation();
      await pumpHome(
        tester,
        repository: const MockHomeRepository(latency: Duration.zero),
        navigation: nav,
      );
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('تم تسجيل الدخول'), findsOneWidget);
      expect(find.text('+963941234567'), findsNothing);
      expect(find.text('وين رايح اليوم؟'), findsOneWidget);
      expect(find.text('قريباً في تم'), findsOneWidget);
      expect(find.text('إعلانات تم'), findsOneWidget);
      expect(find.byKey(const Key('home-promotions-slider')), findsOneWidget);
      expect(find.text('مشوارك أسهل مع تم'), findsOneWidget);
      expect(find.text('تسجيل الخروج'), findsNothing);
      expect(find.text('تسجيل الدخول'), findsNothing);

      await tester.tap(find.byKey(const Key('home-notifications')));
      expect(nav.notifications, 1);
      final rideAction = find.byKey(const Key('home-ride-entry'));
      await tester.ensureVisible(rideAction);
      await tester.tap(rideAction);
      expect(nav.ride, 1);
      expect(find.byKey(const Key('home-ride-entry')), findsOneWidget);
      expect(find.byKey(const Key('home-addresses')), findsNothing);
      expect(find.byKey(const Key('home-active-trip')), findsNothing);
      await tester.ensureVisible(find.text('الطعام'));
      final foodLabel = find.text('الطعام');
      final foodCard = find
          .ancestor(of: foodLabel, matching: find.byType(Container))
          .first;
      expect(tester.getSize(foodCard).height, greaterThanOrEqualTo(68));
      await tester.tap(foodLabel);
      expect(nav.ride, 1, reason: 'Coming-soon services must not navigate');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'English Home uses localized labels and respects guest identity',
    (tester) async {
      final nav = RecordingHomeNavigation();
      await pumpHome(
        tester,
        repository: const MockHomeRepository(latency: Duration.zero),
        navigation: nav,
        language: 'en',
        phone: null,
        authenticated: false,
        guest: true,
      );
      expect(find.text('You are browsing as a guest'), findsOneWidget);
      expect(find.text('Where to today?'), findsOneWidget);
      expect(find.text('Coming soon to TAM'), findsOneWidget);
      expect(find.text('Choose your destination'), findsOneWidget);
      expect(find.text('Sign in'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('empty, API unavailable and offline all provide retry', (
    tester,
  ) async {
    final nav = RecordingHomeNavigation();
    await pumpHome(
      tester,
      repository: const MockHomeRepository(
        scenario: HomeMockScenario.empty,
        latency: Duration.zero,
      ),
      navigation: nav,
    );
    expect(find.text('لا يوجد محتوى متاح حاليًا.'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
    await pumpHome(
      tester,
      repository: const UnavailableHomeRepository(),
      navigation: nav,
    );
    expect(
      find.text('خدمة الرئيسية غير متاحة في وضع API حاليًا.'),
      findsOneWidget,
    );
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();
    expect(
      find.text('خدمة الرئيسية غير متاحة في وضع API حاليًا.'),
      findsOneWidget,
      reason: 'Retry cannot fall back to mock data',
    );
    await pumpHome(
      tester,
      repository: const MockHomeRepository(
        scenario: HomeMockScenario.offline,
        latency: Duration.zero,
      ),
      navigation: nav,
    );
    expect(find.textContaining('تعذر تحميل المحتوى'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 390.0, 800.0]) {
    for (final language in ['ar', 'en']) {
      testWidgets('Home layout ${width.toInt()}dp at 2x in $language', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 870);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pumpHome(
          tester,
          repository: const MockHomeRepository(latency: Duration.zero),
          navigation: RecordingHomeNavigation(),
          language: language,
        );
        final target = find.byKey(const Key('home-ride-entry'));
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(
          find.text(language == 'ar' ? 'التسوق' : 'Shopping'),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
