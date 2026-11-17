import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';

/// A quiet, reusable surface within the trip-completion feature.
class CompletionSurface extends StatelessWidget {
  const CompletionSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.sheet),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        child: child,
      ),
    );
  }
}
