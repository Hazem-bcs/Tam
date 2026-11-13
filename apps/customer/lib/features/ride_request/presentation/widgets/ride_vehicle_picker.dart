import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';

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
          TamCard(
            padding: EdgeInsets.zero,
            onTap: enabled ? () => onSelected(vehicle) : null,
            child: AnimatedContainer(
              key: Key('ride-vehicle-${vehicle.name}'),
              duration: duration,
              curve: AppMotion.easeOut,
              margin: const EdgeInsetsDirectional.all(AppSpacing.xs),
              padding: const EdgeInsetsDirectional.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.md),
                color: selected == vehicle
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerLowest,
              ),
              child: Row(
                children: [
                  AnimatedScale(
                    duration: duration,
                    curve: AppMotion.easeOut,
                    scale: selected == vehicle ? 1 : 0.91,
                    child: Icon(
                      _icon(vehicle),
                      size: 32,
                      color: selected == vehicle
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
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
                  AnimatedSwitcher(
                    duration: duration,
                    switchInCurve: AppMotion.easeOut,
                    switchOutCurve: AppMotion.easeIn,
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      selected == vehicle
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      key: ValueKey(selected == vehicle),
                      color: selected == vehicle
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }

  IconData _icon(RideVehicleClass vehicle) => switch (vehicle) {
    RideVehicleClass.standard => Icons.directions_car_outlined,
    RideVehicleClass.comfort => Icons.airport_shuttle_outlined,
    RideVehicleClass.van => Icons.directions_bus_outlined,
    RideVehicleClass.motorbike => Icons.two_wheeler_outlined,
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
