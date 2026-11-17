import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_coupon_banner.dart';
import 'package:tam_customer/features/settings/data/mock/mock_coupon_book.dart';
import 'package:tam_customer/features/settings/presentation/coupon_book_scope.dart';
import 'package:tam_customer/features/settings/presentation/pages/coupons_page.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

Widget _app(MockCouponBook book, {String language = 'ar'}) {
  return MaterialApp(
    theme: AppTheme.light,
    locale: Locale(language),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: CouponBookScope(
      book: book,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const HomeCouponBanner(),
              Builder(
                builder: (context) => TextButton(
                  key: const Key('show-account-coupons'),
                  onPressed: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CouponsPage(book: CouponBookScope.maybeOf(context)!),
                    ),
                  ),
                  child: const Text('Show wallet'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'home opens the existing coupon entry and shares it with Account',
    (tester) async {
      final book = MockCouponBook();
      addTearDown(book.dispose);
      await tester.pumpWidget(_app(book));
      await tester.pumpAndSettle();

      expect(find.text('إضافة'), findsOneWidget);
      await tester.tap(find.byKey(const Key('home-coupon-details')));
      await tester.pumpAndSettle();
      expect(find.text('إضافة كود حسم'), findsOneWidget);
      expect(find.byKey(const Key('coupon-code-input')), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('coupon-code-input')),
        'INVALID',
      );
      await tester.tap(find.text('إضافة').last);
      await tester.pumpAndSettle();
      expect(
        find.text('هذا الكود غير متاح في المعاينة التجريبية.'),
        findsOneWidget,
      );
      expect(book.coupons, hasLength(2));

      await tester.enterText(
        find.byKey(const Key('coupon-code-input')),
        'tam10',
      );
      await tester.tap(find.text('إضافة').last);
      await tester.pumpAndSettle();

      expect(book.coupons.first.code, 'TAM10');
      expect(book.coupons.first.isAvailable, isTrue);
      expect(book.coupons, hasLength(3));
      expect(find.text('تمت إضافة الكوبون التجريبي'), findsOneWidget);

      await tester.tap(find.byKey(const Key('show-account-coupons')));
      await tester.pumpAndSettle();
      expect(find.text('أكواد الحسم'), findsOneWidget);
      expect(find.text('TAM10'), findsOneWidget);
      expect(find.text('10%'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('cancel and duplicate entry never create an extra discount', (
    tester,
  ) async {
    final book = MockCouponBook();
    addTearDown(book.dispose);
    await tester.pumpWidget(_app(book, language: 'en'));
    await tester.tap(find.byKey(const Key('home-coupon-details')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();
    expect(book.coupons, hasLength(2));

    book.add('TAM10');
    await tester.tap(find.byKey(const Key('home-coupon-details')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('coupon-code-input')), 'TAM10');
    await tester.tap(find.text('Add').last);
    await tester.pumpAndSettle();
    expect(find.text('You have already added this code.'), findsOneWidget);
    expect(book.coupons, hasLength(3));
    expect(tester.takeException(), isNull);
  });

  test('session reset clears the added code but not the expired fixtures', () {
    final book = MockCouponBook();
    addTearDown(book.dispose);
    expect(book.add('TAM10'), AddDemoCouponResult.added);
    expect(book.coupons, hasLength(3));
    book.resetSession();
    expect(book.coupons, hasLength(2));
    expect(book.coupons.every((c) => !c.isAvailable), isTrue);
  });
}
