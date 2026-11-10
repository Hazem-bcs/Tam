import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/maps/data/maps_codec.dart';
import 'maps_test_support.dart';

void main() {
  test(
    'Postman GeoJSON success matches the versioned fixture and client codec',
    () {
      final root = Directory('../../docs/api/maps');
      final fixture = jsonDecode(
        File('${root.path}/examples/route_success.json').readAsStringSync(),
      );
      final collection =
          jsonDecode(
                File(
                  '${root.path}/maps-v1.postman_collection.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      final request =
          (collection['item'] as List).firstWhere(
                (v) => (v['request'] as Map)['method'] == 'POST',
              )
              as Map;
      final success = (request['response'] as List).firstWhere(
        (v) => v['code'] == 200,
      );
      expect(jsonDecode(success['body'] as String), fixture);
      final route = MapsCodec.route(fixture, origin, destination);
      expect(route.points.length, 3);
      expect(route.points.first, origin);
      expect(route.points.last, destination);
    },
  );
}
