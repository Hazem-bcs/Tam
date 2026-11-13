import 'package:geolocator/geolocator.dart';
import '../domain/maps_repository.dart';

final class DeviceLocationSettingsAdapter implements DeviceLocationSettings {
  const DeviceLocationSettingsAdapter();

  @override
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();
}
