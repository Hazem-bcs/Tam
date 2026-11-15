import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// A quiet, recognizable two-stop motif used across active/history cards.
class TripJourney extends StatelessWidget {
  const TripJourney({
    super.key,
    required this.pickup,
    required this.destination,
    this.onDark = false,
  });

  final TripLocation pickup;
  final TripLocation destination;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final labels = AppLocalizations.of(context);
    final primary = onDark ? colors.onPrimary : colors.primary;
    final body = onDark ? colors.onPrimary : colors.onSurface;
    final muted = onDark
        ? colors.onPrimary.withValues(alpha: .70)
        : colors.onSurfaceVariant;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle_rounded, color: primary, size: 10),
              SizedBox(
                height: 25,
                child: CustomPaint(
                  painter: _RouteStem(primary.withValues(alpha: .58)),
                  child: const SizedBox.expand(),
                ),
              ),
              Icon(Icons.location_on_rounded, color: primary, size: 17),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${labels.tripsFrom} ${pickup.label}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.bodySmall?.copyWith(color: muted),
              ),
              const SizedBox(height: 7),
              Text(
                '${labels.tripsTo} ${destination.label}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.titleSmall?.copyWith(
                  color: body,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RouteStem extends CustomPainter {
  const _RouteStem(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round;
    final x = size.width * .5;
    for (var y = 2.0; y < size.height - 2; y += 8) {
      canvas.drawLine(
        Offset(x, y),
        Offset(x, (y + 3.6).clamp(0, size.height)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RouteStem oldDelegate) =>
      oldDelegate.color != color;
}
