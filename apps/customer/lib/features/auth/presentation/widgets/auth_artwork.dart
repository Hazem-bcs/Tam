import 'package:flutter/material.dart';

enum AuthArtwork { route, verification, recovery }

/// Small code-native illustrations, not a brand logo. Colors follow the theme.
class AuthHeaderArtwork extends StatelessWidget {
  const AuthHeaderArtwork({
    super.key,
    required this.artwork,
    this.compact = false,
    this.onDark = false,
  });

  final AuthArtwork artwork;
  final bool compact;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: IgnorePointer(
        child: SizedBox(
          height: compact
              ? 44
              : artwork == AuthArtwork.route
              ? 80
              : 92,
          width: double.infinity,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration:
                artwork == AuthArtwork.route &&
                    !MediaQuery.disableAnimationsOf(context)
                ? const Duration(milliseconds: 880)
                : Duration.zero,
            curve: Curves.easeOutCubic,
            builder: (context, progress, child) => CustomPaint(
              painter: _HeaderPainter(
                artwork,
                onDark ? colors.onPrimary : colors.primary,
                onDark ? colors.primary : colors.surface,
                progress,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderPainter extends CustomPainter {
  const _HeaderPainter(this.artwork, this.primary, this.surface, this.progress);
  final AuthArtwork artwork;
  final Color primary;
  final Color surface;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (artwork == AuthArtwork.route) {
      _route(canvas, size);
      return;
    }
    // A restrained message/check illustration based on the OTP reference.
    final scale = size.height / 100;
    canvas.save();
    canvas.translate((size.width - 120 * scale) / 2, 0);
    canvas.scale(scale);
    final line = Paint()
      ..color = primary.withValues(alpha: .50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final bubble = Path()
      ..moveTo(24, 23)
      ..lineTo(87, 23)
      ..quadraticBezierTo(98, 23, 98, 34)
      ..lineTo(98, 59)
      ..quadraticBezierTo(98, 70, 87, 70)
      ..lineTo(47, 70)
      ..lineTo(29, 84)
      ..lineTo(30, 70)
      ..lineTo(24, 70)
      ..quadraticBezierTo(13, 70, 13, 59)
      ..lineTo(13, 34)
      ..quadraticBezierTo(13, 23, 24, 23);
    canvas.drawPath(bubble, line);
    canvas.drawLine(const Offset(27, 38), const Offset(78, 38), line);
    canvas.drawLine(const Offset(27, 49), const Offset(65, 49), line);
    canvas.drawLine(const Offset(27, 59), const Offset(51, 59), line);
    canvas.drawCircle(const Offset(91, 72), 19, Paint()..color = surface);
    canvas.drawCircle(const Offset(91, 72), 16, line);
    canvas.drawPath(
      Path()
        ..moveTo(83, 72)
        ..lineTo(89, 78)
        ..lineTo(100, 66),
      line,
    );
    canvas.drawLine(const Offset(98, 10), const Offset(101, 3), line);
    canvas.drawLine(const Offset(108, 18), const Offset(116, 14), line);
    canvas.restore();
  }

  void _route(Canvas canvas, Size size) {
    final start = Offset(size.width * .22, size.height * .76);
    final end = Offset(size.width * .79, size.height * .29);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        size.width * .46,
        size.height * 1.02,
        size.width * .47,
        -size.height * .03,
        end.dx,
        end.dy,
      );
    final line = Paint()
      ..color = primary.withValues(alpha: .28)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final metric in path.computeMetrics()) {
      final visible = metric.length * progress;
      for (double distance = 0; distance < visible; distance += 10) {
        canvas.drawPath(
          metric.extractPath(distance, (distance + 5).clamp(0.0, visible)),
          line,
        );
      }
    }
    final points = progress > 0.92 ? [start, end] : [start];
    for (final point in points) {
      canvas.drawOval(
        Rect.fromCenter(center: point.translate(0, 4), width: 24, height: 5),
        Paint()..color = primary.withValues(alpha: .08),
      );
      final marker = Path()
        ..moveTo(point.dx, point.dy)
        ..cubicTo(
          point.dx - 3,
          point.dy - 5,
          point.dx - 10,
          point.dy - 11,
          point.dx - 10,
          point.dy - 18,
        )
        ..cubicTo(
          point.dx - 10,
          point.dy - 32,
          point.dx + 10,
          point.dy - 32,
          point.dx + 10,
          point.dy - 18,
        )
        ..cubicTo(
          point.dx + 10,
          point.dy - 11,
          point.dx + 3,
          point.dy - 5,
          point.dx,
          point.dy,
        );
      canvas.drawPath(marker, Paint()..color = primary.withValues(alpha: .46));
      canvas.drawCircle(point.translate(0, -19), 3.5, Paint()..color = surface);
    }
  }

  @override
  bool shouldRepaint(_HeaderPainter oldDelegate) =>
      artwork != oldDelegate.artwork ||
      primary != oldDelegate.primary ||
      surface != oldDelegate.surface ||
      progress != oldDelegate.progress;
}
