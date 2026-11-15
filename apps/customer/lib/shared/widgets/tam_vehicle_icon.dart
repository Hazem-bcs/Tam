import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Original vector artwork, with the paint inherited from the central theme.
class TamVehicleIcon extends StatelessWidget {
  const TamVehicleIcon({super.key, this.size = 40, this.color});
  static const asset = 'assets/maps/car-top.svg';
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    asset,
    width: size,
    height: size,
    fit: BoxFit.contain,
    theme: SvgTheme(
      currentColor: color ?? Theme.of(context).colorScheme.primary,
    ),
    excludeFromSemantics: true,
  );
}
