import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/presentation/vehicle_marker_kind.dart';
import 'package:tam_customer/shared/widgets/tam_vehicle_icon.dart';

/// Vehicle artwork for live phases; terminal/scheduled artwork retains meaning.
class ActiveVehicleBadge extends StatelessWidget {
  const ActiveVehicleBadge({
    super.key,
    required this.status,
    required this.kind,
  });
  final TripStatus status;
  final VehicleMarkerKind kind;

  @override
  Widget build(BuildContext context) {
    final art = switch (status) {
      TripStatus.scheduled => 'ride_scheduled',
      TripStatus.completed => 'ride_completed',
      TripStatus.cancelled || TripStatus.noDriver => 'ride_cancelled',
      _ => null,
    };
    if (art != null || kind == VehicleMarkerKind.car) {
      return Image.asset(
        'assets/notifications/${art ?? 'driver_arrived'}.webp',
        width: 48,
        height: 48,
        excludeFromSemantics: true,
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: TamVehicleIcon(kind: kind, size: 40),
      ),
    );
  }
}
