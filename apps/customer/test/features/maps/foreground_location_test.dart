import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/maps/domain/foreground_location.dart';
import 'package:tam_customer/features/maps/domain/location_fix.dart';
import 'package:tam_customer/features/maps/domain/maps_repository.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'maps_test_support.dart';

class _Sensor implements LocationSensor {
  final positions = StreamController<LocationFix>.broadcast(sync: true);
  final service = StreamController<bool>.broadcast(sync: true);
  int checks = 0, reads = 0;
  final permissionRequests = <bool>[];
  String? failure;
  late Future<LocationFix> Function() sample;
  @override
  Future<void> checkAccess({required bool requestPermission}) async {
    checks++;
    permissionRequests.add(requestPermission);
    if (failure != null) throw MapsFailure(failure!);
  }

  @override
  Future<LocationFix> read() {
    reads++;
    return sample();
  }

  @override
  Stream<LocationFix> watch() => positions.stream;
  @override
  Stream<bool> watchService() => service.stream;
  Future<void> close() async {
    await positions.close();
    await service.close();
  }
}

void main() {
  late _Sensor sensor;
  late ForegroundLocation location;
  late DateTime now;
  late Duration elapsed;
  LocationFix fix({
    GeoPoint? point,
    double accuracy = 10,
    Duration age = Duration.zero,
  }) => LocationFix(
    point: point ?? origin,
    capturedAt: now.subtract(age),
    accuracyMeters: accuracy,
  );
  Future<void> flush() => Future<void>.delayed(Duration.zero);
  void advance(Duration amount) {
    now = now.add(amount);
    elapsed += amount;
  }

  setUp(() {
    now = DateTime.utc(2026, 11, 15, 12);
    elapsed = Duration.zero;
    sensor = _Sensor()..sample = () async => fix();
    location = ForegroundLocation(
      sensor: sensor,
      policy: const LocationPolicy(),
      now: () => now,
      elapsed: () => elapsed,
    );
  });
  tearDown(() async {
    await location.dispose();
    await sensor.close();
  });

  test(
    'session entry warms once; cached consumers still recheck access',
    () async {
      location.setSession(true);
      location.setSession(true);
      await flush();
      expect(sensor.reads, 1);
      expect(sensor.positions.hasListener, isTrue);
      expect(await location.locate(), origin);
      expect(sensor.reads, 1);
      expect(sensor.checks, 2);
    },
  );
  test(
    'simultaneous consumers share one read and permission request',
    () async {
      final pending = Completer<LocationFix>();
      sensor.sample = () => pending.future;
      location.setSession(true);
      final a = location.locate(), b = location.locate();
      await flush();
      expect(sensor.reads, 1);
      expect(sensor.checks, 1);
      pending.complete(fix());
      expect(await a, origin);
      expect(await b, origin);
    },
  );
  test('movement on another screen updates the cache', () async {
    location.setSession(true);
    await flush();
    advance(const Duration(seconds: 5));
    sensor.positions.add(fix(point: destination));
    expect(await location.locate(), destination);
    expect(sensor.reads, 1);
  });
  test('out-of-order samples cannot move cache back', () async {
    location.setSession(true);
    await flush();
    advance(const Duration(seconds: 5));
    sensor.positions.add(fix(point: destination));
    sensor.positions.add(fix(age: const Duration(seconds: 2)));
    expect(await location.locate(), destination);
  });
  test(
    'a newer imprecise sample invalidates the previous precise cache',
    () async {
      location.setSession(true);
      await flush();
      advance(const Duration(seconds: 5));
      sensor.positions.add(fix(point: destination, accuracy: 500));
      sensor.sample = () async => fix(accuracy: 500);
      await expectLater(location.locate(), throwsA(isA<MapsFailure>()));
      advance(const Duration(seconds: 1));
      sensor.sample = () async => fix(point: destination);
      expect(await location.locate(), destination);
    },
  );
  test('a stream error clears cache and permits a new acquisition', () async {
    location.setSession(true);
    await flush();
    sensor.positions.addError(const MapsFailure('LOCATION_UNAVAILABLE'));
    await flush();
    advance(const Duration(seconds: 1));
    sensor.sample = () async => fix(point: destination);
    expect(await location.locate(), destination);
    expect(sensor.reads, 2);
  });
  test('booking verification bypasses even a fresh shared cache', () async {
    location.setSession(true);
    await flush();
    advance(const Duration(seconds: 1));
    sensor.sample = () async => fix(point: destination);
    expect(await location.locate(requireFresh: true), destination);
    expect(sensor.reads, 2);
  });
  test('booking rejects a device response older than five seconds', () async {
    location.setSession(true);
    await flush();
    advance(const Duration(seconds: 10));
    sensor.sample = () async => fix(age: const Duration(seconds: 8));
    await expectLater(
      location.locate(requireFresh: true),
      throwsA(isA<MapsFailure>()),
    );
  });
  test('expired cache forces a fresh read', () async {
    location.setSession(true);
    await flush();
    advance(const Duration(seconds: 21));
    sensor.sample = () async => fix(point: destination);
    expect(await location.locate(), destination);
    expect(sensor.reads, 2);
  });
  for (final kind in ['old', 'inaccurate', 'future', 'nan']) {
    test('$kind reading never becomes an automatic pickup', () async {
      sensor.sample = () async => fix(
        accuracy: kind == 'inaccurate'
            ? 300
            : kind == 'nan'
            ? double.nan
            : 10,
        age: kind == 'old'
            ? const Duration(minutes: 5)
            : kind == 'future'
            ? const Duration(seconds: -5)
            : Duration.zero,
      );
      location.setSession(true);
      await flush();
      await expectLater(location.locate(), throwsA(isA<MapsFailure>()));
    });
  }
  test(
    'monotonic age prevents reuse despite a wall-clock adjustment',
    () async {
      location.setSession(true);
      await flush();
      elapsed += const Duration(minutes: 1);
      sensor.sample = () async => fix(point: destination);
      expect(await location.locate(), destination);
      expect(sensor.reads, 2);
    },
  );
  test('permission revocation cannot return cached success', () async {
    location.setSession(true);
    await flush();
    sensor.failure = 'LOCATION_DENIED_FOREVER';
    await expectLater(
      location.locate(),
      throwsA(isA<MapsFailure>().having((e) => e.code, 'code', sensor.failure)),
    );
    await flush();
    expect(sensor.positions.hasListener, isFalse);
  });
  test(
    'pause stops sensors; resume revalidates without permission prompt',
    () async {
      location.setSession(true);
      await flush();
      location.setForeground(false);
      await flush();
      expect(sensor.positions.hasListener, isFalse);
      expect(sensor.service.hasListener, isFalse);
      await expectLater(location.locate(), throwsA(isA<MapsFailure>()));
      advance(const Duration(minutes: 5));
      sensor.sample = () async => fix(point: destination);
      location.setForeground(true);
      await flush();
      expect(sensor.permissionRequests.last, isFalse);
      expect(await location.locate(), destination);
      expect(sensor.reads, 2);
    },
  );
  test('service off invalidates; service on resumes acquisition', () async {
    location.setSession(true);
    await flush();
    sensor.failure = 'LOCATION_DISABLED';
    sensor.service.add(false);
    await flush();
    expect(sensor.positions.hasListener, isFalse);
    expect(sensor.service.hasListener, isTrue);
    await expectLater(location.locate(), throwsA(isA<MapsFailure>()));
    sensor.failure = null;
    advance(const Duration(seconds: 5));
    sensor.sample = () async => fix(point: destination);
    sensor.service.add(true);
    await flush();
    expect(await location.locate(), destination);
  });
  test('logout rejects late read and clears the next session', () async {
    final pending = Completer<LocationFix>();
    sensor.sample = () => pending.future;
    location.setSession(true);
    final rejected = expectLater(
      location.locate(),
      throwsA(isA<MapsFailure>()),
    );
    await flush();
    location.setSession(false);
    advance(const Duration(seconds: 5));
    sensor.sample = () async => fix(point: destination);
    location.setSession(true);
    await flush();
    pending.complete(fix());
    await rejected;
    expect(await location.locate(), destination);
  });
  test('paused read cannot resurrect an old location after resume', () async {
    final pending = Completer<LocationFix>();
    sensor.sample = () => pending.future;
    location.setSession(true);
    final rejected = expectLater(
      location.locate(),
      throwsA(isA<MapsFailure>()),
    );
    await flush();
    location.setForeground(false);
    advance(const Duration(seconds: 5));
    sensor.sample = () async => fix(point: destination);
    location.setForeground(true);
    await flush();
    pending.complete(fix());
    await rejected;
    expect(await location.locate(), destination);
  });
  test('disposing stops streams and rejects subsequent reads', () async {
    location.setSession(true);
    await flush();
    await location.dispose();
    expect(sensor.positions.hasListener, isFalse);
    expect(sensor.service.hasListener, isFalse);
    await expectLater(location.locate(), throwsA(isA<MapsFailure>()));
  });
}
