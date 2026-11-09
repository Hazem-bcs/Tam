import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';

/// A schematic geographic projection; no map SDK, GPS permission or live tiles.
class ActiveRouteMap extends StatelessWidget {
  const ActiveRouteMap({super.key, required this.trip, required this.stale});
  final Trip trip;
  final bool stale;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: l.activeTripRouteSemantics(
        trip.booking.pickup.label,
        trip.booking.destination.label,
      ),
      child: TamCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: _RoutePainter(
                  trip.booking.pickup.point,
                  trip.booking.destination.point,
                  trip.live?.position?.point,
                  colors.primary,
                  colors.outlineVariant,
                  colors.surfaceContainerHighest,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              stale ? l.activeTripPositionStale : l.activeTripSchematic,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter(
    this.pickup,
    this.destination,
    this.driver,
    this.routeColor,
    this.gridColor,
    this.markerColor,
  );
  final GeoPoint pickup, destination;
  final GeoPoint? driver;
  final Color routeColor, gridColor, markerColor;
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 1; i < 6; i++) {
      canvas.drawLine(
        Offset(size.width * i / 6, 0),
        Offset(size.width * i / 6, size.height),
        grid,
      );
      canvas.drawLine(
        Offset(0, size.height * i / 6),
        Offset(size.width, size.height * i / 6),
        grid,
      );
    }
    final start = Offset(size.width * .18, size.height * .8);
    final end = Offset(size.width * .82, size.height * .2);
    final route = Paint()
      ..color = routeColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(start, end, route);
    final marker = Paint()..color = routeColor;
    canvas.drawCircle(start, 8, marker);
    canvas.drawCircle(end, 8, marker);
    if (driver != null) {
      final lat = destination.latitude - pickup.latitude;
      final lng = destination.longitude - pickup.longitude;
      final denominator = lat * lat + lng * lng;
      final fraction = denominator == 0
          ? 0.0
          : (((driver!.latitude - pickup.latitude) * lat +
                        (driver!.longitude - pickup.longitude) * lng) /
                    denominator)
                .clamp(0.0, 1.0);
      final at = Offset.lerp(start, end, fraction)!;
      canvas.drawCircle(at, 14, Paint()..color = markerColor);
      canvas.drawCircle(at, 10, route);
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter old) =>
      pickup != old.pickup ||
      destination != old.destination ||
      driver != old.driver ||
      routeColor != old.routeColor ||
      gridColor != old.gridColor ||
      markerColor != old.markerColor;
}
