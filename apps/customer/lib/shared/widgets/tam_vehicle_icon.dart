import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tam_customer/shared/presentation/vehicle_marker_kind.dart';

/// Original vector artwork, with the paint inherited from the central theme.
class TamVehicleIcon extends StatelessWidget {
  const TamVehicleIcon({
    super.key,
    this.size = 40,
    this.color,
    this.kind = VehicleMarkerKind.car,
  });
  final VehicleMarkerKind kind;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    kind.asset,
    width: size,
    height: size,
    fit: BoxFit.contain,
    theme: SvgTheme(
      currentColor: color ?? Theme.of(context).colorScheme.primary,
    ),
    excludeFromSemantics: true,
  );
}
