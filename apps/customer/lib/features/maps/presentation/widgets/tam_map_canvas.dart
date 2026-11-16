import 'package:flutter/foundation.dart';
import 'map_camera_focus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/core/config/map_configuration.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';

import '../../domain/maps_repository.dart';
import 'raster_map_canvas.dart';
import 'vector/vector_map_surface.dart';

class TamMapCanvas extends StatelessWidget {
  const TamMapCanvas({
    super.key,
    required this.configuration,
    this.origin,
    this.destination,
    this.driver,
    this.route,
    this.onSelected,
    this.tileProviderFactory,
    this.onAttribution,
    this.bottomInset,
    this.selection,
    this.onLocate,
    this.locating = false,
    this.focus,
    this.markerIconSize = 36,
  });
  final ValueListenable<double>? bottomInset;
  final GeoPoint? selection;
  final VoidCallback? onLocate;
  final bool locating;
  final MapCameraFocus? focus;
  final double markerIconSize;
  final MapConfiguration configuration;
  final GeoPoint? origin, destination, driver;
  final MapRoute? route;
  final ValueChanged<GeoPoint>? onSelected;
  final TileProvider Function(String)? tileProviderFactory;
  final Future<void> Function()? onAttribution;
  @override
  Widget build(BuildContext context) => configuration.hasVectorStyle
      ? ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: VectorMapSurface(
            configuration: configuration,
            origin: origin,
            destination: destination,
            driver: driver,
            route: route,
            onSelected: onSelected,
            bottomInset: bottomInset,
            selection: selection,
            onLocate: onLocate,
            locating: locating,
            focus: focus,
          ),
        )
      : RasterMapCanvas(
          configuration: configuration,
          origin: origin,
          destination: destination,
          driver: driver,
          route: route,
          onSelected: onSelected,
          bottomInset: bottomInset,
          selection: selection,
          onLocate: onLocate,
          locating: locating,
          focus: focus,
          markerIconSize: markerIconSize,
          tileProviderFactory: tileProviderFactory,
          onAttribution: onAttribution,
        );
}
