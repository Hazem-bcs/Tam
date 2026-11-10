import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/maps/domain/maps_repository.dart';
import 'package:tam_customer/features/maps/presentation/bloc/map_picker_cubit.dart';
import 'package:tam_customer/features/maps/presentation/bloc/map_route_cubit.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'maps_test_support.dart';

void main() {
  test('clearing endpoints invalidates an old route', () async {
    final r = MapsProbe(), reply = Completer<MapRoute>();
    r.onRoute = (a, b) => reply.future;
    final c = MapRouteCubit(r);
    addTearDown(c.close);
    final old = c.load(origin, destination);
    await c.load(null, null);
    reply.complete(routeValue(origin, destination));
    await old;
    expect(c.state.route, isNull);
    expect(c.state.busy, isFalse);
  });
  test('closed route ignores reply; failure never invents geometry', () async {
    final r = MapsProbe(), reply = Completer<MapRoute>();
    r.onRoute = (a, b) => reply.future;
    final c = MapRouteCubit(r), old = c.load(origin, destination);
    await c.close();
    reply.complete(routeValue(origin, destination));
    await old;
    final f = MapRouteCubit(
      MapsProbe()
        ..onRoute = (a, b) async =>
            throw const MapsFailure('SERVICE_UNAVAILABLE'),
    );
    addTearDown(f.close);
    await f.load(origin, destination);
    expect(f.state.route, isNull);
    expect(f.state.failure, 'SERVICE_UNAVAILABLE');
  });
  test('typed label wins over slow reverse for the same point', () async {
    final r = MapsProbe(), reply = Completer<TripLocation>();
    r.onReverse = (_) => reply.future;
    final device = LocationProbe(),
        c = MapPickerCubit(r, device, language: 'ar');
    addTearDown(c.close);
    expect(device.calls, 0);
    final old = c.select(origin);
    c.labelChanged('مدخل المبنى');
    reply.complete(TripLocation(label: 'آلي', point: origin));
    await old;
    expect(c.state.label, 'مدخل المبنى');
    expect(c.state.canConfirm, isTrue);
  });
  test('a manual choice wins over pending GPS', () async {
    final gps = Completer<GeoPoint>(),
        device = LocationProbe()..onLocate = () => gps.future;
    final c = MapPickerCubit(MapsProbe(), device, language: 'ar');
    addTearDown(c.close);
    final old = c.locate();
    c.choose(TripLocation(label: 'اختياري', point: destination));
    gps.complete(origin);
    await old;
    expect(c.state.point, destination);
    expect(c.state.label, 'اختياري');
  });
  test('failed reverse keeps pin but requires a valid manual label', () async {
    final r = MapsProbe()
      ..onReverse = (_) async => throw const MapsFailure('MAP_NOT_CONFIGURED');
    final c = MapPickerCubit(r, LocationProbe(), language: 'ar');
    addTearDown(c.close);
    await c.select(origin);
    expect(c.state.canConfirm, isFalse);
    expect(c.state.failure, 'MAP_NOT_CONFIGURED');
    c.labelChanged('عنواني');
    expect(c.state.canConfirm, isTrue);
    expect(c.state.point, origin);
    c.labelChanged('x' * 201);
    expect(c.state.canConfirm, isFalse);
  });
  test(
    'debounced search ignores old result after selection and close',
    () async {
      final r = MapsProbe(), reply = Completer<List<TripLocation>>();
      r.onSearch = (_) => reply.future;
      final c = MapPickerCubit(r, LocationProbe(), language: 'en');
      c.search('a');
      c.search('ab');
      await Future<void>.delayed(const Duration(milliseconds: 350));
      expect(r.searches, 1);
      c.choose(TripLocation(label: 'Selected', point: origin));
      await c.close();
      reply.complete([TripLocation(label: 'Old', point: destination)]);
      await Future<void>.delayed(Duration.zero);
      expect(c.state.point, origin);
      expect(c.state.results, isEmpty);
    },
  );
}
