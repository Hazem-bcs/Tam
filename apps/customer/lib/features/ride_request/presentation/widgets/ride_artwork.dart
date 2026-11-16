import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum RideArtworkType { sedan, comfort, van, motorbike, mapSelect, place }

/// User-supplied transparent vehicle artwork; map actions retain themed SVGs.
class RideArtwork extends StatelessWidget {
  const RideArtwork({
    super.key,
    required this.type,
    this.width = 64,
    this.height = 44,
    this.color,
  });
  final RideArtworkType type;
  final double width, height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final vehicle = switch (type) {
      RideArtworkType.sedan => 'sedan',
      RideArtworkType.comfort => 'comfort',
      RideArtworkType.van => 'van',
      RideArtworkType.motorbike => 'motorbike',
      _ => null,
    };
    if (vehicle != null) {
      return Image.asset(
        'assets/maps/vehicle-$vehicle-user.png',
        width: width,
        height: height,
        fit: BoxFit.contain,
        cacheWidth: 320,
        excludeFromSemantics: true,
      );
    }
    return SvgPicture.asset(
      'assets/maps/${switch (type) {
        RideArtworkType.sedan => 'vehicle-sedan',
        RideArtworkType.comfort => 'vehicle-comfort',
        RideArtworkType.van => 'vehicle-van',
        RideArtworkType.motorbike => 'vehicle-motorbike',
        RideArtworkType.mapSelect => 'map-select',
        RideArtworkType.place => 'place-pin',
      }}.svg',
      width: width,
      height: height,
      fit: BoxFit.contain,
      theme: SvgTheme(
        currentColor: color ?? Theme.of(context).colorScheme.primary,
      ),
      excludeFromSemantics: true,
    );
  }
}
