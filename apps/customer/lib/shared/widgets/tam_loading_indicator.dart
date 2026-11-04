import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';

/// A compact progress indicator. Supply a localized label when used alone.
class TamLoadingIndicator extends StatelessWidget {
  const TamLoadingIndicator({
    super.key,
    this.semanticLabel,
    this.value,
    this.size = AppDimensions.progressSize,
    this.color,
  }) : assert(value == null || (value >= 0 && value <= 1)),
       assert(size > 0);

  final String? semanticLabel;
  final double? value;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(
        value: value,
        color: color,
        semanticsLabel: semanticLabel,
        strokeWidth: AppDimensions.progressStroke,
      ),
    );
  }
}
