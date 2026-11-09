/// Strict calendar validation: DateTime.parse alone normalizes invalid dates.
abstract final class UtcTimestamp {
  static DateTime parse(Object? value) {
    if (value is! String) throw const FormatException('Expected UTC timestamp');
    final match = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(?:\.\d{1,6})?Z$',
    ).firstMatch(value);
    final parsed = DateTime.tryParse(value);
    if (match == null || parsed == null || !parsed.isUtc) {
      throw const FormatException('Expected ISO-8601 UTC Z');
    }
    final components = [
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
    ];
    for (var i = 0; i < components.length; i++) {
      if (components[i] != int.parse(match.group(i + 1)!)) {
        throw const FormatException('Invalid calendar timestamp');
      }
    }
    return parsed;
  }
}
