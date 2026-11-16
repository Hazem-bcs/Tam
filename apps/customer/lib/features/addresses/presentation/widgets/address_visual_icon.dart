import 'package:flutter/material.dart';
import '../../domain/saved_address.dart';

/// A small, transparent product icon. Raster artwork is intentionally kept
/// separate from tappable controls and from the map's semantic marker.
class AddressVisualIcon extends StatelessWidget {
  const AddressVisualIcon({super.key, required this.category, this.size = 56});

  final AddressIcon category;
  final double size;

  static String assetFor(AddressIcon category) =>
      'assets/images/address_${category.name}.webp';

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Image.asset(
        assetFor(category),
        width: size,
        height: size,
        filterQuality: FilterQuality.medium,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// Only a pin motif is custom artwork; all action controls remain native.
class AddressPinArtwork extends StatelessWidget {
  const AddressPinArtwork({super.key, this.size = 112});
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Image.asset(
      'assets/images/address_pin.webp',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    ),
  );
}
