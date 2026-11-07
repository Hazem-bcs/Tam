import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/auth/domain/phone_number.dart';

/// Six visible slots, one native editable field. The native field retains
/// autofill, clipboard/context menu, selection, keyboard and screen-reader input.
class AuthOtpInput extends StatefulWidget {
  const AuthOtpInput({
    super.key,
    required this.controller,
    required this.label,
    required this.onChanged,
    required this.onSubmitted,
    required this.validator,
    this.errorText,
    this.readOnly = false,
    this.blocked = false,
    this.autofocus = true,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final FormFieldValidator<String> validator;
  final String? errorText;
  final bool readOnly;
  final bool blocked;
  final bool autofocus;

  @override
  State<AuthOtpInput> createState() => _AuthOtpInputState();
}

class _AuthOtpInputState extends State<AuthOtpInput> {
  final _focus = FocusNode();
  final _field = GlobalKey<FormFieldState<String>>();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_rebuild);
    widget.controller.addListener(_update);
  }

  @override
  void didUpdateWidget(AuthOtpInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_update);
      widget.controller.addListener(_update);
    }
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  void _update() {
    _field.currentState?.didChange(widget.controller.text);
    _rebuild();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    _focus.removeListener(_rebuild);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final motion = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 160);
    final digitStyle = theme.textTheme.headlineSmall!;
    return FormField<String>(
      key: _field,
      initialValue: widget.controller.text,
      validator: widget.validator,
      forceErrorText: widget.errorText,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final digitSize = MediaQuery.textScalerOf(
                context,
              ).scale(digitStyle.fontSize!);
              final minCell = digitSize + AppSpacing.lg;
              const gap = AppSpacing.sm;
              var columns = 1;
              for (final candidate in [6, 3, 2]) {
                if (candidate * minCell + (candidate - 1) * gap <=
                    constraints.maxWidth) {
                  columns = candidate;
                  break;
                }
              }
              final width =
                  (constraints.maxWidth - (columns - 1) * gap) / columns;
              final height = max(
                56.0,
                digitSize * (digitStyle.height ?? 1.4) + AppSpacing.lg,
              );
              final text = widget.controller.text;
              final cursor = widget.controller.selection.isValid
                  ? widget.controller.selection.extentOffset.clamp(0, 5)
                  : text.length.clamp(0, 5);
              return Directionality(
                textDirection: TextDirection.ltr,
                child: Stack(
                  children: [
                    ExcludeSemantics(
                      child: Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: List.generate(6, (index) {
                          final filled = index < text.length;
                          final active =
                              _focus.hasFocus &&
                              cursor == index &&
                              !widget.readOnly &&
                              !widget.blocked;
                          final invalid = field.hasError;
                          final border = invalid
                              ? colors.error
                              : active
                              ? colors.primary
                              : colors.outlineVariant;
                          return AnimatedContainer(
                            key: ValueKey('otp-slot-$index'),
                            duration: motion,
                            width: width,
                            height: height,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: widget.blocked
                                  ? colors.surfaceContainer
                                  : filled
                                  ? colors.primaryContainer.withValues(
                                      alpha: .40,
                                    )
                                  : colors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(AppRadii.md),
                              border: Border.all(
                                color: border,
                                width: active || invalid
                                    ? AppDimensions.focusBorderWidth
                                    : AppDimensions.borderWidth,
                              ),
                            ),
                            child: Text(
                              filled ? text[index] : '–',
                              style: digitStyle.copyWith(
                                color: widget.blocked
                                    ? colors.onSurfaceVariant
                                    : filled
                                    ? colors.onSurface
                                    : colors.outline,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0,
                        alwaysIncludeSemantics: true,
                        child: TextField(
                          controller: widget.controller,
                          focusNode: _focus,
                          autofocus:
                              widget.autofocus &&
                              !widget.blocked &&
                              !widget.readOnly,
                          readOnly: widget.readOnly || widget.blocked,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          textDirection: TextDirection.ltr,
                          autofillHints: const [AutofillHints.oneTimeCode],
                          autocorrect: false,
                          enableSuggestions: false,
                          inputFormatters: [
                            TextInputFormatter.withFunction(
                              (_, next) => next.copyWith(
                                text: normalizeDigits(next.text),
                                composing: TextRange.empty,
                              ),
                            ),
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          decoration: InputDecoration(labelText: widget.label),
                          onChanged: widget.onChanged,
                          onSubmitted: (_) {
                            if (!widget.readOnly && !widget.blocked) {
                              widget.onSubmitted();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (field.hasError) ...[
            const SizedBox(height: AppSpacing.sm),
            Semantics(
              liveRegion: true,
              child: Text(
                field.errorText!,
                style: theme.inputDecorationTheme.errorStyle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
