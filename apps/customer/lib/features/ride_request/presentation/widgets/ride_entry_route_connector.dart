import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';

/// Static, decorative route between the icon centers of the two endpoint cells.
class RideEntryRouteConnector extends CustomPainter {
  const RideEntryRouteConnector({required this.color, required this.direction});
  final Color color;
  final TextDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = (size.width - AppSpacing.lg) / 2;
    final start = cellWidth / 2 + 20;
    final end = size.width - cellWidth / 2 - 20;
    final middle = size.width / 2;
    const y = 16.0;
    final route = Path()
      ..moveTo(start, y)
      ..cubicTo(middle - 16, y - 8, middle + 16, y + 8, end, y);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final metric in route.computeMetrics()) {
      for (double offset = 0; offset < metric.length; offset += 6) {
        canvas.drawPath(metric.extractPath(offset, offset + 2), paint);
      }
    }
    final sign = direction == TextDirection.rtl ? -1 : 1;
    canvas.drawPath(
      Path()
        ..moveTo(middle - sign * 3, y - 3)
        ..lineTo(middle + sign * 3, y)
        ..lineTo(middle - sign * 3, y + 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(RideEntryRouteConnector oldDelegate) =>
      color != oldDelegate.color || direction != oldDelegate.direction;
}
