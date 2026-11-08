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
  });

  final RideVehicleClass selected;
  final bool enabled;
  final ValueChanged<RideVehicleClass> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.rideRequestChooseClass, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        for (final vehicle in RideVehicleClass.values) ...[
          TamCard(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            onTap: enabled ? () => onSelected(vehicle) : null,
            child: Row(
              children: [
                Icon(
                  _icon(vehicle),
                  size: 32,
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
                        _name(l10n, vehicle),
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
                Icon(
                  selected == vehicle
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected == vehicle
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                ),
              ],
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

  String _name(AppLocalizations l, RideVehicleClass vehicle) =>
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
