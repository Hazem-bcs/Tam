import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Exactly one entry to ride request. No pickup/destination "pretend fields".
class HomeDestinationHero extends StatelessWidget {
  const HomeDestinationHero({super.key, required this.onChooseDestination});

  final VoidCallback onChooseDestination;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final type = Theme.of(context).textTheme;
    final t = AppLocalizations.of(context);

    return Semantics(
      button: true,
      label: t.homeChooseDestination,
      child: Material(
        color: colors.primary,
        borderRadius: BorderRadius.circular(27),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: const Key('home-ride-entry'),
          onTap: onChooseDestination,
          child: Stack(
            children: [
              PositionedDirectional(
                end: 0,
                top: 0,
                bottom: 0,
                width: 150,
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _RouteAccentPainter(
                      lineColor: colors.onPrimary.withValues(alpha: .23),
                      stopColor: colors.onPrimary.withValues(alpha: .55),
                      rtl: Directionality.of(context) == TextDirection.rtl,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 22, 20, 19),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.homeLandingQuestion,
                      style: type.headlineMedium?.copyWith(
                        color: colors.onPrimary,
                        height: 1.25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      t.homeLandingSubtitle,
                      style: type.bodyMedium?.copyWith(
                        color: colors.onPrimary.withValues(alpha: .84),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Container(
                      constraints: const BoxConstraints(minHeight: 58),
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 13,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colors.onPrimary,
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 37,
                            height: 37,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(
                              Icons.place_outlined,
                              color: colors.primary,
                              size: 21,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              t.homeChooseDestination,
                              style: type.titleSmall?.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: colors.primary,
                            size: 21,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteAccentPainter extends CustomPainter {
  const _RouteAccentPainter({
    required this.lineColor,
    required this.stopColor,
    required this.rtl,
  });

  final Color lineColor;
  final Color stopColor;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    if (rtl) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    final route = Path()
      ..moveTo(size.width * .16, 8)
      ..cubicTo(
        size.width * 1.05,
        size.height * .23,
        size.width * .07,
        size.height * .52,
        size.width * .85,
        size.height * .72,
      );
    final paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color = lineColor;
    for (final metric in route.computeMetrics()) {
      for (double start = 0; start < metric.length; start += 13) {
        canvas.drawPath(
          metric.extractPath(start, (start + 6).clamp(0, metric.length)),
          paint,
        );
      }
    }
    final end = Offset(size.width * .85, size.height * .35);
    canvas.drawCircle(end, 11, Paint()..color = stopColor);
    canvas.drawCircle(end, 4.5, Paint()..color = lineColor);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RouteAccentPainter old) =>
      old.lineColor != lineColor ||
      old.stopColor != stopColor ||
      old.rtl != rtl;
}
