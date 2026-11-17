import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'ride_artwork.dart';

class RideVehiclePicker extends StatefulWidget {
  const RideVehiclePicker({
    super.key,
    required this.selected,
    required this.enabled,
    required this.onSelected,
    this.showHeading = true,
    this.quotes = const {},
    this.vehicles = RideVehicleClass.values,
  });
  final bool showHeading;
  final RideVehicleClass selected;
  final bool enabled;
  final ValueChanged<RideVehicleClass> onSelected;
  final Map<RideVehicleClass, RideQuote> quotes;
  final List<RideVehicleClass> vehicles;

  static String labelFor(AppLocalizations l, RideVehicleClass vehicle) =>
      switch (vehicle) {
        RideVehicleClass.standard => l.rideRequestStandard,
        RideVehicleClass.comfort => l.rideRequestComfort,
        RideVehicleClass.van => l.rideRequestVan,
        RideVehicleClass.motorbike => l.rideRequestMotorbike,
      };
  static String descriptionFor(AppLocalizations l, RideVehicleClass vehicle) =>
      switch (vehicle) {
        RideVehicleClass.standard => l.rideRequestStandardDescription,
        RideVehicleClass.comfort => l.rideRequestComfortDescription,
        RideVehicleClass.van => l.rideRequestVanDescription,
        RideVehicleClass.motorbike => l.rideRequestMotorbikeDescription,
      };
  @override
  State<RideVehiclePicker> createState() => _RideVehiclePickerState();
}

class _RideVehiclePickerState extends State<RideVehiclePicker> {
  final _scroll = ScrollController();
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _move(double delta) {
    if (!_scroll.hasClients) return;
    final target = (_scroll.offset + delta).clamp(
      0.0,
      _scroll.position.maxScrollExtent,
    );
    if (MediaQuery.disableAnimationsOf(context)) {
      _scroll.jumpTo(target);
    } else {
      _scroll.animateTo(
        target,
        duration: AppMotion.medium,
        curve: AppMotion.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), theme = Theme.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.showHeading
                      ? l.rideRequestChooseClass
                      : l.rideRequestVehicleScrollHint,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _move(-180),
                tooltip: l.rideRequestPreviousVehicles,
                icon: Icon(rtl ? Icons.chevron_right : Icons.chevron_left),
              ),
              IconButton(
                onPressed: () => _move(180),
                tooltip: l.rideRequestNextVehicles,
                icon: Icon(rtl ? Icons.chevron_left : Icons.chevron_right),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          key: const Key('ride-vehicle-scroll'),
          controller: _scroll,
          scrollDirection: Axis.horizontal,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final vehicle in widget.vehicles)
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      end: vehicle == widget.vehicles.last ? 0 : AppSpacing.sm,
                    ),
                    child: SizedBox(
                      width: 118 + (scale - 1).clamp(0, 3) * 64,
                      child: _VehicleCard(
                        vehicle: vehicle,
                        selected: widget.selected == vehicle,
                        onTap: widget.enabled
                            ? () => widget.onSelected(vehicle)
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text(
            RideVehiclePicker.descriptionFor(l, widget.selected),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.selected,
    required this.onTap,
  });
  final RideVehicleClass vehicle;
  final bool selected;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), theme = Theme.of(context);
    final c = theme.colorScheme;
    final label = RideVehiclePicker.labelFor(l, vehicle);
    return Semantics(
      selected: selected,
      button: true,
      child: AnimatedContainer(
        key: Key('ride-vehicle-${vehicle.name}'),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : AppMotion.medium,
        decoration: BoxDecoration(
          color: selected ? c.primaryContainer : c.surfaceContainerLowest,
          border: Border.all(color: selected ? c.primary : c.outlineVariant),
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Material(
          color: c.surface.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: Icon(
                      selected ? Icons.check_circle : Icons.circle_outlined,
                      size: 16,
                      color: selected ? c.primary : c.outlineVariant,
                    ),
                  ),
                  RideArtwork(
                    type: switch (vehicle) {
                      RideVehicleClass.standard => RideArtworkType.sedan,
                      RideVehicleClass.comfort => RideArtworkType.comfort,
                      RideVehicleClass.van => RideArtworkType.van,
                      RideVehicleClass.motorbike => RideArtworkType.motorbike,
                    },
                    width: 88,
                    height: 54,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
