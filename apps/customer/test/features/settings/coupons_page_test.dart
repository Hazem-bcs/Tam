import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/settings/data/mock/mock_coupon_book.dart';
import 'package:tam_customer/features/settings/presentation/pages/coupons_page.dart';
import 'package:tam_customer/features/settings/presentation/widgets/coupon_ticket_shape.dart';
import 'package:tam_customer/features/settings/presentation/widgets/settings_account_links.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

Widget _app(Widget child, {String language = 'ar', double scale = 1}) {
  return MaterialApp(
    locale: Locale(language),
    theme: AppTheme.account(AppTheme.light),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child,
      ),
    ),
  );
}

void main() {
  test(
    'ticket clipper cuts actual edge and seam notches in both directions',
    () {
      const size = Size(342, 150);
      for (final isRtl in [true, false]) {
        final clipper = CouponTicketClipper(
          isRtl: isRtl,
          horizontalSplit: true,
        );
        final path = clipper.getClip(size);
        final outsideEdge = isRtl ? 1.0 : size.width - 1;
        final insideEdge = isRtl ? 15.0 : size.width - 15;
        expect(path.contains(Offset(outsideEdge, size.height * .22)), isFalse);
        expect(path.contains(Offset(insideEdge, size.height * .22)), isTrue);
        final seam = isRtl ? size.width - 113 : 113.0;
        expect(path.contains(Offset(seam, 2)), isFalse);
        expect(path.contains(Offset(seam, 14)), isTrue);
      }
    },
  );

  test('coupon book validates the actual demo booking code', () {
    final book = MockCouponBook();
    addTearDown(book.dispose);
    expect(book.coupons, hasLength(2));
    expect(book.add('wrong'), AddDemoCouponResult.invalid);
    expect(book.add('  tam10 '), AddDemoCouponResult.added);
    expect(book.coupons.first.code, 'TAM10');
    expect(book.coupons.first.percent, 10);
    expect(book.add('TAM10'), AddDemoCouponResult.duplicate);
    expect(book.coupons, hasLength(3));
  });

  testWidgets('account coupon tile invokes its supplied destination', (
    tester,
  ) async {
    var count = 0;
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: SettingsAccountLinks(
            enabled: true,
            destinationsOnly: true,
            onCoupons: () => count++,
            onAddresses: () {},
            onSupport: () {},
            onTerms: () {},
            onPrivacy: () {},
            onChangePhone: () {},
            onDeleteAccount: () {},
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('settings-coupons')));
    expect(count, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Arabic code entry rejects invalid and accepts TAM10', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final book = MockCouponBook();
    addTearDown(book.dispose);
    await tester.pumpWidget(_app(CouponsPage(book: book)));
    await tester.pumpAndSettle();

    expect(find.text('NOW25'), findsOneWidget);
    expect(find.text('SAVE15'), findsOneWidget);
    expect(find.text('10%'), findsNothing);
    await tester.tap(find.byKey(const Key('coupons-add')));
    await tester.pumpAndSettle();
    expect(find.text('إضافة كود حسم'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('coupon-code-input')), 'NOPE');
    await tester.tap(find.text('إضافة').last);
    await tester.pumpAndSettle();
    expect(
      find.text('هذا الكود غير متاح في المعاينة التجريبية.'),
      findsOneWidget,
    );

    await tester.enterText(find.byKey(const Key('coupon-code-input')), 'tam10');
    await tester.tap(find.text('إضافة').last);
    await tester.pumpAndSettle();
    expect(find.text('TAM10'), findsOneWidget);
    expect(find.text('10%'), findsOneWidget);
    expect(book.coupons, hasLength(3));
    expect(tester.takeException(), isNull);
  });

  for (final (size, scale, language) in [
    (const Size(320, 780), 2.0, 'ar'),
    (const Size(390, 844), 1.0, 'ar'),
    (const Size(800, 1000), 2.0, 'en'),
  ]) {
    testWidgets('coupons responsive $size $language x$scale', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final book = MockCouponBook();
      addTearDown(book.dispose);
      await tester.pumpWidget(
        _app(
          CouponsPage(book: book),
          language: language,
          scale: scale,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('coupons-ios-chevron')), findsOneWidget);
      final couponArt = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/notifications/discount_offer.webp',
      );
      expect(couponArt, findsWidgets);
      if (size.width >= 390) {
        expect(find.byKey(const Key('coupon-ticket-cutout')), findsWidgets);
      }
      await tester.tap(find.byKey(const Key('coupons-add')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('coupon-code-input')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
