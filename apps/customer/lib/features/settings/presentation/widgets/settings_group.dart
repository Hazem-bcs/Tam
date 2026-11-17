import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';

/// A quiet, unified list surface rather than a stack of unrelated cards.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final typography = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: AppSpacing.xs,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            title,
            style: typography.titleSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Material(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadii.md),
          clipBehavior: Clip.antiAlias,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: colors.outlineVariant),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i != 0)
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Divider(
                        color: colors.outlineVariant.withValues(alpha: 0.75),
                        height: AppDimensions.borderWidth,
                      ),
                    ),
                  children[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
