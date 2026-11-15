import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:tam_customer/features/maps/data/device_location_adapter.dart';
import 'package:tam_customer/features/maps/domain/maps_repository.dart';
import 'maps_test_support.dart';

class PlatformProbe extends GeolocatorPlatform {
  bool enabled = true;
  LocationPermission permission = LocationPermission.denied,
      requested = LocationPermission.whileInUse;
  int requests = 0, fixes = 0;
  @override
  Future<bool> isLocationServiceEnabled() async => enabled;
  @override
  Future<LocationPermission> checkPermission() async => permission;
  @override
  Future<LocationPermission> requestPermission() async {
    requests++;
    return requested;
  }

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    fixes++;
    expect(locationSettings!.timeLimit, const Duration(seconds: 15));
    return Position(
      latitude: origin.latitude,
      longitude: origin.longitude,
      timestamp: DateTime.now(),
      accuracy: 10,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }
}

void main() {
  late GeolocatorPlatform previous;
  late PlatformProbe platform;
  setUp(() {
    previous = GeolocatorPlatform.instance;
    platform = PlatformProbe();
    GeolocatorPlatform.instance = platform;
  });
  tearDown(() => GeolocatorPlatform.instance = previous);
  test(
    'only an explicit call asks permission and obtains a single foreground fix',
    () async {
      final a = DeviceLocationAdapter();
      expect(platform.requests, 0);
      expect(platform.fixes, 0);
      expect(await a.locate(), origin);
      expect(platform.requests, 1);
      expect(platform.fixes, 1);
    },
  );
  for (final mode in ['disabled', 'denied', 'permanent']) {
    test('$mode never reads a position', () async {
      platform.enabled = mode != 'disabled';
      platform.requested = mode == 'permanent'
          ? LocationPermission.deniedForever
          : LocationPermission.denied;
      await expectLater(
        DeviceLocationAdapter().locate(),
        throwsA(isA<MapsFailure>()),
      );
      expect(platform.fixes, 0);
    });
  }
}
