import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';

/// The same three anchored slots for positive and critical feedback.
///
/// Screen width and text scale determine the number of columns; star selection
/// only cross-fades slot contents, never changes the grid geometry.
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
  final bool positive;
  final Set<int> selected;
  final bool enabled;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final duration = reduceMotion ? Duration.zero : AppMotion.short;
    final icons = positive
        ? const [
            Icons.person_outline_rounded,
            Icons.directions_car_outlined,
            Icons.airline_seat_recline_normal_rounded,
          ]
        : const [
            Icons.access_time_rounded,
            Icons.car_crash_outlined,
            Icons.sentiment_dissatisfied_outlined,
          ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 285 || scale > 1.4 ? 2 : 3;
        final tileWidth =
            (constraints.maxWidth - (columns - 1) * AppSpacing.sm) / columns;
        // Reserve height for the longest translation at large accessibility scales.
        // Both rating sentiments always occupy identical, fixed-size slots.
        final tileHeight = 132.0 + (scale - 1).clamp(0, 3) * 220.0;

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (var index = 0; index < labels.length; index++)
              SizedBox(
                width: tileWidth,
                height: tileHeight,
                child: _FeedbackOption(
                  key: ValueKey('completion-tag-$index'),
                  label: labels[index],
                  icon: icons[index],
                  selected: selected.contains(index),
                  enabled: enabled,
                  duration: duration,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onToggle(index);
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FeedbackOption extends StatelessWidget {
  const _FeedbackOption({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.duration,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: label,
      child: AnimatedScale(
        scale: selected ? 1.015 : 1,
        duration: duration,
        curve: AppMotion.easeOut,
        child: Material(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            onTap: enabled ? onTap : null,
            child: AnimatedContainer(
              duration: duration,
              curve: AppMotion.easeOut,
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? colors.primaryContainer
                    : colors.surfaceContainerLow.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(
                  color: selected ? colors.primary : colors.outlineVariant,
                  width: selected ? 1.4 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: duration,
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Icon(
                      icon,
                      key: ValueKey(icon),
                      color: selected
                          ? colors.primary
                          : colors.onSurfaceVariant,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AnimatedSwitcher(
                    duration: duration,
                    switchInCurve: AppMotion.easeOut,
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Text(
                      label,
                      key: ValueKey(label),
                      textAlign: TextAlign.center,
                      style: text.labelMedium?.copyWith(
                        color: selected
                            ? colors.onPrimaryContainer
                            : colors.onSurface,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
