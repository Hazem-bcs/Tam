import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';

/// Compact, wrapping choices grow naturally with translations and text scaling.
class CompletionFeedbackOptions extends StatelessWidget {
  const CompletionFeedbackOptions({
    super.key,
    required this.labels,
    required this.positive,
    required this.selected,
    required this.enabled,
    required this.onToggle,
  }) : assert(labels.length == 3);
  final List<String> labels;
  final bool positive, enabled;
  final Set<int> selected;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assets = positive
        ? const ['account', 'ride_completed', 'rating']
        : const ['ride_scheduled', 'warning', 'support'];
    return LayoutBuilder(
      builder: (context, bounds) => Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
        children: [
          for (var i = 0; i < labels.length; i++)
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: bounds.maxWidth),
              child: FilterChip(
                key: ValueKey('completion-tag-$i'),
                avatar: Image.asset(
                  'assets/notifications/${assets[i]}.webp',
                  width: 24,
                  height: 24,
                  excludeFromSemantics: true,
                ),
                label: Text(labels[i], softWrap: true),
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  color: selected.contains(i)
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                ),
                selected: selected.contains(i),
                showCheckmark: true,
                selectedColor: theme.colorScheme.primaryContainer,
                backgroundColor: theme.colorScheme.surfaceContainerLowest,
                side: BorderSide(
                  color: selected.contains(i)
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                ),
                shape: const StadiumBorder(),
                materialTapTargetSize: MaterialTapTargetSize.padded,
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                onSelected: !enabled
                    ? null
                    : (_) {
                        HapticFeedback.selectionClick();
                        onToggle(i);
                      },
              ),
            ),
        ],
      ),
    );
  }
}
