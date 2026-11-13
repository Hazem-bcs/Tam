import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/maps/presentation/maps_scope.dart';
import 'package:tam_customer/features/maps/presentation/widgets/route_map_view.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// Uses configured live tiles; an explicitly labelled illustration is retained
/// only when tiles are disabled. Draft labels never claim device GPS or an ETA.
class RideJourneyBackdrop extends StatelessWidget {
  const RideJourneyBackdrop({
    super.key,
    this.pickup,
    this.destination,
    required this.compact,
  });
  final TripLocation? pickup, destination;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tiles = MapsScope.maybeOf(context)?.configuration.hasTiles ?? false;
    final reduced = MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, bounds) => Stack(
        children: [
          if (tiles)
            RouteMapView(
              origin: pickup?.point,
              destination: destination?.point,
              height: bounds.maxHeight,
            )
          else ...[
            Positioned.fill(
              child: ExcludeSemantics(
                child: RepaintBoundary(
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey((pickup?.point, destination?.point)),
                    tween: Tween(begin: reduced ? 1 : 0, end: 1),
                    duration: reduced ? Duration.zero : AppMotion.long,
                    curve: AppMotion.easeOut,
                    builder: (context, value, _) => CustomPaint(
                      painter: _JourneyIllustration(
                        street: colors.surfaceContainerHigh,
                        block: colors.surfaceContainer,
                        accent: colors.primary,
                        destination: colors.tertiary,
                        hasPickup: pickup != null,
                        hasDestination: destination != null,
                        progress: value,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              start: AppSpacing.xl,
              end: AppSpacing.xl,
              bottom: AppSpacing.xxl + AppSpacing.md,
              child: Text(
                AppLocalizations.of(context).rideRequestFlowVisualMap,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
          if (pickup != null || destination != null)
            AnimatedAlign(
              duration: reduced ? Duration.zero : AppMotion.long,
              curve: AppMotion.easeOut,
              alignment: compact
                  ? AlignmentDirectional.centerEnd
                  : AlignmentDirectional.bottomEnd,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Material(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      [
                        pickup?.label,
                        destination?.label,
                      ].whereType<String>().join('  ·  '),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _JourneyIllustration extends CustomPainter {
  const _JourneyIllustration({
    required this.street,
    required this.block,
    required this.accent,
    required this.destination,
    required this.hasPickup,
    required this.hasDestination,
    required this.progress,
  });
  final Color street, block, accent, destination;
  final bool hasPickup, hasDestination;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 390, size.height / 520);
    final blocks = Paint()..color = block;
    for (final r in [
      const Rect.fromLTWH(34, 170, 92, 82),
      const Rect.fromLTWH(248, 100, 112, 118),
      const Rect.fromLTWH(24, 350, 84, 108),
      const Rect.fromLTWH(242, 355, 88, 104),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(20)),
        blocks,
      );
    }
    final lane = Paint()
      ..color = street
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;
    for (final line in [
      (const Offset(-20, 130), const Offset(410, 430)),
      (const Offset(-30, 330), const Offset(430, 100)),
      (const Offset(30, 530), const Offset(370, 215)),
      (const Offset(250, -20), const Offset(286, 540)),
    ]) {
      canvas.drawLine(line.$1, line.$2, lane);
    }
    // Schematic connector only, explicitly labelled as an illustration above.
    if (hasPickup && hasDestination) {
      final path = Path()
        ..moveTo(95, 400)
        ..cubicTo(140, 235, 245, 400, 298, 180);
      final metric = path.computeMetrics().first;
      canvas.drawPath(
        metric.extractPath(0, metric.length * progress),
        Paint()
          ..color = accent
          ..strokeWidth = 6
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.restore();
    Offset position(double x, double y) =>
        Offset(x / 390 * size.width, y / 520 * size.height);
    final scale = size.width / 390;
    if (hasPickup) {
      canvas.drawCircle(
        position(95, 400),
        25 * scale,
        Paint()..color = accent.withValues(alpha: .18),
      );
      canvas.drawCircle(position(95, 400), 11 * scale, Paint()..color = accent);
    }
    if (hasDestination) {
      canvas.drawCircle(
        position(298, 180),
        17 * scale,
        Paint()..color = destination,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _JourneyIllustration old) =>
      street != old.street ||
      block != old.block ||
      accent != old.accent ||
      destination != old.destination ||
      hasPickup != old.hasPickup ||
      hasDestination != old.hasDestination ||
      progress != old.progress;
}
