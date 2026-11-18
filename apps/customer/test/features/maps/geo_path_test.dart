import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/shared/domain/geo_path.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';

void main() {
  test('distance-based travel follows corners and geographic heading', () {
    final a = GeoPoint(latitude: 0, longitude: 0);
    final b = GeoPoint(latitude: .001, longitude: 0);
    final c = GeoPoint(latitude: .001, longitude: .001);
    final path = GeoPath([a, b, c]);
    expect(path.length, closeTo(222.39, .1));
    expect(path.at(path.length / 2).latitude, closeTo(.001, .000001));
    expect(path.at(path.length / 2).longitude, closeTo(0, .000001));
    expect(path.headingAt(30), closeTo(0, .1));
    expect(path.headingAt(180), closeTo(90, .1));
    final projected = path.project(
      GeoPoint(latitude: .00105, longitude: .0005),
    );
    expect(projected.error, closeTo(5.56, .1));
    expect(projected.distance, closeTo(166.79, .1));
    expect(GeoPath.turn(350, 10, .5), closeTo(0, .01));
  });
  test('antimeridian travel uses the short longitude direction', () {
    final path = GeoPath([
      GeoPoint(latitude: 0, longitude: 179.9),
      GeoPoint(latitude: 0, longitude: -179.9),
    ]);
    expect(path.length, lessThan(23000));
    expect(path.at(path.length / 2).longitude.abs(), closeTo(180, .001));
  });
}
