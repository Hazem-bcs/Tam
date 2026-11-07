import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/home/data/mock/mock_home_repository.dart';
import 'package:tam_customer/features/home/data/unavailable_home_repository.dart';
import 'package:tam_customer/features/home/presentation/pages/home_page.dart';

import 'home_test_support.dart';

void main() {
  testWidgets(
    'Arabic phone aligns with the greeting while its text stays LTR',
    (tester) async {
      await pumpHome(
        tester,
        repository: const MockHomeRepository(latency: Duration.zero),
        navigation: RecordingHomeNavigation(),
      );
      final phone = find.text('+963941234567');
      expect(
        tester.getTopRight(phone).dx,
        closeTo(tester.getTopRight(find.text('تم تسجيل الدخول')).dx, 0.01),
      );
      expect(tester.widget<Text>(phone).textDirection, TextDirection.ltr);
    },
  );
  testWidgets('Arabic Home shows sections and uses only navigation callbacks', (
    tester,
  ) async {
    final nav = RecordingHomeNavigation();
    var logouts = 0;
    await pumpHome(
      tester,
      repository: const MockHomeRepository(latency: Duration.zero),
      navigation: nav,
      onLogout: () => logouts++,
    );
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('تم تسجيل الدخول'), findsOneWidget);
    expect(find.text('+963941234567'), findsOneWidget);
    expect(find.text('مشوارك أسهل مع تم'), findsOneWidget);
    expect(find.text('مزايا جديدة في الطريق'), findsOneWidget);
    expect(find.text('اختر خدمتك'), findsOneWidget);
    expect(find.text('قريبًا'), findsNWidgets(3));

    await tester.tap(find.byKey(const Key('home-notifications')));
    expect(nav.notifications, 1);
    await tester.ensureVisible(
      find.text('حدد نقطة الانطلاق والوجهة لطلب رحلة'),
    );
    await tester.tap(find.text('حدد نقطة الانطلاق والوجهة لطلب رحلة'));
    expect(nav.ride, 1);
    await tester.ensureVisible(find.text('مشوار'));
    await tester.tap(find.text('مشوار'));
    expect(nav.ride, 2);
    await tester.ensureVisible(find.text('الطعام'));
    await tester.tap(find.text('الطعام'));
    expect(nav.ride, 2, reason: 'Unavailable service must not navigate');

    await tester.tap(find.text('طلباتي'));
    await tester.tap(find.text('الإعدادات'));
    expect(nav.trips, 1);
    expect(nav.settings, 1);
    await tester.ensureVisible(find.text('تسجيل الخروج'));
    await tester.tap(find.text('تسجيل الخروج'));
    expect(logouts, 1);
    expect(tester.takeException(), isNull);
  });

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
      expect(find.text('Where to?'), findsOneWidget);
      expect(find.text('Coming soon'), findsNWidgets(3));
      expect(find.text('Ride'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
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
        final target = language == 'ar'
            ? 'مشوارك أسهل مع تم'
            : 'Getting there is easier with Tam';
        await tester.ensureVisible(find.text(target));
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
