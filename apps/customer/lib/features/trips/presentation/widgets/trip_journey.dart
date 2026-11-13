import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// A compact vertical pickup-to-destination timeline.
class TripJourney extends StatelessWidget {
  const TripJourney({
    super.key,
    required this.pickup,
    required this.destination,
  });
  final TripLocation pickup;
  final TripLocation destination;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Icon(Icons.circle, size: 12, color: scheme.primary),
              ),
              SizedBox(
                height: 35,
                child: CustomPaint(
                  painter: _RouteDashPainter(scheme.primary),
                  child: const SizedBox.expand(),
                ),
              ),
              Icon(Icons.location_on, size: 20, color: scheme.primary),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PlaceLabel(prefix: l.tripsFrom, place: pickup.label),
              const SizedBox(height: AppSpacing.lg),
              _PlaceLabel(prefix: l.tripsTo, place: destination.label),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlaceLabel extends StatelessWidget {
  const _PlaceLabel({required this.prefix, required this.place});
  final String prefix;
  final String place;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          prefix,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            place,
            softWrap: true,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _RouteDashPainter extends CustomPainter {
  const _RouteDashPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final x = size.width / 2;
    for (var y = 3.0; y < size.height - 2; y += 8) {
      canvas.drawLine(
        Offset(x, y),
        Offset(x, (y + 4).clamp(0, size.height)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RouteDashPainter oldDelegate) =>
      oldDelegate.color != color;
}
