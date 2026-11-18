import 'package:flutter/material.dart';

class ChatBackground extends StatelessWidget {
  const ChatBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _ChatWavePainter(Theme.of(context).colorScheme.primaryContainer),
    child: child,
  );
}

class _ChatWavePainter extends CustomPainter {
  const _ChatWavePainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: .35);
    final top = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * .55, 0)
      ..cubicTo(
        size.width * .45,
        size.height * .08,
        size.width * .18,
        size.height * .02,
        0,
        size.height * .14,
      )
      ..close();
    final bottom = Path()
      ..moveTo(0, size.height * .8)
      ..cubicTo(
        size.width * .25,
        size.height * .82,
        size.width * .45,
        size.height * .95,
        size.width,
        size.height * .82,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(top, paint);
    canvas.drawPath(bottom, paint);
  }

  @override
  bool shouldRepaint(_ChatWavePainter oldDelegate) =>
      oldDelegate.color != color;
}
