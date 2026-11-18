/// Deterministic coupon fixture. This never charges or credits a wallet.
abstract final class MockRidePricing {
  static const couponCode = 'TAM10';
  static const arabicCouponCode = 'تم10';
  static const couponCodes = {couponCode, arabicCouponCode};
  static int discountFor(int fare) => (fare * 10) ~/ 100;
}
