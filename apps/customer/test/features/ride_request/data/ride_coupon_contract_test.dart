import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/settings/data/mock/mock_coupon_book.dart';

void main() {
  test(
    'proposed activation fixture matches supported mock coupon and saved responses',
    () {
      const root = '../../docs/api/ride_coupons';
      final fixture =
          jsonDecode(
                File('$root/examples/activate_success.json').readAsStringSync(),
              )
              as Map;
      final book = MockCouponBook();
      expect(
        book.add(fixture['data']['code'] as String),
        AddDemoCouponResult.added,
      );
      final coupon = book.coupons.first;
      expect(coupon.percent, fixture['data']['percent']);
      expect(coupon.isAvailable, fixture['data']['is_available']);
      expect(coupon.expiresAt, fixture['data']['expires_at']);
      expect(coupon.remainingTrips, fixture['data']['remaining_trips']);
      final collection =
          jsonDecode(
                File(
                  '$root/ride_coupons-v1.postman_collection.json',
                ).readAsStringSync(),
              )
              as Map;
      for (final item in collection['item'] as List) {
        for (final response in item['response'] as List) {
          final name = response['name'];
          expect(
            jsonDecode(response['body'] as String),
            jsonDecode(File('$root/examples/$name.json').readAsStringSync()),
          );
        }
      }
      book.dispose();
    },
  );
}
