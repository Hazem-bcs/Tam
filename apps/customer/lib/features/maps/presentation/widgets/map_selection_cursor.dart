import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';

/// Vector geometry stays crisp at any density; only the pin lifts during a drag.
/// The bottom of the pin, not its bounding box, is the selected map coordinate.
class MapSelectionCursor extends StatelessWidget {
  const MapSelectionCursor({
    super.key,
    required this.anchor,
    required this.moving,
  });
  final Offset anchor;
  final ValueListenable<bool> moving;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              left: anchor.dx - 18,
              top: anchor.dy - 41,
              child: ValueListenableBuilder<bool>(
                valueListenable: moving,
                builder: (context, lifting, _) => SizedBox(
                  width: 36,
                  height: 44,
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        left: 10,
                        right: 10,
                        child: SizedBox(
                          height: 8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppRadii.sheet,
                              ),
                              gradient: RadialGradient(
                                radius: .55,
                                colors: [
                                  c.primary.withValues(alpha: .26),
                                  c.primary.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      AnimatedSlide(
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : AppMotion.short,
                        offset: Offset(0, lifting ? -.12 : 0),
                        child: TweenAnimationBuilder<double>(
                          key: ValueKey(anchor),
                          tween: Tween(begin: .9, end: 1),
                          duration: MediaQuery.disableAnimationsOf(context)
                              ? Duration.zero
                              : AppMotion.short,
                          curve: AppMotion.easeOut,
                          builder: (context, scale, child) => Transform.scale(
                            scale: scale,
                            alignment: Alignment.bottomCenter,
                            child: child,
                          ),
                          child: CustomPaint(
                            size: const Size(36, 42),
                            painter: _PinPainter(c.primary, c.onPrimary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinPainter extends CustomPainter {
  const _PinPainter(this.ink, this.center);
  final Color ink, center;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 52, size.height / 62);
    final path = Path()
      ..moveTo(26, 60)
      ..cubicTo(21, 54, 5, 36, 5, 23)
      ..cubicTo(5, 11, 14, 2, 26, 2)
      ..cubicTo(38, 2, 47, 11, 47, 23)
      ..cubicTo(47, 36, 31, 54, 26, 60)
      ..close();
    canvas.drawPath(path, Paint()..color = ink);
    canvas.drawCircle(const Offset(26, 23), 8, Paint()..color = center);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PinPainter oldDelegate) =>
      oldDelegate.ink != ink || oldDelegate.center != center;
}
