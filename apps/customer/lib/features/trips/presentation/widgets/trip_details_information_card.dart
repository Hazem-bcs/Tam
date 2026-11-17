import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';

/// Reuses the same user-supplied vehicle artwork as the ride request screen.
class TripDetailsInformationCard extends StatelessWidget {
  const TripDetailsInformationCard({super.key, required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final type = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);
    final vehicle = switch (trip.booking.vehicleClassId) {
      'standard' => 'sedan',
      'comfort' => 'comfort',
      'van' => 'van',
      'motorbike' => 'motorbike',
      _ => null,
    };

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
              l.tripsInformation,
              style: type.titleSmall?.copyWith(
                color: colors.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _CaptionedValue(
                    caption: l.tripsVehicleClass,
                    value: tripVehicleLabel(l, trip.booking.vehicleClassId),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (vehicle != null)
                  Image.asset(
                    'assets/maps/vehicle-$vehicle-user.png',
                    width: 86,
                    height: 54,
                    fit: BoxFit.contain,
                    cacheWidth: 256,
                    excludeFromSemantics: true,
                  )
                else
                  Icon(
                    Icons.directions_car_outlined,
                    color: colors.onSurfaceVariant,
                    size: 28,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(height: 1, thickness: 0.7, color: colors.outlineVariant),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text(
                  l.tripsFare,
                  style: type.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    tripMoneyLabel(context, trip.booking.fare),
                    textAlign: TextAlign.end,
                    style: type.titleMedium?.copyWith(
                      color: colors.primary,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l.tripsFareNote,
                    style: type.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 11.5,
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CaptionedValue extends StatelessWidget {
  const _CaptionedValue({required this.caption, required this.value});

  final String caption;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final type = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          caption,
          style: type.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: type.bodyMedium?.copyWith(
            color: colors.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
