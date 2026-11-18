import 'package:flutter/services.dart';
import 'package:tam_customer/features/auth/domain/phone_number.dart';

/// Edits the local part beside the fixed +963 prefix without changing Auth's
/// canonical number contract. Complete international pastes remain supported.
final class NationalPhoneFormatter extends TextInputFormatter {
  const NationalPhoneFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final normalized = normalizeDigits(newValue.text);
    final digits = normalized.replaceAll(RegExp(r'[^0-9]'), '');
    final international = normalizeSyrianPhone(normalized);
    final hasCountry =
        international != null &&
        (normalized.startsWith('+963') ||
            digits.startsWith('00963') ||
            (digits.startsWith('963') && digits.length == 12));
    final removed = hasCountry ? digits.length - 9 : 0;
    final local = hasCountry ? international.substring(4) : digits;
    final text = local.substring(0, local.length.clamp(0, 10));
    int offset(int original) {
      if (original < 0) return text.length;
      final before = normalizeDigits(
        newValue.text.substring(0, original.clamp(0, newValue.text.length)),
      ).replaceAll(RegExp(r'[^0-9]'), '').length;
      return (before - removed).clamp(0, text.length);
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection(
        baseOffset: offset(newValue.selection.baseOffset),
        extentOffset: offset(newValue.selection.extentOffset),
        affinity: newValue.selection.affinity,
        isDirectional: newValue.selection.isDirectional,
      ),
    );
  }
}
