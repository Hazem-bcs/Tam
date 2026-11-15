import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/di/service_locator.dart';
import 'package:tam_customer/core/config/map_configuration.dart';
import 'package:tam_customer/features/maps/domain/foreground_location.dart';
import 'package:tam_customer/features/maps/domain/location_fix.dart';
import 'package:tam_customer/features/maps/maps_dependencies.dart';
import '../features/maps/maps_test_support.dart';
import 'support/customer_app_harness.dart';

class _Sensor implements LocationSensor {
  int reads = 0;
  final requests = <bool>[];
  final positions = StreamController<LocationFix>.broadcast();
  final service = StreamController<bool>.broadcast();
  @override
  Future<void> checkAccess({required bool requestPermission}) async =>
      requests.add(requestPermission);
  @override
  Future<LocationFix> read() async {
    reads++;
    return LocationFix(
      point: origin,
      capturedAt: DateTime.now(),
      accuracyMeters: 8,
    );
  }

  @override
  Stream<LocationFix> watch() => positions.stream;
  @override
  Stream<bool> watchService() => service.stream;
}

void main() {
  for (final guest in [true, false]) {
    testWidgets(
      'location follows ${guest ? 'guest' : 'local'} entry, foreground and logout',
      (tester) async {
        final sensor = _Sensor();
        final location = ForegroundLocation(
          sensor: sensor,
          policy: const LocationPolicy(),
        );
        locator.registerFactory<MapsDependencies>(
          () => MapsDependencies(
            configuration: const MapConfiguration(),
            repository: MapsProbe(),
            deviceLocation: location,
            currentLocation: location,
          ),
        );
        addTearDown(() {
          locator.unregister<MapsDependencies>();
          unawaited(location.dispose());
          unawaited(sensor.positions.close());
          unawaited(sensor.service.close());
        });
        await launchCustomerApp(tester);
        expect(sensor.reads, 0);
        await enterCustomerSession(tester, phone: guest ? null : '0941234567');
        expect(sensor.reads, 1);
        expect(sensor.positions.hasListener, isTrue);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pump();
        expect(sensor.positions.hasListener, isFalse);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() => Future<void>.delayed(Duration.zero));
        await tester.pump();
        expect(sensor.reads, 2);
        expect(sensor.requests.last, isFalse);
        await tester.runAsync(customerAuth(tester).logout);
        await tester.pumpAndSettle();
        expect(sensor.positions.hasListener, isFalse);
        expect(sensor.service.hasListener, isFalse);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pump();
      },
    );
  }
}
