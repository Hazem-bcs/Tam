import 'package:intl/intl.dart';
import 'package:tam_customer/shared/domain/trip.dart';

String rideFareFormat(Money money, String locale, {int? amountMinor}) {
  final scale = List.filled(money.minorUnit, 10).fold<int>(1, (a, b) => a * b);
  return NumberFormat.decimalPatternDigits(
    locale: locale,
    decimalDigits: money.minorUnit,
  ).format((amountMinor ?? money.amountMinor) / scale);
}
