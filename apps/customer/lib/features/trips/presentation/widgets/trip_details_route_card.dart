import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// A decorative local street motif; it is intentionally NOT a geographic
/// route preview. No fictitious polyline or pins are attributed to the trip.
class TripDetailsRouteCard extends StatelessWidget {
  const TripDetailsRouteCard({super.key, required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.alt_route_rounded,
                      color: colors.primary,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l.tripsRoute,
                    style: text.titleLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                final sideBySide =
                    constraints.maxWidth >= 304 &&
                    MediaQuery.textScalerOf(context).scale(1) < 1.35;
                final timeline = _TripStops(trip: trip);
                final visual = const _StreetMotif();
                if (!sideBySide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      timeline,
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(height: 142, child: visual),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: timeline),
                    const SizedBox(width: AppSpacing.md),
                    SizedBox(
                      width: constraints.maxWidth * .42,
                      height: 166,
                      child: visual,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TripStops extends StatelessWidget {
  const _TripStops({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Stop(
          icon: Icons.trip_origin_rounded,
          label: l.tripsFrom,
          address: trip.booking.pickup.label,
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 10),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              width: 2,
              height: 28,
              color: colors.primary.withValues(alpha: .42),
            ),
          ),
        ),
        _Stop(
          icon: Icons.location_on_rounded,
          label: l.tripsTo,
          address: trip.booking.destination.label,
        ),
      ],
    );
  }
}

class _Stop extends StatelessWidget {
  const _Stop({required this.icon, required this.label, required this.address});
  final IconData icon;
  final String label;
  final String address;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 23, color: colors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: text.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StreetMotif extends StatelessWidget {
  const _StreetMotif();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: ColoredBox(
            color: colors.surfaceContainerLow,
            child: CustomPaint(
              painter: _StreetPainter(
                road: colors.surfaceContainerLowest,
                edge: colors.outlineVariant.withValues(alpha: .55),
                park: colors.secondaryContainer.withValues(alpha: .55),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/maps/vehicle-sedan.svg',
                  width: 72,
                  height: 72,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small static street geometry avoids downloading map tiles or shipping
/// decorative bitmap assets. It never depicts the route's actual coordinates.
class _StreetPainter extends CustomPainter {
  const _StreetPainter({
    required this.road,
    required this.edge,
    required this.park,
  });
  final Color road;
  final Color edge;
  final Color park;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final parks = Paint()..color = park;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(.07 * w, .04 * h, .30 * w, .23 * h),
        const Radius.circular(12),
      ),
      parks,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(.69 * w, .65 * h, .29 * w, .34 * h),
        const Radius.circular(14),
      ),
      parks,
    );

    Path path(List<Offset> points) {
      final line = Path()..moveTo(points.first.dx * w, points.first.dy * h);
      for (final point in points.skip(1)) {
        line.lineTo(point.dx * w, point.dy * h);
      }
      return line;
    }

    final streets = [
      [const Offset(-.1, .16), const Offset(.44, .31), const Offset(1.1, .17)],
      [const Offset(-.1, .59), const Offset(.40, .52), const Offset(1.1, .84)],
      [const Offset(.12, -.1), const Offset(.27, .45), const Offset(.18, 1.1)],
      [const Offset(.66, -.1), const Offset(.59, .52), const Offset(.78, 1.1)],
      [const Offset(.9, -.1), const Offset(.87, .46), const Offset(.98, 1.1)],
      [
        const Offset(-.1, .95),
        const Offset(.49, .82),
        const Offset(.89, .31),
        const Offset(1.1, .22),
      ],
    ];

    for (final points in streets) {
      canvas.drawPath(
        path(points),
        Paint()
          ..color = edge
          ..style = PaintingStyle.stroke
          ..strokeWidth = 13
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.drawPath(
        path(points),
        Paint()
          ..color = road
          ..style = PaintingStyle.stroke
          ..strokeWidth = 11
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StreetPainter oldDelegate) =>
      oldDelegate.road != road ||
      oldDelegate.edge != edge ||
      oldDelegate.park != park;
}
