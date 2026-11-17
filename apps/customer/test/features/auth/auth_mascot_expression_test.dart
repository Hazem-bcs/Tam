import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_mascot_expression.dart';

void main() {
  test('a higher priority expression suppresses overlapping form events', () {
    const expected = [
      AuthMascotExpression.idle,
      AuthMascotExpression.focus,
      AuthMascotExpression.waiting,
      AuthMascotExpression.waiting,
      AuthMascotExpression.error,
      AuthMascotExpression.error,
      AuthMascotExpression.error,
      AuthMascotExpression.error,
      AuthMascotExpression.success,
      AuthMascotExpression.success,
      AuthMascotExpression.success,
      AuthMascotExpression.success,
      AuthMascotExpression.success,
      AuthMascotExpression.success,
      AuthMascotExpression.success,
      AuthMascotExpression.success,
    ];
    for (var mask = 0; mask < expected.length; mask++) {
      expect(
        resolveAuthMascotExpression(
          inputFocused: mask & 1 != 0,
          busy: mask & 2 != 0,
          hasError: mask & 4 != 0,
          success: mask & 8 != 0,
        ),
        expected[mask],
        reason: 'Overlapping expression mask: $mask',
      );
    }
  });
}
