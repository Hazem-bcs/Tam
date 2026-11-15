import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_map_colors.dart';

/// Transforms a bundled Liberty document, preserving its sources and licenses.
/// This is a rendering resource, not a booking/domain model or HTTP service.
abstract final class VectorMapStyle {
  static String color(Color color) =>
      '#${(color.toARGB32() & 0xffffff).toRadixString(16).padLeft(6, '0')}';

  static String build(String template, AppMapColors palette, String language) {
    final document = jsonDecode(template) as Map<String, dynamic>;
    if (document['version'] != 8 ||
        document['sources'] is! Map ||
        document['layers'] is! List) {
      throw const FormatException('Invalid vector map style');
    }
    for (final layer in document['layers'] as List) {
      final id = layer['id'] as String;
      final source = layer['source-layer'];
      final paint = Map<String, dynamic>.from(layer['paint'] as Map? ?? {});
      final layout = Map<String, dynamic>.from(layer['layout'] as Map? ?? {});
      switch (layer['type']) {
        case 'background':
          paint['background-color'] = color(palette.land);
        case 'raster':
          // Avoid the unrelated colored Natural Earth backdrop at low zooms.
          layout['visibility'] = 'none';
        case 'fill' || 'fill-extrusion':
          final fill = switch (source) {
            'building' => palette.building,
            'water' => palette.water,
            'park' || 'landcover' => palette.green,
            'transportation' || 'aeroway' => palette.road,
            _ => palette.land,
          };
          final prefix = layer['type'] as String;
          paint['$prefix-color'] = color(fill);
          paint.remove('fill-pattern');
          if (paint.containsKey('fill-outline-color')) {
            paint['fill-outline-color'] = color(palette.buildingOutline);
          }
        case 'line':
          final line = switch (source) {
            'transportation' || 'aeroway' =>
              id.contains('casing')
                  ? palette.roadCasing
                  : id.contains('motorway') || id.contains('trunk_primary')
                  ? palette.majorRoad
                  : palette.road,
            'waterway' => palette.water,
            'park' => palette.green,
            'building' => palette.buildingOutline,
            _ => palette.secondaryText,
          };
          paint['line-color'] = color(line);
        case 'symbol':
          final original = layout['text-field'];
          if (_usesName(original)) {
            final names = language == 'ar'
                ? ['name:ar', 'name', 'name:nonlatin', 'name:latin']
                : ['name:en', 'name_en', 'name:latin', 'name'];
            layout['text-field'] = [
              'case',
              for (final name in names) ...[
                [
                  '!=',
                  [
                    'coalesce',
                    ['get', name],
                    '',
                  ],
                  '',
                ],
                ['get', name],
              ],
              if (original is List) original else '',
            ];
            layout['text-font'] = [
              (layout['text-font'] as List?)?.contains('Noto Sans Bold') == true
                  ? 'Noto Sans Bold'
                  : 'Noto Sans Regular',
            ];
            layout['text-letter-spacing'] = 0;
            paint['text-color'] = color(
              source == 'poi' ? palette.secondaryText : palette.text,
            );
            paint['text-halo-color'] = color(palette.land);
            paint['text-halo-width'] = 1.3;
            paint['text-halo-blur'] = .4;
          }
          if (source == 'poi' && (id == 'poi_r7' || id == 'poi_r20')) {
            final minimum = id == 'poi_r7' ? 17 : 18;
            final zoom = layer['minzoom'] as num? ?? 0;
            layer['minzoom'] = zoom > minimum ? zoom : minimum;
          }
      }
      layer['paint'] = paint;
      if (layout.isNotEmpty) layer['layout'] = layout;
    }
    return jsonEncode(document);
  }

  static bool _usesName(dynamic expression) {
    if (expression is String) return expression.contains('{name');
    if (expression is! List) return false;
    if (expression.length > 1 && expression.first == 'get') {
      return (expression[1] as String).startsWith('name');
    }
    return expression.any(_usesName);
  }
}
