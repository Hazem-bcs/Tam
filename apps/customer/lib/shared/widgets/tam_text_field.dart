import 'package:flutter/material.dart';

/// A form-aware input styled by the application's InputDecorationTheme.
/// The caller owns controllers, focus nodes, validation and localized copy.
class TamTextField extends StatelessWidget {
  const TamTextField({
    super.key,
    required this.labelText,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.hintText,
    this.helperText,
    this.errorText,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.textDirection,
    this.autofillHints,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.maxLines = 1,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  }) : assert(controller == null || initialValue == null),
       assert(maxLines == null || maxLines > 0),
       assert(!obscureText || maxLines == 1);

  final String labelText;
  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextDirection? textDirection;
  final Iterable<String>? autofillHints;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final int? maxLines;
  final AutovalidateMode autovalidateMode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textDirection: textDirection,
      textAlign: TextAlign.start,
      autofillHints: autofillHints,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      forceErrorText: errorText,
      autovalidateMode: autovalidateMode,
      // Let errors wrap naturally, including at large accessibility text scales.
      errorBuilder: (context, error) =>
          Text(error, style: Theme.of(context).inputDecorationTheme.errorStyle),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        alignLabelWithHint: maxLines != 1,
      ),
    );
  }
}
