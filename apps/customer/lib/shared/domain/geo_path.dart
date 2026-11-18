import 'dart:math' as math;

import 'geo_point.dart';

/// Distance-parametrized path; independent of widgets and map providers.
final class GeoPath {
  GeoPath(List<GeoPoint> points) : points = List.unmodifiable(points) {
    for (var i = 1; i < points.length; i++) {
      _distances.add(_distances.last + meters(points[i - 1], points[i]));
    }
  }
  final List<GeoPoint> points;
  final List<double> _distances = [0];
  double get length => _distances.last;

  GeoPoint at(double distance) {
    if (points.isEmpty) throw StateError('Empty path');
    if (length == 0 || distance <= 0) return points.first;
    if (distance >= length) return points.last;
    final d = distance.clamp(0.0, length);
    for (var i = 1; i < points.length; i++) {
      if (d <= _distances[i]) {
        final segment = _distances[i] - _distances[i - 1];
        return mix(
          points[i - 1],
          points[i],
          segment == 0 ? 0 : (d - _distances[i - 1]) / segment,
        );
      }
    }
    return points.last;
  }

  ({double distance, double error}) project(GeoPoint point) {
    var closest = double.infinity, along = 0.0;
    for (var i = 1; i < points.length; i++) {
      final a = points[i - 1], b = points[i];
      final cosine = math.cos(point.latitude * math.pi / 180);
      final dx = _longitude(b.longitude - a.longitude) * cosine;
      final dy = b.latitude - a.latitude;
      final px = _longitude(point.longitude - a.longitude) * cosine;
      final py = point.latitude - a.latitude;
      final denominator = dx * dx + dy * dy;
      final t = denominator == 0
          ? 0.0
          : ((px * dx + py * dy) / denominator).clamp(0.0, 1.0);
      final error = meters(point, mix(a, b, t));
      if (error < closest) {
        closest = error;
        along = _distances[i - 1] + (_distances[i] - _distances[i - 1]) * t;
      }
    }
    return (distance: along, error: closest);
  }

  double headingAt(double distance) {
    final d = distance.clamp(0.0, length);
    return bearing(at(math.max(0, d - 4)), at(math.min(length, d + 8)));
  }

  static GeoPoint mix(GeoPoint a, GeoPoint b, double t) => t <= 0
      ? a
      : t >= 1
      ? b
      : GeoPoint(
          latitude: a.latitude + (b.latitude - a.latitude) * t,
          longitude: _longitude(
            a.longitude + _longitude(b.longitude - a.longitude) * t,
          ),
        );
  static double _longitude(double value) => (value + 180) % 360 - 180;
  static double meters(GeoPoint a, GeoPoint b) {
    const r = 6371000.0;
    final lat1 = a.latitude * math.pi / 180, lat2 = b.latitude * math.pi / 180;
    final dLat = lat2 - lat1;
    final dLng = _longitude(b.longitude - a.longitude) * math.pi / 180;
    final h =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dLng / 2), 2);
    return r * 2 * math.asin(math.sqrt(h.clamp(0.0, 1.0)));
  }

  static double bearing(GeoPoint a, GeoPoint b) {
    final lat1 = a.latitude * math.pi / 180, lat2 = b.latitude * math.pi / 180;
    final lng = _longitude(b.longitude - a.longitude) * math.pi / 180;
    return (math.atan2(
                  math.sin(lng) * math.cos(lat2),
                  math.cos(lat1) * math.sin(lat2) -
                      math.sin(lat1) * math.cos(lat2) * math.cos(lng),
                ) *
                180 /
                math.pi +
            360) %
        360;
  }

  static double turn(double from, double to, double t) =>
      (from + ((to - from + 540) % 360 - 180) * t + 360) % 360;
}
