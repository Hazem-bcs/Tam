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
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
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
