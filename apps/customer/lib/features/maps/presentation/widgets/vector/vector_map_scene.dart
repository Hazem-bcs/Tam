import 'package:equatable/equatable.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import '../../../domain/maps_repository.dart';

/// Renderer-only GeoJSON mapping. The domain remains independent of MapLibre.
final class VectorMapScene extends Equatable {
  const VectorMapScene({
    this.origin,
    this.destination,
    this.selection,
    this.driver,
    this.route,
  });
  final GeoPoint? origin, destination, selection, driver;
  final MapRoute? route;

  List<GeoPoint> get bounds => [?origin, ?destination, ...?route?.points];

  Map<String, dynamic> toGeoJson() => {
    'type': 'FeatureCollection',
    'features': [
      if (route != null)
        {
          'type': 'Feature',
          'properties': {'kind': 'route'},
          'geometry': {
            'type': 'LineString',
            'coordinates': route!.points.map(coordinate).toList(),
          },
        },
      for (final entry in [
        ('origin', origin),
        ('destination', destination),
        ('selection', selection),
        ('driver', driver),
      ])
        if (entry.$2 != null)
          {
            'type': 'Feature',
            'properties': {'kind': entry.$1},
            'geometry': {'type': 'Point', 'coordinates': coordinate(entry.$2!)},
          },
    ],
  };

  static List<double> coordinate(GeoPoint p) => [
    p.longitude,
    p.latitude.clamp(-85.0511, 85.0511),
  ];

  @override
  List<Object?> get props => [origin, destination, selection, driver, route];
}
