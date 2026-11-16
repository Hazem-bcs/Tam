import 'package:flutter/material.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Compact branded summary: the inbox content remains the main visual focus.
class NotificationsOverview extends StatelessWidget {
  const NotificationsOverview({super.key, required this.unreadCount});

  final int? unreadCount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    return Container(
      key: const Key('notifications-overview'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            colors.primary,
            Color.lerp(colors.primary, colors.onPrimaryContainer, .55)!,
          ],
        ),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            end: -18,
            bottom: -44,
            child: ExcludeSemantics(
              child: Container(
                width: 165,
                height: 165,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.onPrimary.withValues(alpha: .09),
                    width: 28,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(18, 17, 18, 17),
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
                          color: colors.onPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.notificationsFeedSubtitle,
                        style: text.bodySmall?.copyWith(
                          color: colors.onPrimary.withValues(alpha: .82),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colors.onPrimary.withValues(alpha: .14),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: colors.onPrimary.withValues(alpha: .20),
                          ),
                        ),
                        child: Text(
                          unreadCount == null
                              ? l10n.notificationsUnknownCount
                              : l10n.notificationsUnreadCount(unreadCount!),
                          style: text.labelMedium?.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (MediaQuery.textScalerOf(context).scale(1) < 1.4)
                  SizedBox(
                    width: 84,
                    height: 83,
                    child: ExcludeSemantics(
                      child: CustomPaint(
                        painter: _JourneyLine(
                          color: colors.onPrimary.withValues(alpha: .68),
                          centerColor: colors.onPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyLine extends CustomPainter {
  const _JourneyLine({required this.color, required this.centerColor});
  final Color color;
  final Color centerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final route = Path()
      ..moveTo(size.width * .07, size.height * .86)
      ..cubicTo(
        size.width * .35,
        size.height * .80,
        size.width * .38,
        size.height * .24,
        size.width * .92,
        size.height * .12,
      );
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final metric in route.computeMetrics()) {
      for (var start = 0.0; start < metric.length; start += 12) {
        canvas.drawPath(
          metric.extractPath(start, (start + 6).clamp(0, metric.length)),
          paint,
        );
      }
    }
    for (final dot in [
      Offset(size.width * .07, size.height * .86),
      Offset(size.width * .92, size.height * .12),
    ]) {
      canvas.drawCircle(dot, 9, Paint()..color = color);
      canvas.drawCircle(dot, 3.7, Paint()..color = const Color(0xFFFFFFFF));
    }
  }

  @override
  bool shouldRepaint(covariant _JourneyLine oldDelegate) =>
      oldDelegate.color != color || oldDelegate.centerColor != centerColor;
}
