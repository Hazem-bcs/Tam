import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'ride_artwork.dart';

class RideVehiclePicker extends StatelessWidget {
  const RideVehiclePicker({
    super.key,
    required this.selected,
    required this.enabled,
    required this.onSelected,
    this.showHeading = true,
  });

  final bool showHeading;
  final RideVehicleClass selected;
  final bool enabled;
  final ValueChanged<RideVehicleClass> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.medium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHeading) ...[
          Text(l10n.rideRequestChooseClass, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
        ],
        for (final vehicle in RideVehicleClass.values) ...[
          Semantics(
            selected: selected == vehicle,
            child: AnimatedContainer(
              key: Key('ride-vehicle-${vehicle.name}'),
              duration: duration,
              curve: AppMotion.easeOut,
              decoration: BoxDecoration(
                color: selected == vehicle
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerLowest,
                border: Border.all(
                  color: selected == vehicle
                      ? theme.colorScheme.primary.withValues(alpha: .55)
                      : theme.colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Material(
                color: theme.colorScheme.surface.withValues(alpha: 0),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: enabled ? () => onSelected(vehicle) : null,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        RideArtwork(
                          type: _artwork(vehicle),
                          width: 68,
                          height: 46,
                          color: selected == vehicle
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                labelFor(l10n, vehicle),
                                style: theme.textTheme.titleSmall,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                _description(l10n, vehicle),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(
                          selected == vehicle
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          size: 20,
                          color: selected == vehicle
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }

  RideArtworkType _artwork(RideVehicleClass vehicle) => switch (vehicle) {
    RideVehicleClass.standard => RideArtworkType.sedan,
    RideVehicleClass.comfort => RideArtworkType.comfort,
    RideVehicleClass.van => RideArtworkType.van,
    RideVehicleClass.motorbike => RideArtworkType.motorbike,
  };

  static String labelFor(AppLocalizations l, RideVehicleClass vehicle) =>
      switch (vehicle) {
        RideVehicleClass.standard => l.rideRequestStandard,
        RideVehicleClass.comfort => l.rideRequestComfort,
        RideVehicleClass.van => l.rideRequestVan,
        RideVehicleClass.motorbike => l.rideRequestMotorbike,
      };

  String _description(AppLocalizations l, RideVehicleClass vehicle) =>
      switch (vehicle) {
        RideVehicleClass.standard => l.rideRequestStandardDescription,
        RideVehicleClass.comfort => l.rideRequestComfortDescription,
        RideVehicleClass.van => l.rideRequestVanDescription,
        RideVehicleClass.motorbike => l.rideRequestMotorbikeDescription,
      };
}
