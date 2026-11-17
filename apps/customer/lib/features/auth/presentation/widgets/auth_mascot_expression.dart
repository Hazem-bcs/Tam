/// One expression wins when form events overlap; OTP is only scene context.
enum AuthMascotExpression { idle, focus, waiting, error, success }

AuthMascotExpression resolveAuthMascotExpression({
  required bool inputFocused,
  required bool busy,
  required bool hasError,
  required bool success,
}) {
  if (success) return AuthMascotExpression.success;
  if (hasError) return AuthMascotExpression.error;
  if (busy) return AuthMascotExpression.waiting;
  if (inputFocused) return AuthMascotExpression.focus;
  return AuthMascotExpression.idle;
}
