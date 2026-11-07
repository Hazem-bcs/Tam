import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/auth/domain/phone_number.dart';

/// The country prefix is presentation-only. The existing domain normalizer
/// continues to receive the full number and retains all of its existing rules.
String phoneEntryForRequest(String input) {
  final digits = normalizeDigits(input).replaceAll(RegExp(r'[\s()\-]'), '');
  return RegExp(r'^9\d{8}$').hasMatch(digits) ? '+963$digits' : input;
}

String nationalPhoneEntry(String input) {
  final international = normalizeSyrianPhone(input);
  return international == null
      ? normalizeDigits(input)
      : international.substring(4);
}

class AuthPhoneField extends StatelessWidget {
  const AuthPhoneField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.invalidMessage,
    required this.semanticLabel,
    required this.onChanged,
    required this.onSubmitted,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String invalidMessage;
  final String semanticLabel;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final direction = Directionality.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(child: Text(label, style: theme.textTheme.labelLarge)),
        const SizedBox(height: AppSpacing.sm),
        Directionality(
          textDirection: TextDirection.ltr,
          child: MergeSemantics(
            child: Semantics(
              label: semanticLabel,
              child: TextFormField(
                controller: controller,
                readOnly: readOnly,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.telephoneNumber],
                textDirection: TextDirection.ltr,
                style: theme.textTheme.bodyMedium,
                onFieldSubmitted: (_) => onSubmitted(),
                onChanged: onChanged,
                validator: (value) =>
                    normalizeSyrianPhone(phoneEntryForRequest(value ?? '')) ==
                        null
                    ? invalidMessage
                    : null,
                inputFormatters: [
                  TextInputFormatter.withFunction((_, next) {
                    final text = nationalPhoneEntry(next.text);
                    return next.copyWith(
                      text: text,
                      selection: text.length == next.text.length
                          ? next.selection
                          : TextSelection.collapsed(offset: text.length),
                      composing: TextRange.empty,
                    );
                  }),
                ],
                errorBuilder: (context, error) => Directionality(
                  textDirection: direction,
                  child: Text(
                    error,
                    style: theme.inputDecorationTheme.errorStyle,
                  ),
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  prefixIconConstraints: const BoxConstraints(
                    minHeight: AppDimensions.controlMinHeight,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: AppSpacing.lg,
                      end: AppSpacing.md,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ExcludeSemantics(
                          child: Text(
                            '+963',
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Container(
                          width: AppDimensions.borderWidth,
                          height: AppDimensions.iconSize,
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
