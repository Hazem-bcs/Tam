import 'package:flutter/material.dart';

/// True ticket-shaped clipping, including punches at the coupon split.
/// In RTL the perforations sit on the physical left edge, as in the reference.
class CouponTicketClipper extends CustomClipper<Path> {
  const CouponTicketClipper({
    required this.isRtl,
    required this.horizontalSplit,
    this.discountWidth = 112,
  });

  final bool isRtl;
  final bool horizontalSplit;
  final double discountWidth;

  @override
  Path getClip(Size size) {
    if (size.isEmpty) return Path();
    final base = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(20)),
      );
    final punches = Path();
    final edge = isRtl ? 0.0 : size.width;

    // Three small semicircular cutouts are physically cut from the side.
    for (final fraction in <double>[.22, .50, .78]) {
      punches.addOval(
        Rect.fromCircle(
          center: Offset(edge, size.height * fraction),
          radius: 8,
        ),
      );
    }

    if (horizontalSplit) {
      final splitX = isRtl ? size.width - discountWidth - 1 : discountWidth + 1;
      // Top and bottom punches interrupt the perforation naturally.
      for (final y in <double>[0, size.height]) {
        punches.addOval(Rect.fromCircle(center: Offset(splitX, y), radius: 7));
      }
    }
    return Path.combine(PathOperation.difference, base, punches);
  }

  @override
  bool shouldReclip(covariant CouponTicketClipper old) =>
      old.isRtl != isRtl ||
      old.horizontalSplit != horizontalSplit ||
      old.discountWidth != discountWidth;
}

/// Paints the real cut border; does not fake holes with surface-colored circles.
class CouponTicketOutlinePainter extends CustomPainter {
  const CouponTicketOutlinePainter({
    required this.color,
    required this.clipper,
  });

  final Color color;
  final CouponTicketClipper clipper;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      clipper.getClip(size),
      Paint()
        ..color = color
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant CouponTicketOutlinePainter old) =>
      old.color != color || clipper.shouldReclip(old.clipper);
}
