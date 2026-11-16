import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'vector_map_scene.dart';
import 'vector_map_style.dart';
import 'vector_marker_images.dart';

/// Native drawing operations stay ordered; a disposed/replaced view stops work.
final class VectorSceneLayers {
  VectorSceneLayers(
    this.controller,
    this.isCurrent,
    this.primary,
    this.surface, {
    this.loadMarker = VectorMarkerImages.load,
  });
  final MapLibreMapController controller;
  final bool Function() isCurrent;
  final Color primary, surface;
  final Future<Uint8List> Function(String, Color) loadMarker;
  static const source = 'tam-customer-scene';

  Future<bool> install() async {
    final car = await loadMarker(VectorMarkerImages.car, primary);
    if (!isCurrent()) return false;
    final pin = await loadMarker(VectorMarkerImages.destination, primary);
    final ink = VectorMapStyle.color(primary);
    final paper = VectorMapStyle.color(surface);
    final steps = <Future<void> Function()>[
      () => controller.addImage('tam-car', car),
      () => controller.addImage('tam-pin', pin),
      () => controller.addGeoJsonSource(
        source,
        const VectorMapScene().toGeoJson(),
      ),
      () => controller.addLineLayer(
        source,
        'tam-route-casing',
        LineLayerProperties(
          lineColor: paper,
          lineWidth: 8,
          lineJoin: 'round',
          lineCap: 'round',
        ),
        filter: _kind('route'),
        enableInteraction: false,
      ),
      () => controller.addLineLayer(
        source,
        'tam-route',
        LineLayerProperties(
          lineColor: ink,
          lineWidth: 4.5,
          lineJoin: 'round',
          lineCap: 'round',
        ),
        filter: _kind('route'),
        enableInteraction: false,
      ),
      () => controller.addCircleLayer(
        source,
        'tam-pickup',
        CircleLayerProperties(
          circleColor: ink,
          circleRadius: 8,
          circleStrokeColor: paper,
          circleStrokeWidth: 3,
        ),
        filter: _kind('origin'),
        enableInteraction: false,
      ),
      () => controller.addCircleLayer(
        source,
        'tam-pickup-center',
        CircleLayerProperties(circleColor: paper, circleRadius: 3),
        filter: _kind('origin'),
        enableInteraction: false,
      ),
      () => controller.addSymbolLayer(
        source,
        'tam-stops',
        const SymbolLayerProperties(
          iconImage: 'tam-pin',
          iconSize: .55,
          iconAnchor: 'bottom',
          iconAllowOverlap: true,
          iconIgnorePlacement: true,
        ),
        filter: [
          'in',
          ['get', 'kind'],
          [
            'literal',
            ['destination'],
          ],
        ],
        enableInteraction: false,
      ),
      () => controller.addSymbolLayer(
        source,
        'tam-driver',
        const SymbolLayerProperties(
          iconImage: 'tam-car',
          iconSize: .4,
          iconAnchor: 'center',
          iconAllowOverlap: true,
          iconIgnorePlacement: true,
          iconRotationAlignment: 'map',
        ),
        filter: _kind('driver'),
        enableInteraction: false,
      ),
    ];
    for (final step in steps) {
      if (!isCurrent()) return false;
      await step();
    }
    return isCurrent();
  }

  Future<void> update(VectorMapScene scene) =>
      controller.setGeoJsonSource(source, scene.toGeoJson());

  static List<Object> _kind(String value) => [
    '==',
    ['get', 'kind'],
    value,
  ];
}
