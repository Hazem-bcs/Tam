import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'vector_map_scene.dart';

/// Fits the *visible* viewport, with a restrained automatic zoom. Manual zoom
/// still reaches street detail; nearby endpoints do not zoom into a building.
abstract final class VectorCamera {
  static CameraUpdate? fit(VectorMapScene scene, Size viewport, double inset) {
    final camera = position(scene, viewport, inset);
    return camera == null ? null : CameraUpdate.newCameraPosition(camera);
  }

  static CameraPosition? position(
    VectorMapScene scene,
    Size viewport,
    double inset,
  ) {
    final points = scene.bounds.toSet().toList();
    if (points.isEmpty) return null;
    if (points.length == 1) {
      final p = points.single;
      return CameraPosition(
        target: LatLng(p.latitude.clamp(-85.0511, 85.0511), p.longitude),
        zoom: 15,
      );
    }
    final ys = points.map((p) => _mercator(p.latitude)).toList()..sort();
    final longitudes = points.map((p) => p.longitude).toList()..sort();
    // Cut the largest empty longitude gap, so dateline routes stay nearby.
    var gap = 0.0, start = 0;
    for (var i = 0; i < longitudes.length; i++) {
      final next = i + 1 < longitudes.length
          ? longitudes[i + 1]
          : longitudes.first + 360;
      if (next - longitudes[i] > gap) {
        gap = next - longitudes[i];
        start = (i + 1) % longitudes.length;
      }
    }
    final west = longitudes[start];
    final east = west + 360 - gap;
    final width = math.max(1, viewport.width - 72);
    final bottom = inset.clamp(0.0, math.max(0.0, viewport.height - 160));
    final height = math.max(1, viewport.height - bottom - 144);
    final dx = (east - west) / 360;
    final dy = (ys.last - ys.first) / (2 * math.pi);
    double zoom(double pixels, double span) =>
        span <= 0 ? 16 : math.log(pixels / (512 * span)) / math.ln2;
    final targetZoom = math
        .min(zoom(width.toDouble(), dx), zoom(height.toDouble(), dy))
        .clamp(3.0, 16.0);
    final latitude =
        (2 * math.atan(math.exp((ys.first + ys.last) / 2)) - math.pi / 2) *
        180 /
        math.pi;
    return CameraPosition(
      target: LatLng(latitude, (west + east) / 2),
      zoom: targetZoom,
    );
  }

  static double _mercator(double latitude) => math.log(
    math.tan(math.pi / 4 + latitude.clamp(-85.0511, 85.0511) * math.pi / 360),
  );
}
