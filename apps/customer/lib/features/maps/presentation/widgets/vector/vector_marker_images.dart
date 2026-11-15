import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tam_customer/shared/widgets/tam_vehicle_icon.dart';

/// A map sprite is rasterized once from our SVG, then owned by the native map.
/// No SVG parsing, downloads or image conversion occurs per GPS update.
abstract final class VectorMarkerImages {
  static Future<Uint8List> load(String asset, Color primary) async {
    final picture = await vg.loadPicture(
      SvgAssetLoader(asset, theme: SvgTheme(currentColor: primary)),
      null,
    );
    try {
      final image = await picture.picture.toImage(
        picture.size.width.round(),
        picture.size.height.round(),
      );
      try {
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        if (bytes == null) throw StateError('Map marker conversion failed');
        return bytes.buffer.asUint8List();
      } finally {
        image.dispose();
      }
    } finally {
      picture.picture.dispose();
    }
  }

  static const car = TamVehicleIcon.asset;
  static const destination = 'assets/maps/destination.svg';
}
