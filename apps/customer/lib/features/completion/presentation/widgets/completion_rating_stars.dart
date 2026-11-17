import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Five tactile, glossy gold stars without a continuous animation loop.
class CompletionRatingStars extends StatelessWidget {
  const CompletionRatingStars({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return LayoutBuilder(
      builder: (context, constraints) {
        const width = AppDimensions.minTapTarget;
        return Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadii.sheet * 2),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 0,
                vertical: AppSpacing.xs,
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  for (var star = 1; star <= 5; star++)
                    _RatingStar(
                      key: ValueKey('completion-star-item-$star'),
                      number: star,
                      value: value,
                      width: width,
                      duration: reduceMotion
                          ? Duration.zero
                          : Duration(milliseconds: 200 + star * 35),
                      label: l.completionStars(star),
                      onPressed: onChanged == null
                          ? null
                          : () {
                              HapticFeedback.selectionClick();
                              onChanged!(star);
                            },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RatingStar extends StatelessWidget {
  const _RatingStar({
    super.key,
    required this.number,
    required this.value,
    required this.width,
    required this.duration,
    required this.label,
    required this.onPressed,
  });

  final int number;
  final int value;
  final double width;
  final Duration duration;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final active = number <= value;
    final focused = number == value && value > 0;
    final image = active
        ? 'assets/images/completion_star_gold.svg'
        : 'assets/images/completion_star_outline.svg';

    return Semantics(
      label: label,
      selected: focused,
      child: SizedBox(
        width: width,
        height: AppDimensions.minTapTarget,
        child: AnimatedScale(
          scale: focused ? 1.02 : 1,
          duration: duration,
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: duration,
            curve: AppMotion.easeOut,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: focused
                  ? colors.primaryContainer.withValues(alpha: 0.72)
                  : colors.surfaceContainerLow.withValues(alpha: 0),
            ),
            child: IconButton(
              key: ValueKey('completion-stars-$number'),
              tooltip: label,
              onPressed: onPressed,
              padding: const EdgeInsets.all(4),
              constraints: BoxConstraints(
                minWidth: width,
                minHeight: AppDimensions.minTapTarget,
              ),
              icon: AnimatedSwitcher(
                duration: duration,
                switchInCurve: AppMotion.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
                child: ExcludeSemantics(
                  key: ValueKey(active),
                  child: SvgPicture.asset(image, width: 28, height: 28),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
