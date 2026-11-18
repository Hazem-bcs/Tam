import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/maps/domain/maps_repository.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_location_cubit.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import '../../../maps/maps_test_support.dart';

class _Settings implements DeviceLocationSettings {
  int app = 0, location = 0;
  bool opened = true;
  @override
  Future<bool> openAppSettings() async {
    app++;
    return opened;
  }

  @override
  Future<bool> openLocationSettings() async {
    location++;
    return opened;
  }
}

void main() {
  late LocationProbe gps;
  late MapsProbe maps;
  late _Settings settings;
  late RideLocationCubit cubit;
  setUp(() {
    gps = LocationProbe();
    maps = MapsProbe();
    settings = _Settings();
    cubit = RideLocationCubit(
      repository: maps,
      device: gps,
      settings: settings,
      language: 'ar',
    );
  });
  tearDown(() async {
    if (!cubit.isClosed) await cubit.close();
  });

  test(
    'foreground fix does not wait for address lookup or invent a route',
    () async {
      await cubit.locate();
      expect(cubit.state.fix, origin);
      expect(cubit.state.fixRevision, 1);
      expect(cubit.state.locating, false);
      expect(maps.routes, 0);
      expect(maps.searches, 0);
    },
  );
  test(
    'explicit location focuses the same fix repeatedly but validation never focuses',
    () async {
      await cubit.locate(requireFresh: true, focusMap: true);
      expect(gps.lastRequireFresh, isTrue);
      expect(cubit.state.focusPoint, origin);
      expect(cubit.state.focusRevision, 1);
      await cubit.locate(requireFresh: true, focusMap: true);
      expect(cubit.state.focusRevision, 2);
      gps.onLocate = () async => destination;
      await cubit.validatePickup(origin);
      expect(cubit.state.fix, destination);
      expect(cubit.state.focusPoint, origin);
      expect(cubit.state.focusRevision, 2);
    },
  );
  test('a newer tapped point wins a pending explicit location focus', () async {
    final pending = Completer<GeoPoint>();
    gps.onLocate = () => pending.future;
    final locating = cubit.locate(focusMap: true);
    await cubit.selectPoint(destination);
    pending.complete(origin);
    await locating;
    expect(cubit.state.point, destination);
    expect(cubit.state.focusRevision, 0);
  });
  test(
    'successful explicit location clears only the unconfirmed point',
    () async {
      await cubit.selectPoint(destination);
      await cubit.locate(focusMap: true);
      expect(cubit.state.point, isNull);
      expect(cubit.state.focusPoint, origin);
    },
  );
  test('repeated location action only has one in-flight request', () async {
    final pending = Completer<GeoPoint>();
    gps.onLocate = () => pending.future;
    final task = cubit.locate();
    await cubit.locate();
    expect(gps.calls, 1);
    pending.complete(origin);
    await task;
  });
  test('a manual pickup wins against a late GPS response', () async {
    final pending = Completer<GeoPoint>();
    gps.onLocate = () => pending.future;
    final task = cubit.locate();
    cubit.keepManualPickup();
    pending.complete(origin);
    await task;
    expect(cubit.state.fix, isNull);
    expect(cubit.state.fixRevision, 0);
    expect(cubit.state.locating, false);
  });
  for (final code in [
    'LOCATION_DISABLED',
    'LOCATION_DENIED',
    'LOCATION_DENIED_FOREVER',
  ]) {
    test('$code stays explicit without a fabricated pickup', () async {
      gps.onLocate = () async => throw MapsFailure(code);
      await cubit.locate();
      expect(cubit.state.failure, code);
      expect(cubit.state.fix, isNull);
      expect(cubit.state.locating, false);
    });
  }
  test(
    'unconfigured reverse lookup preserves the exact tapped coordinates',
    () async {
      maps.onReverse = (_) async =>
          throw const MapsFailure('MAP_NOT_CONFIGURED');
      await cubit.selectPoint(destination);
      expect(cubit.state.point, destination);
      expect(cubit.state.address, isNull);
      expect(cubit.state.resolving, false);
    },
  );
  test('a stale address response cannot change the newer point', () async {
    final a = Completer<TripLocation>(), b = Completer<TripLocation>();
    maps.onReverse = (p) => p == origin ? a.future : b.future;
    final first = cubit.selectPoint(origin),
        second = cubit.selectPoint(destination);
    b.complete(TripLocation(point: destination, label: 'Second'));
    await second;
    a.complete(TripLocation(point: origin, label: 'First'));
    await first;
    expect(cubit.state.point, destination);
    expect(cubit.state.address, 'Second');
  });
  test('dismissed point is not resurrected by address lookup', () async {
    final pending = Completer<TripLocation>();
    maps.onReverse = (_) => pending.future;
    final task = cubit.selectPoint(origin);
    cubit.clearPoint();
    pending.complete(TripLocation(point: origin, label: 'Late'));
    await task;
    expect(cubit.state.point, isNull);
    expect(cubit.state.address, isNull);
  });
  test(
    'settings return retries once, while ordinary resumes never request GPS',
    () async {
      gps.onLocate = () async => throw const MapsFailure('LOCATION_DISABLED');
      await cubit.locate();
      await cubit.openSettings();
      expect(settings.location, 1);
      expect(settings.app, 0);
      gps.onLocate = () async => destination;
      cubit.resumed();
      await Future<void>.delayed(Duration.zero);
      cubit.resumed();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.fix, destination);
      expect(gps.calls, 2);
    },
  );
  test(
    'permanently denied permission opens app settings; failure is recoverable',
    () async {
      gps.onLocate = () async =>
          throw const MapsFailure('LOCATION_DENIED_FOREVER');
      await cubit.locate();
      settings.opened = false;
      await cubit.openSettings();
      expect(settings.app, 1);
      expect(settings.location, 0);
      expect(cubit.state.failure, 'LOCATION_UNAVAILABLE');
    },
  );
  test(
    'booking validation detects meaningful movement without quoting',
    () async {
      await cubit.locate();
      gps.onLocate = () async => destination;
      expect(await cubit.validatePickup(origin), PickupValidation.moved);
      expect(gps.lastRequireFresh, isTrue);
      expect(cubit.state.fix, destination);
      expect(maps.routes, 0);
    },
  );
  test('small GPS jitter preserves reviewed pickup', () async {
    gps.onLocate = () async => GeoPoint(latitude: 33.50001, longitude: 36.25);
    expect(await cubit.validatePickup(origin), PickupValidation.unchanged);
  });
  test('unavailable validation never authorizes confirmation', () async {
    await cubit.locate();
    gps.onLocate = () async => throw const MapsFailure('LOCATION_INACCURATE');
    expect(await cubit.validatePickup(origin), PickupValidation.unavailable);
    expect(cubit.state.failure, 'LOCATION_INACCURATE');
  });
  test('manual edit during validation wins the late result', () async {
    final pending = Completer<GeoPoint>();
    gps.onLocate = () => pending.future;
    final checking = cubit.validatePickup(origin);
    cubit.keepManualPickup();
    pending.complete(destination);
    expect(await checking, PickupValidation.unavailable);
  });
  test('route disposal rejects late GPS and address work', () async {
    final fix = Completer<GeoPoint>(), address = Completer<TripLocation>();
    gps.onLocate = () => fix.future;
    maps.onReverse = (_) => address.future;
    final a = cubit.locate(), b = cubit.selectPoint(origin);
    await cubit.close();
    fix.complete(origin);
    address.complete(TripLocation(point: origin, label: 'Closed'));
    await Future.wait([a, b]);
    expect(cubit.state.fix, isNull);
    expect(cubit.state.address, isNull);
  });
  test('approximate permission opens app permission settings', () async {
    gps.onLocate = () async =>
        throw const MapsFailure('LOCATION_PRECISE_REQUIRED');
    await cubit.locate();
    await cubit.openSettings();
    expect(settings.app, 1);
    expect(settings.location, 0);
  });
}
