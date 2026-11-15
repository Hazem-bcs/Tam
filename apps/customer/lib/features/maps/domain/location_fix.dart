import 'dart:math' as math;
import 'package:tam_customer/shared/domain/geo_point.dart';

/// A device observation, never a map centre or a persisted previous session.
final class LocationFix {
  const LocationFix({
    required this.point,
    required this.capturedAt,
    required this.accuracyMeters,
  });
  final GeoPoint point;
  final DateTime capturedAt;
  final double accuracyMeters;
}

final class LocationPolicy {
  const LocationPolicy({
    this.maximumAge = const Duration(seconds: 20),
    this.maximumAccuracyMeters = 50,
    this.verificationAge = const Duration(seconds: 5),
    this.pickupMovementMeters = 50,
    this.updateDistanceMeters = 20,
    this.updateInterval = const Duration(seconds: 10),
    this.fixTimeout = const Duration(seconds: 15),
  });
  final Duration maximumAge, verificationAge, updateInterval, fixTimeout;
  final double maximumAccuracyMeters, pickupMovementMeters;
  final int updateDistanceMeters;

  bool accepts(LocationFix fix, DateTime now, {bool verification = false}) {
    final age = now.difference(fix.capturedAt);
    return fix.accuracyMeters.isFinite &&
        fix.accuracyMeters >= 0 &&
        fix.accuracyMeters <= maximumAccuracyMeters &&
        age >= Duration.zero &&
        age <= (verification ? verificationAge : maximumAge);
  }
}

double locationDistanceMeters(GeoPoint a, GeoPoint b) {
  final lat1 = a.latitude * math.pi / 180;
  final lat2 = b.latitude * math.pi / 180;
  final dLat = lat2 - lat1;
  final dLon = (b.longitude - a.longitude) * math.pi / 180;
  final h =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dLon / 2), 2);
  return 6371000 * 2 * math.asin(math.sqrt(h.clamp(0, 1)));
}

abstract interface class LocationSensor {
  Future<void> checkAccess({required bool requestPermission});
  Future<LocationFix> read();
  Stream<LocationFix> watch();
  Stream<bool> watchService();
}
