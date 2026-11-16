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
    required VoidCallback onRideRequest,
    bool rideAvailable = true,
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
              child: HomePromotionCarousel(
                promotions: promotions,
                onRideRequest: onRideRequest,
                rideAvailable: rideAvailable,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('disabled or absent campaigns are not shown', (tester) async {
    await pumpCarousel(
      tester,
      promotions: const [disabled],
      onRideRequest: () {},
    );
    expect(find.text('غير منشور'), findsNothing);
    expect(find.byType(PageView), findsNothing);
  });

  testWidgets('only available ride promotions can trigger booking', (
    tester,
  ) async {
    var taps = 0;
    await pumpCarousel(
      tester,
      promotions: const [first],
      onRideRequest: () => taps++,
      rideAvailable: false,
    );
    await tester.tap(find.text('خبر تم الأول'));
    expect(taps, 0);
    await pumpCarousel(
      tester,
      promotions: const [first],
      onRideRequest: () => taps++,
    );
    await tester.tap(find.text('خبر تم الأول'));
    expect(taps, 1);
  });

  testWidgets('promotions swipe manually without fabricated slides', (
    tester,
  ) async {
    await pumpCarousel(
      tester,
      promotions: const [first, second, disabled],
      onRideRequest: () {},
    );
    expect(find.text('خبر تم الأول'), findsOneWidget);
    expect(find.text('غير منشور'), findsNothing);
    await tester.drag(find.byType(PageView), const Offset(300, 0));
    await tester.pumpAndSettle();
    expect(find.text('خبر تم الثاني'), findsOneWidget);
  });
}
