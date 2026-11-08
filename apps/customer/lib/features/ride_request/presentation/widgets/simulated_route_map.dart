import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Decorative geography only; intentionally has no live map/GPS access.
class SimulatedRouteMap extends StatelessWidget {
  const SimulatedRouteMap({super.key, required this.hasRoute});

  final bool hasRoute;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final label = AppLocalizations.of(context).rideRequestMockMap;
    return Semantics(
      label: label,
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: SizedBox(
          height: 210,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _RoadSketch(
                  background: colors.surfaceContainer,
                  street: colors.surfaceContainerLowest,
                  park: colors.secondaryContainer,
                  route: colors.primary,
                  hasRoute: hasRoute,
                ),
              ),
              if (hasRoute) ...[
                Align(
                  alignment: const Alignment(-0.65, -0.4),
                  child: Icon(
                    Icons.radio_button_checked,
                    color: colors.primary,
                  ),
                ),
                Align(
                  alignment: const Alignment(0.65, 0.3),
                  child: Icon(
                    Icons.location_on,
                    size: 32,
                    color: colors.primary,
                  ),
                ),
              ] else
                Center(
                  child: Icon(
                    Icons.map_outlined,
                    size: 50,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              Align(
                alignment: AlignmentDirectional.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoadSketch extends CustomPainter {
  const _RoadSketch({
    required this.background,
    required this.street,
    required this.park,
    required this.route,
    required this.hasRoute,
  });

  final Color background;
  final Color street;
  final Color park;
  final Color route;
  final bool hasRoute;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    final green = Paint()..color = park;
    for (var i = 0; i < 9; i++) {
      final x = (i * 91 + 13) % size.width;
      final y = (i * 43 + 22) % size.height;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, 30, 21),
          const Radius.circular(5),
        ),
        green,
      );
    }
    final roads = Paint()
      ..color = street
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var x = -size.height; x < size.width + size.height; x += 43) {
      canvas.drawLine(
        Offset(x.toDouble(), 0),
        Offset((x + size.height * 0.55).toDouble(), size.height),
        roads,
      );
    }
    for (var y = -size.width; y < size.height + size.width; y += 48) {
      canvas.drawLine(
        Offset(0, y.toDouble()),
        Offset(size.width, y + size.width * 0.22),
        roads,
      );
    }
    if (hasRoute) {
      final path = Path()
        ..moveTo(size.width * 0.2, size.height * 0.3)
        ..lineTo(size.width * 0.37, size.height * 0.46)
        ..lineTo(size.width * 0.53, size.height * 0.37)
        ..lineTo(size.width * 0.8, size.height * 0.64);
      canvas.drawPath(
        path,
        Paint()
          ..color = route
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RoadSketch old) =>
      old.hasRoute != hasRoute ||
      old.background != background ||
      old.route != route ||
      old.street != street ||
      old.park != park;
}
