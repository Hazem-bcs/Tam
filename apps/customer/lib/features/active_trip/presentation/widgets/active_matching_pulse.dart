import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A single quiet search motif. The map and panel never repaint with its clock.
class ActiveMatchingPulse extends StatefulWidget {
  const ActiveMatchingPulse({super.key});
  @override
  State<ActiveMatchingPulse> createState() => _ActiveMatchingPulseState();
}

class _ActiveMatchingPulseState extends State<ActiveMatchingPulse>
    with SingleTickerProviderStateMixin {
  late final _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.stop();
      _motion.value = .4;
    } else if (!_motion.isAnimating) {
      _motion.repeat();
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: SizedBox(
          key: const Key('driver-search-animation'),
          height: 112,
          child: AnimatedBuilder(
            animation: _motion,
            builder: (context, child) => CustomPaint(
              painter: _SearchRings(colors.primary, _motion.value),
              child: Center(
                child: Transform.translate(
                  offset: Offset(math.sin(_motion.value * math.pi * 2) * 5, 0),
                  child: child,
                ),
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.primary.withValues(alpha: .18),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.search_rounded,
                  size: 32,
                  color: colors.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchRings extends CustomPainter {
  const _SearchRings(this.color, this.phase);
  final Color color;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maximum = math.min(52.0, size.width / 2 - 4);
    for (var i = 0; i < 3; i++) {
      final value = (phase + i / 3) % 1;
      final paint = Paint()
        ..color = color.withValues(alpha: (1 - value) * .24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, 29 + value * math.max(0, maximum - 29), paint);
    }
  }

  @override
  bool shouldRepaint(_SearchRings old) =>
      old.phase != phase || old.color != color;
}
