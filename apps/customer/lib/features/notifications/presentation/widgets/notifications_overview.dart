import 'package:flutter/material.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Editorial identity for the TAM notification timeline; vector-only, no assets.
class NotificationsOverview extends StatelessWidget {
  const NotificationsOverview({super.key, required this.unreadCount});

  final int? unreadCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final showRoute =
            constraints.maxWidth > 305 &&
            MediaQuery.textScalerOf(context).scale(1) < 1.5;
        return Container(
          key: const Key('notifications-overview'),
          padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 13, 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [Color(0xFFA51D48), Color(0xFF74102F)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.notificationsFeedTitle,
                      style: text.titleMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.notificationsFeedSubtitle,
                      style: text.bodySmall?.copyWith(
                        fontSize: 11,
                        color: const Color(0xFFF6DDE5),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Text(
                        unreadCount == null
                            ? l10n.notificationsUnknownCount
                            : l10n.notificationsUnreadCount(unreadCount!),
                        maxLines: 2,
                        style: text.labelSmall?.copyWith(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (showRoute) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  height: 80,
                  width: 94,
                  child: CustomPaint(painter: _RouteArtwork()),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _RouteArtwork extends CustomPainter {
  const _RouteArtwork();

  @override
  void paint(Canvas canvas, Size size) {
    final route = Path()
      ..moveTo(size.width * .06, size.height * .79)
      ..cubicTo(
        size.width * .35,
        size.height * .79,
        size.width * .31,
        size.height * .22,
        size.width * .61,
        size.height * .39,
      )
      ..quadraticBezierTo(
        size.width * .78,
        size.height * .5,
        size.width * .9,
        size.height * .12,
      );
    final paint = Paint()
      ..color = const Color(0xFFFFD9E2).withValues(alpha: .74)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final metric in route.computeMetrics()) {
      var start = 0.0;
      while (start < metric.length) {
        canvas.drawPath(
          metric.extractPath(start, (start + 5).clamp(0, metric.length)),
          paint,
        );
        start += 11;
      }
    }
    final origin = Offset(size.width * .06, size.height * .79);
    canvas.drawCircle(origin, 9, Paint()..color = const Color(0xFFF7DCE4));
    canvas.drawCircle(origin, 4, Paint()..color = const Color(0xFF8D153A));
    final end = Offset(size.width * .9, size.height * .12);
    canvas.drawCircle(end, 11, Paint()..color = const Color(0xFFF7DCE4));
    canvas.drawCircle(end, 4.8, Paint()..color = const Color(0xFF8D153A));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
