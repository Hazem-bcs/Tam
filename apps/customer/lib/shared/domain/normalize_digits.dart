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
