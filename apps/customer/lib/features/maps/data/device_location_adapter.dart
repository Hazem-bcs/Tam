import 'dart:async';

import 'package:flutter/services.dart';
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
      if (await Geolocator.getLocationAccuracy() ==
          LocationAccuracyStatus.reduced) {
        throw const MapsFailure('LOCATION_PRECISE_REQUIRED');
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
  Future<LocationFix> read() async {
    final clock = Stopwatch()..start();
    var rejected = false;
    try {
      while (true) {
        final remaining = policy.fixTimeout - clock.elapsed;
        if (remaining <= Duration.zero) throw TimeoutException('Location fix');
        final fix = _map(
          await Geolocator.getCurrentPosition(
            locationSettings: LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: remaining,
            ),
          ).timeout(remaining),
        );
        if (policy.accepts(fix, DateTime.now(), verification: true)) return fix;
        rejected = true;
        // A first fused observation can be stale/coarse while GPS warms up.
        // Retry within one deadline; never relabel it as a permission failure.
        final pause = policy.fixTimeout - clock.elapsed;
        if (pause <= Duration.zero) throw TimeoutException('Location fix');
        await Future<void>.delayed(
          pause < const Duration(milliseconds: 500)
              ? pause
              : const Duration(milliseconds: 500),
        );
      }
    } on TimeoutException {
      final code = rejected ? 'LOCATION_INACCURATE' : 'LOCATION_TIMEOUT';
      throw MapsFailure(await _withVpnHint(code));
    } on LocationServiceDisabledException {
      throw const MapsFailure('LOCATION_DISABLED');
    } on PermissionDeniedException {
      await checkAccess(requestPermission: false);
      throw const MapsFailure('LOCATION_UNAVAILABLE');
    }
  }

  Future<String> _withVpnHint(String code) async {
    try {
      final active = await const MethodChannel(
        'tam/location_diagnostics',
      ).invokeMethod<bool>('isVpnActive').timeout(const Duration(seconds: 1));
      if (active == true) return 'LOCATION_VPN_NOTICE';
    } catch (_) {
      // Optional platform diagnostic must never change permission or block GPS.
    }
    return code;
  }

  @override
  Stream<LocationFix> watch() => Geolocator.getPositionStream(
    locationSettings: AndroidSettings(
      accuracy: LocationAccuracy.high,
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
