/// Normalizes Arabic/Persian digits without translating personal data.
String normalizeDigits(String input) {
  return String.fromCharCodes(
    input.runes.map((value) {
      if (value >= 0x0660 && value <= 0x0669) return value - 0x0660 + 0x30;
      if (value >= 0x06F0 && value <= 0x06F9) return value - 0x06F0 + 0x30;
      return value;
    }),
  );
}

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
