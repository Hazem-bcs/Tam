import 'package:flutter/widgets.dart';
import 'package:tam_customer/features/settings/data/mock/mock_coupon_book.dart';

/// A single in-memory demo coupon collection for the current app session.
///
/// Home and Account read the same instance. The application owns its lifetime
/// and clears it when the user session ends. No codes reach an API or wallet.
class CouponBookScope extends InheritedWidget {
  const CouponBookScope({super.key, required this.book, required super.child});

  final MockCouponBook book;

  static MockCouponBook? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CouponBookScope>()?.book;

  @override
  bool updateShouldNotify(covariant CouponBookScope oldWidget) =>
      !identical(book, oldWidget.book);
}
