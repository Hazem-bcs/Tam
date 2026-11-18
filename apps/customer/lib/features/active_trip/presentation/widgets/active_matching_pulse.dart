import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/ride_request/presentation/widgets/ride_artwork.dart';

/// Quiet continuous search feedback; only this small illustration repaints.
class ActiveMatchingPulse extends StatefulWidget {
  const ActiveMatchingPulse({super.key});
  @override
  State<ActiveMatchingPulse> createState() => _ActiveMatchingPulseState();
}

class _ActiveMatchingPulseState extends State<ActiveMatchingPulse>
    with SingleTickerProviderStateMixin {
  late final _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.stop();
      _motion.value = .5;
    } else {
      _motion.repeat();
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: SizedBox(
      height: 100,
      child: AnimatedBuilder(
        animation: _motion,
        builder: (context, child) => CustomPaint(
          painter: _SearchRings(
            Theme.of(context).colorScheme.primary,
            _motion.value,
          ),
          child: Center(child: child),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadii.sheet),
          ),
          child: const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: RideArtwork(
              type: RideArtworkType.comfort,
              width: 78,
              height: 44,
            ),
          ),
        ),
      ),
    ),
  );
}

class _SearchRings extends CustomPainter {
  const _SearchRings(this.color, this.phase);
  final Color color;
  final double phase;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < 3; i++) {
      final value = (phase + i / 3) % 1;
      final paint = Paint()
        ..color = color.withValues(alpha: (1 - value) * .22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: 92 + value * math.min(180, size.width - 104),
          height: 44 + value * 48,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SearchRings old) =>
      old.phase != phase || old.color != color;
}
