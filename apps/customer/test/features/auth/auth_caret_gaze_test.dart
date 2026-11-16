import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_caret_gaze.dart';

void main() {
  test(
    'caret location follows numeric characters, not total string length',
    () {
      const text = '912345678';
      expect(
        authCaretProgress(
          const TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: 0),
          ),
          maxDigits: 9,
        ),
        0,
      );
      expect(
        authCaretProgress(
          const TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: 4),
          ),
          maxDigits: 9,
        ),
        closeTo(4 / 9, 0.0001),
      );
      expect(
        authCaretProgress(
          const TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: 9),
          ),
          maxDigits: 9,
        ),
        1,
      );
    },
  );

  test('formatting, Arabic digits, and invalid-length input are safe', () {
    expect(
      authCaretProgress(
        const TextEditingValue(
          text: '٩١٢ ٣٤٥',
          selection: TextSelection.collapsed(offset: 7),
        ),
        maxDigits: 9,
      ),
      closeTo(6 / 9, 0.0001),
    );
    expect(
      authCaretProgress(
        const TextEditingValue(text: '91234567888888888'),
        maxDigits: 9,
      ),
      1,
    );
    expect(
      authCaretProgress(const TextEditingValue(text: '123'), maxDigits: 6),
      0.5,
    );
  });
}
