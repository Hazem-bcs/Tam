import 'package:geolocator/geolocator.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import '../domain/maps_repository.dart';

final class DeviceLocationAdapter implements DeviceLocation {
  @override
  Future<GeoPoint> locate() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const MapsFailure('LOCATION_DISABLED');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw const MapsFailure('LOCATION_DENIED_FOREVER');
      }
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw const MapsFailure('LOCATION_DENIED');
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return GeoPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on MapsFailure {
      rethrow;
    } catch (_) {
      throw const MapsFailure('LOCATION_UNAVAILABLE');
    }
  }
}
