import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/ride_request/domain/ride_coupon_offer.dart';

void main() {
  test('availability excludes disabled, expired and exhausted coupons', () {
    final now = DateTime.utc(2026, 11, 18);
    const active = RideCouponOffer(code: 'TAM10', percent: 10, enabled: true);
    expect(active.availableAt(now), isTrue);
    expect(
      RideCouponOffer(
        code: 'OLD',
        percent: 25,
        enabled: true,
        expiresAt: now,
      ).availableAt(now),
      isFalse,
    );
    expect(
      const RideCouponOffer(
        code: 'USED',
        percent: 10,
        enabled: true,
        remainingTrips: 0,
      ).availableAt(now),
      isFalse,
    );
    expect(
      const RideCouponOffer(
        code: 'DISABLED',
        percent: 10,
        enabled: false,
      ).availableAt(now),
      isFalse,
    );
  });
}
