import 'package:tam_customer/shared/domain/normalize_digits.dart';

export 'package:tam_customer/shared/domain/normalize_digits.dart';

/// Supported region: Syrian mobile numbers. Returns null for invalid input.
/// Other supported regions must be agreed with Backend before adding them.
String? normalizeSyrianPhone(String input) {
  var phone = normalizeDigits(input).replaceAll(RegExp(r'[\s()\-]'), '');
  if (phone.startsWith('00963')) phone = '+963${phone.substring(5)}';
  if (RegExp(r'^9639\d{8}$').hasMatch(phone)) phone = '+$phone';
  if (RegExp(r'^09\d{8}$').hasMatch(phone)) {
    phone = '+963${phone.substring(1)}';
  }
  return RegExp(r'^\+9639\d{8}$').hasMatch(phone) ? phone : null;
}
