import 'package:flutter/widgets.dart';

/// Normalized logical cursor location within a short numeric field.
///
/// Uses the actual caret, not total input length: editing an earlier digit
/// moves the mascot back toward that character. Values are clamped at the
/// valid digit count, so very long invalid input cannot break the eye rig.
double authCaretProgress(TextEditingValue value, {required int maxDigits}) {
  assert(maxDigits > 0);
  final cursor = value.selection.extentOffset;
  final safeCursor = (cursor < 0 ? value.text.length : cursor).clamp(
    0,
    value.text.length,
  );
  final beforeCaret = value.text.substring(0, safeCursor);
  final count = RegExp(r'[0-9٠-٩]').allMatches(beforeCaret).length;
  return count.clamp(0, maxDigits) / maxDigits;
}
