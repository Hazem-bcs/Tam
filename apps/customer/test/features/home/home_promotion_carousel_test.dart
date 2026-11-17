import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/home/domain/entities/home_content.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_promotion_carousel.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

void main() {
  const first = HomePromotion(
    id: 'first',
    kind: HomePromotionKind.hero,
    title: HomeLocalizedText(ar: 'خبر تم الأول', en: 'First update'),
    subtitle: HomeLocalizedText(ar: 'وصف أول', en: 'First description'),
    enabled: true,
    action: HomeAction.rideRequest,
  );
  const second = HomePromotion(
    id: 'second',
    kind: HomePromotionKind.announcement,
    title: HomeLocalizedText(ar: 'خبر تم الثاني', en: 'Second update'),
    subtitle: HomeLocalizedText(ar: 'وصف ثان', en: 'Second description'),
    enabled: true,
    action: null,
  );
  const disabled = HomePromotion(
    id: 'disabled',
    kind: HomePromotionKind.announcement,
    title: HomeLocalizedText(ar: 'غير منشور', en: 'Not published'),
    subtitle: HomeLocalizedText(ar: 'مخفي', en: 'Hidden'),
    enabled: false,
    action: null,
  );

  Future<void> pumpCarousel(
    WidgetTester tester, {
    required List<HomePromotion> promotions,
    bool reducedMotion = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: reducedMotion),
          child: child!,
        ),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 390,
              child: HomePromotionCarousel(promotions: promotions),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('disabled campaigns are omitted entirely', (tester) async {
    await pumpCarousel(tester, promotions: const [disabled]);
    expect(find.text('غير منشور'), findsNothing);
    expect(find.byType(PageView), findsNothing);
  });

  testWidgets('promotions do not duplicate ride navigation', (tester) async {
    await pumpCarousel(tester, promotions: const [first]);
    final slider = find.byKey(const Key('home-promotions-slider'));
    expect(slider, findsOneWidget);
    final firstSlide = find.text('خبر تم الأول');
    expect(firstSlide, findsOneWidget);
    expect(find.byType(InkWell), findsNothing);
  });

  testWidgets('ads fill the available width without clipped neighbor slides', (
    tester,
  ) async {
    await pumpCarousel(tester, promotions: const [first, second]);
    final slider = find.byKey(const Key('home-promotions-slider'));
    final pageView = tester.widget<PageView>(slider);
    expect(pageView.controller.viewportFraction, 1.0);
    final viewport = tester.getRect(slider);
    final slide = tester.getRect(
      find.byKey(const Key('home-promotion-slide-0')),
    );
    expect(slide.left, closeTo(viewport.left, 0.1));
    expect(slide.right, closeTo(viewport.right, 0.1));
    expect(find.text('إعلانات تم'), findsOneWidget);
  });

  testWidgets('ads advance automatically and wrap to the first card', (
    tester,
  ) async {
    await pumpCarousel(tester, promotions: const [first, second]);
    expect(find.text('1 / 2'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 450));
    expect(find.text('2 / 2'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 450));
    expect(find.text('1 / 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion keeps ads still until the user swipes', (
    tester,
  ) async {
    await pumpCarousel(
      tester,
      promotions: const [first, second],
      reducedMotion: true,
    );
    await tester.pump(const Duration(seconds: 7));
    expect(find.text('1 / 2'), findsOneWidget);
    await tester.drag(
      find.byKey(const Key('home-promotions-slider')),
      const Offset(310, 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('2 / 2'), findsOneWidget);
  });

  testWidgets('approved informational campaigns swipe manually', (
    tester,
  ) async {
    await pumpCarousel(tester, promotions: const [first, second, disabled]);
    expect(find.text('خبر تم الأول'), findsOneWidget);
    expect(find.text('غير منشور'), findsNothing);
    await tester.drag(
      find.byKey(const Key('home-promotions-slider')),
      const Offset(310, 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('خبر تم الثاني'), findsOneWidget);
    expect(find.text('2 / 2'), findsOneWidget);
  });
}
