import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/addresses/presentation/bloc/address_map_selection_cubit.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';

import '../maps/maps_test_support.dart';

void main() {
  final first = GeoPoint(latitude: 33.5138, longitude: 36.2765);
  final second = GeoPoint(latitude: 33.5141, longitude: 36.277);

  test('tapping the map selects real coordinates without geocoding', () async {
    final repo = MapsProbe();
    final cubit = AddressMapSelectionCubit(
      repository: repo,
      deviceLocation: LocationProbe(),
      language: 'ar',
      reverseAvailable: false,
    );

    expect(cubit.state.location, isNull);
    cubit.select(first);
    expect(cubit.state.location!.point, first);
    expect(
      cubit.state.location!.label,
      '33.51380, 36.27650',
    );
    cubit.select(second);
    expect(cubit.state.location!.point, second);
    await cubit.close();
  });

  test('a late reverse-geocoding result cannot replace a newer tap', () async {
    final previous = Completer<TripLocation>();
    final repo = MapsProbe()
      ..onReverse = (point) => point == first
          ? previous.future
          : Future.value(TripLocation(label: 'new', point: point));
    final cubit = AddressMapSelectionCubit(
      repository: repo,
      deviceLocation: LocationProbe(),
      language: 'ar',
      reverseAvailable: true,
    );
    cubit.select(first);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    cubit.select(second);
    previous.complete(TripLocation(label: 'old', point: first));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.location!.point, second);
    expect(cubit.state.location!.label, isNot('old'));
    await cubit.close();
  });

  test('device location becomes the selected map coordinate', () async {
    final device = LocationProbe()..onLocate = () async => second;
    final cubit = AddressMapSelectionCubit(
      repository: MapsProbe(),
      deviceLocation: device,
      language: 'ar',
      reverseAvailable: false,
    );
    await cubit.locate();
    expect(device.calls, 1);
    expect(cubit.state.location!.point, second);
    expect(cubit.state.locating, false);
    await cubit.close();
  });

  test('a failing device location never invents or clears a point', () async {
    final device = LocationProbe()
      ..onLocate = () async => throw StateError('permission denied');
    final initial = TripLocation(label: 'existing', point: first);
    final cubit = AddressMapSelectionCubit(
      repository: MapsProbe(),
      deviceLocation: device,
      language: 'ar',
      reverseAvailable: false,
      initialLocation: initial,
    );
    await cubit.locate();
    expect(cubit.state.location, initial);
    expect(cubit.state.locationFailed, true);
    await cubit.close();
  });
}
