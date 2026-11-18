import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:tam_customer/features/maps/data/device_location_adapter.dart';
import 'package:tam_customer/features/maps/domain/location_fix.dart';
import 'package:tam_customer/features/maps/domain/maps_repository.dart';
import 'maps_test_support.dart';

class PlatformProbe extends GeolocatorPlatform {
  bool enabled = true;
  LocationPermission permission = LocationPermission.denied,
      requested = LocationPermission.whileInUse;
  int requests = 0, fixes = 0;
  LocationAccuracyStatus accuracy = LocationAccuracyStatus.precise;
  final samples = <Position>[];
  bool timeout = false;
  double defaultAccuracy = 10;
  @override
  Future<LocationAccuracyStatus> getLocationAccuracy() async => accuracy;
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
    expect(locationSettings!.timeLimit! <= const Duration(seconds: 15), isTrue);
    if (timeout) throw TimeoutException('No fix');
    if (samples.isNotEmpty) return samples.removeAt(0);
    return Position(
      latitude: origin.latitude,
      longitude: origin.longitude,
      timestamp: DateTime.now(),
      accuracy: defaultAccuracy,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }
}

Position sample({double accuracy = 10, Duration age = Duration.zero}) =>
    Position(
      latitude: origin.latitude,
      longitude: origin.longitude,
      timestamp: DateTime.now().subtract(age),
      accuracy: accuracy,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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
  test('granted permission is reused without another prompt', () async {
    platform.permission = LocationPermission.whileInUse;
    expect(await DeviceLocationAdapter().locate(), origin);
    expect(platform.requests, 0);
  });
  test('approximate permission is distinct from denied or disabled', () async {
    platform.permission = LocationPermission.whileInUse;
    platform.accuracy = LocationAccuracyStatus.reduced;
    await expectLater(
      DeviceLocationAdapter().locate(),
      throwsA(
        isA<MapsFailure>().having(
          (e) => e.code,
          'code',
          'LOCATION_PRECISE_REQUIRED',
        ),
      ),
    );
    expect(platform.requests, 0);
    expect(platform.fixes, 0);
  });
  test(
    'first coarse or stale fix is retried until a precise fresh fix',
    () async {
      platform.samples.addAll([
        sample(accuracy: 1500),
        sample(age: const Duration(minutes: 2)),
        sample(),
      ]);
      expect(await DeviceLocationAdapter().locate(requireFresh: true), origin);
      expect(platform.fixes, 3);
      expect(platform.requests, 1);
    },
  );
  test(
    'inaccurate readings remain bounded and never become accepted pickup',
    () async {
      platform.defaultAccuracy = 1500;
      await expectLater(
        DeviceLocationAdapter(
          policy: const LocationPolicy(fixTimeout: Duration(milliseconds: 20)),
        ).locate(),
        throwsA(
          isA<MapsFailure>().having(
            (e) => e.code,
            'code',
            'LOCATION_INACCURATE',
          ),
        ),
      );
    },
  );
  test(
    'VPN notice is conditional on real detection after a failed acquisition',
    () async {
      const channel = MethodChannel('tam/location_diagnostics');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (_) async => true);
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      // A successful GPS fix must never be blocked by the VPN.
      expect(await DeviceLocationAdapter().locate(), origin);
      platform.timeout = true;
      await expectLater(
        DeviceLocationAdapter().locate(),
        throwsA(
          isA<MapsFailure>().having(
            (e) => e.code,
            'code',
            'LOCATION_VPN_NOTICE',
          ),
        ),
      );
    },
  );
  test('missing VPN diagnostic keeps the true timeout error', () async {
    platform.timeout = true;
    await expectLater(
      DeviceLocationAdapter().locate(),
      throwsA(
        isA<MapsFailure>().having((e) => e.code, 'code', 'LOCATION_TIMEOUT'),
      ),
    );
  });
}
