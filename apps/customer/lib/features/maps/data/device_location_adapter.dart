import 'package:geolocator/geolocator.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';

import '../domain/location_fix.dart';
import '../domain/maps_repository.dart';

final class DeviceLocationAdapter implements DeviceLocation, LocationSensor {
  DeviceLocationAdapter({this.policy = const LocationPolicy()});
  final LocationPolicy policy;

  @override
  Future<void> checkAccess({required bool requestPermission}) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const MapsFailure('LOCATION_DISABLED');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && requestPermission) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw const MapsFailure('LOCATION_DENIED_FOREVER');
      }
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw const MapsFailure('LOCATION_DENIED');
      }
    } on MapsFailure {
      rethrow;
    } catch (_) {
      throw const MapsFailure('LOCATION_UNAVAILABLE');
    }
  }

  LocationFix _map(Position position) => LocationFix(
    point: GeoPoint(latitude: position.latitude, longitude: position.longitude),
    capturedAt: position.timestamp.toUtc(),
    accuracyMeters: position.accuracy,
  );

  @override
  Future<LocationFix> read() async => _map(
    await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: policy.fixTimeout,
      ),
    ),
  );

  @override
  Stream<LocationFix> watch() => Geolocator.getPositionStream(
    locationSettings: AndroidSettings(
      accuracy: LocationAccuracy.medium,
      distanceFilter: policy.updateDistanceMeters,
      intervalDuration: policy.updateInterval,
    ),
  ).map(_map);

  @override
  Stream<bool> watchService() => Geolocator.getServiceStatusStream().map(
    (status) => status == ServiceStatus.enabled,
  );

  @override
  Future<GeoPoint> locate({bool requireFresh = false}) async {
    await checkAccess(requestPermission: true);
    final fix = await read();
    if (!policy.accepts(fix, DateTime.now(), verification: requireFresh)) {
      throw const MapsFailure('LOCATION_INACCURATE');
    }
    return fix.point;
  }
}
