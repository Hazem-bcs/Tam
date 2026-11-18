import 'package:equatable/equatable.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/presentation/vehicle_marker_kind.dart';

import '../../../domain/maps_repository.dart';

/// Renderer-only GeoJSON mapping. The domain remains independent of MapLibre.
final class VectorMapScene extends Equatable {
  const VectorMapScene({
    this.origin,
    this.destination,
    this.selection,
    this.driver,
    this.driverVehicle = VehicleMarkerKind.car,
    this.driverBearing = 0,
    this.deviceLocation,
    this.route,
  });
  final GeoPoint? origin, destination, selection, driver, deviceLocation;
  VectorMapScene withDeviceLocation(GeoPoint? point) => VectorMapScene(
    origin: origin,
    destination: destination,
    selection: selection,
    driver: driver,
    driverVehicle: driverVehicle,
    driverBearing: driverBearing,
    route: route,
    deviceLocation: point,
  );
  final VehicleMarkerKind driverVehicle;
  final MapRoute? route;
  final double driverBearing;

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
        ('device', deviceLocation),
      ])
        if (entry.$2 != null)
          {
            'type': 'Feature',
            'properties': {
              'kind': entry.$1,
              if (entry.$1 == 'driver') ...{
                'bearing': driverBearing,
                'vehicle_icon': driverVehicle.spriteId,
              },
            },
            'geometry': {'type': 'Point', 'coordinates': coordinate(entry.$2!)},
          },
    ],
  };

  static List<double> coordinate(GeoPoint p) => [
    p.longitude,
    p.latitude.clamp(-85.0511, 85.0511),
  ];

  @override
  List<Object?> get props => [
    origin,
    destination,
    selection,
    driver,
    driverBearing,
    driverVehicle,
    route,
    deviceLocation,
  ];
}
