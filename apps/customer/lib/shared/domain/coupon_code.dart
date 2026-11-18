import 'normalize_digits.dart';

/// Coupon identifiers preserve Arabic letters; only Latin case, surrounding
/// whitespace and equivalent digit scripts are normalized for comparison.
String normalizeCouponCode(String value) => normalizeDigits(
  value.trim(),
).replaceAllMapped(RegExp('[a-z]'), (match) => match[0]!.toUpperCase());

bool couponCodeIsRtl(String value) =>
    RegExp(r'[\u0600-\u06ff\u0750-\u077f\u08a0-\u08ff]').hasMatch(value);

/// Canonical transport identifiers: Latin capitals, Arabic letters/marks,
/// normalized digits, underscore and hyphen; no whitespace or bidi controls.
bool isCanonicalCouponCode(String value) => RegExp(
  r'^[A-Z0-9_\-\u0621-\u063a\u0640-\u065f\u0671-\u06d3\u06fa-\u06fc]{1,32}$',
  unicode: true,
).hasMatch(value);
