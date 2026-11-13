import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';

/// A primary action or an outlined secondary action using native button states.
/// In a Row, wrap a full-width button in Expanded, or set fullWidth to false.
class TamButton extends StatelessWidget {
  const TamButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.loadingLabel,
    this.fullWidth = true,
  }) : _primary = true;

  const TamButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.loadingLabel,
    this.fullWidth = true,
  }) : _primary = false;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final String? loadingLabel;
  final bool fullWidth;
  final bool _primary;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final callback = isLoading ? null : onPressed;
    // Loading blocks activation while retaining the action's visual identity.
    final loadingStyle = isLoading
        ? ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(
              _primary ? colors.onPrimary : colors.primary,
            ),
            backgroundColor: _primary
                ? WidgetStatePropertyAll(colors.primary)
                : null,
            side: _primary
                ? null
                : WidgetStatePropertyAll(BorderSide(color: colors.primary)),
          )
        : null;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          ExcludeSemantics(
            child: TamLoadingIndicator(
              size: AppDimensions.buttonProgressSize,
              color: _primary ? colors.onPrimary : colors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (icon != null) ...[
          Icon(
            icon,
            size: IconTheme.of(context).size ?? AppDimensions.iconSize,
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            isLoading ? loadingLabel ?? label : label,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    return Semantics(
      liveRegion: isLoading,
      child: SizedBox(
        width: fullWidth ? double.infinity : null,
        child: _primary
            ? FilledButton(
                onPressed: callback,
                style: loadingStyle,
                child: content,
              )
            : OutlinedButton(
                onPressed: callback,
                style: loadingStyle,
                child: content,
              ),
      ),
    );
  }
}
