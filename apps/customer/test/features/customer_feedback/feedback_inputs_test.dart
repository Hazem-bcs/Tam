import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/features/auth/domain/phone_number.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_phone_field.dart';
import 'package:tam_customer/features/auth/presentation/widgets/national_phone_formatter.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_coupon_field.dart';
import 'package:tam_customer/features/settings/data/mock/mock_coupon_book.dart';
import 'package:tam_customer/features/settings/presentation/widgets/coupon_entry_sheet.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/data/trip_wire_codec.dart';
import 'package:tam_customer/shared/domain/coupon_code.dart';

void main() {
  const formatter = NationalPhoneFormatter();
  TextEditingValue edit(String text, {int? cursor}) =>
      formatter.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: cursor ?? text.length),
        ),
      );
  test(
    'phone typing/paste normalizes digits, limits local length and validates',
    () {
      for (final input in ['0912345678999', '٠٩١٢٣٤٥٦٧٨٩٩٩', '۰۹۱۲۳۴۵۶۷۸۹۹۹']) {
        final value = edit(input);
        expect(value.text, '0912345678');
        expect(value.selection.extentOffset, 10);
        expect(
          normalizeSyrianPhone(phoneEntryForRequest(value.text)),
          '+963912345678',
        );
      }
      for (final input in [
        '+963 912 345 678',
        '00963912345678',
        '963912345678',
      ]) {
        expect(edit(input).text, '912345678');
      }
      expect(edit('09a1-2').text, '0912');
      expect(edit('09a1-2', cursor: 4).selection.extentOffset, 3);
      expect(edit('0912345678', cursor: 3).selection.extentOffset, 3);
      expect(edit('091234567', cursor: 3).selection.extentOffset, 3);
      for (final input in [
        '123456789',
        '91234567',
        '091234567',
        '0812345678',
      ]) {
        expect(
          normalizeSyrianPhone(phoneEntryForRequest(edit(input).text)),
          isNull,
        );
      }
    },
  );
  test(
    'Arabic coupon identity survives normalization, transport and session reset',
    () {
      final book = MockCouponBook();
      addTearDown(book.dispose);
      expect(normalizeCouponCode('  تم١٠  '), 'تم10');
      expect(normalizeCouponCode('  tam10  '), 'TAM10');
      expect(book.add('تم١٠'), AddDemoCouponResult.added);
      expect(book.coupons.first.code, 'تم10');
      expect(TripWireCodec.couponCode('تم10'), 'تم10');
      expect(book.add('تم۱۰'), AddDemoCouponResult.duplicate);
      expect(book.add('tam10'), AddDemoCouponResult.added);
      expect(book.add('تم11'), AddDemoCouponResult.invalid);
      for (final invalid in [
        'تم\u202e10',
        'تم 10',
        List.filled(33, 'X').join(),
      ]) {
        expect(() => TripWireCodec.couponCode(invalid), throwsFormatException);
      }
      book.resetSession();
      expect(book.coupons.where((coupon) => coupon.isAvailable), isEmpty);
    },
  );
  for (final language in ['ar', 'en']) {
    testWidgets('phone edits remain LTR and bounded in $language', (
      tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        _host(
          language: language,
          child: AuthPhoneField(
            controller: controller,
            label: 'Phone',
            hint: '',
            invalidMessage: 'Invalid',
            semanticLabel: 'Phone +963',
            onChanged: (_) {},
            onSubmitted: () {},
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField), '٠٩١٢٣٤٥٦٧٨٩٩');
      expect(controller.text, '0912345678');
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).textDirection,
        TextDirection.ltr,
      );
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '0912345678',
          selection: TextSelection.collapsed(offset: 3),
        ),
      );
      await tester.pump();
      expect(controller.selection.extentOffset, 3);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    });
    testWidgets(
      'Arabic and Latin coupons can be pasted and re-edited in $language',
      (tester) async {
        String? applied;
        await tester.pumpWidget(
          _host(
            language: language,
            child: RideCouponField(
              code: null,
              quote: null,
              enabled: true,
              loading: false,
              invalid: false,
              onApply: (code) => applied = code,
              onRemove: () {},
            ),
          ),
        );
        final input = find.byKey(const Key('ride-coupon-input'));
        await tester.enterText(input, 'تم١٠');
        await tester.pump();
        expect(
          tester.widget<EditableText>(find.byType(EditableText)).textDirection,
          TextDirection.rtl,
        );
        await tester.tap(find.byKey(const Key('ride-coupon-apply')));
        expect(applied, 'تم١٠');
        await tester.enterText(input, 'tam10');
        await tester.pump();
        expect(
          tester.widget<EditableText>(find.byType(EditableText)).textDirection,
          TextDirection.ltr,
        );
        await tester.tap(find.byKey(const Key('ride-coupon-apply')));
        expect(applied, 'tam10');
        expect(tester.takeException(), isNull);
      },
    );
    testWidgets(
      'coupon sheet stays usable at 320dp, large text and open keyboard in $language',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        tester.view.viewInsets = const FakeViewPadding(bottom: 260);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        final book = MockCouponBook();
        addTearDown(book.dispose);
        await tester.pumpWidget(
          _host(
            language: language,
            scale: 2,
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () => showCouponEntrySheet(context, book: book),
                child: const Text('open'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        final field = find.byKey(const Key('coupon-code-input'));
        await tester.ensureVisible(field);
        await tester.enterText(field, 'تم١٠');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(book.coupons.first.code, 'تم10');
        expect(tester.takeException(), isNull);
      },
    );
  }
}

Widget _host({
  required Widget child,
  String language = 'ar',
  double scale = 1,
}) => MaterialApp(
  theme: AppTheme.light,
  locale: Locale(language),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: Scaffold(body: SafeArea(child: child)),
    ),
  ),
);
