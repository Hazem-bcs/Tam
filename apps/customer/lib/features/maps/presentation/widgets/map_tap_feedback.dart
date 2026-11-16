import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';

typedef MapTap = ({Offset point, int id});

/// Immediate local feedback, independent of native camera and address requests.
class MapTapFeedback extends StatelessWidget {
  const MapTapFeedback({super.key, required this.tap});
  final ValueListenable<MapTap?> tap;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: IgnorePointer(
      child: ExcludeSemantics(
        child: ValueListenableBuilder<MapTap?>(
          valueListenable: tap,
          builder: (context, value, _) {
            if (value == null || MediaQuery.disableAnimationsOf(context)) {
              return const SizedBox.shrink();
            }
            final color = Theme.of(context).colorScheme.primary;
            return Stack(
              children: [
                Positioned(
                  left: value.point.dx - 18,
                  top: value.point.dy - 18,
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey(value.id),
                    tween: Tween(begin: 0, end: 1),
                    duration: AppMotion.short,
                    curve: AppMotion.easeOut,
                    builder: (context, progress, _) => Opacity(
                      opacity: 1 - progress,
                      child: Transform.scale(
                        scale: .6 + .4 * progress,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withValues(alpha: .08),
                            border: Border.all(
                              color: color.withValues(alpha: .3),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
