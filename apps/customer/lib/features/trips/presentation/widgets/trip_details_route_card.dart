import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// Text-only route timeline: no decorative map pretending to show the real
/// street path, and no duplicate vehicle illustration.
class TripDetailsRouteCard extends StatelessWidget {
  const TripDetailsRouteCard({super.key, required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final type = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.tripsRoute,
              style: type.titleSmall?.copyWith(
                color: colors.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _StopRow(
              label: l.tripsFrom,
              address: trip.booking.pickup.label,
              destination: false,
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 7),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  width: 1.5,
                  height: 24,
                  color: colors.outlineVariant,
                ),
              ),
            ),
            _StopRow(
              label: l.tripsTo,
              address: trip.booking.destination.label,
              destination: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({
    required this.label,
    required this.address,
    required this.destination,
  });
  final String label;
  final String address;
  final bool destination;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final type = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 5),
          child: Icon(
            destination ? Icons.location_on_rounded : Icons.circle_outlined,
            size: 16,
            color: colors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: type.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                address,
                style: type.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
