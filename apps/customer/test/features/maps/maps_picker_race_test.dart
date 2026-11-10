import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/maps/presentation/bloc/map_picker_cubit.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'maps_test_support.dart';

void main() {
  test(
    'description typed while GPS is pending survives reverse lookup',
    () async {
      final gps = Completer<GeoPoint>();
      final device = LocationProbe()..onLocate = () => gps.future;
      final cubit = MapPickerCubit(MapsProbe(), device, language: 'ar');
      addTearDown(cubit.close);
      final locating = cubit.locate();
      cubit.labelChanged('المدخل الذي حددته');
      gps.complete(origin);
      await locating;
      expect(cubit.state.label, 'المدخل الذي حددته');
      expect(cubit.state.point, origin);
      expect(cubit.state.canConfirm, isTrue);
    },
  );
  test(
    'GPS requested after a search choice replaces the earlier choice',
    () async {
      final gps = Completer<GeoPoint>();
      final device = LocationProbe()..onLocate = () => gps.future;
      final cubit = MapPickerCubit(MapsProbe(), device, language: 'en');
      addTearDown(cubit.close);
      cubit.choose(TripLocation(label: 'Earlier choice', point: destination));
      final locating = cubit.locate();
      gps.complete(origin);
      await locating;
      expect(cubit.state.point, origin);
      expect(cubit.state.label, 'المكان');
      expect(cubit.state.busy, isFalse);
    },
  );
  test('new pin beats pending GPS and its late failure', () async {
    final gps = Completer<GeoPoint>();
    final device = LocationProbe()..onLocate = () => gps.future;
    final cubit = MapPickerCubit(MapsProbe(), device, language: 'en');
    addTearDown(cubit.close);
    final locating = cubit.locate();
    await cubit.select(destination);
    cubit.labelChanged('My newer pin');
    gps.completeError(StateError('GPS failed late'));
    await locating;
    expect(cubit.state.point, destination);
    expect(cubit.state.label, 'My newer pin');
    expect(cubit.state.failure, isNull);
  });
  test('pin choice invalidates a pending search result', () async {
    final reply = Completer<List<TripLocation>>();
    final repository = MapsProbe()..onSearch = (_) => reply.future;
    final cubit = MapPickerCubit(repository, LocationProbe(), language: 'en');
    addTearDown(cubit.close);
    cubit.search('earlier query');
    await Future<void>.delayed(const Duration(milliseconds: 350));
    expect(repository.searches, 1);
    await cubit.select(origin);
    reply.complete([
      TripLocation(label: 'Previous query result', point: destination),
    ]);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.results, isEmpty);
    expect(cubit.state.searching, isFalse);
    expect(cubit.state.point, origin);
  });
}
