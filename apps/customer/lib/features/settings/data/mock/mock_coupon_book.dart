import 'package:flutter/foundation.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_pricing.dart';

/// Preview-only coupon data; no API, persistence or payment is involved.
@immutable
class DemoCoupon {
  const DemoCoupon({
    required this.code,
    required this.percent,
    required this.isAvailable,
    this.expiresAt,
    this.remainingTrips,
    this.totalTrips,
  });

  final String code;
  final int percent;
  final bool isAvailable;
  final DateTime? expiresAt;
  final int? remainingTrips;
  final int? totalTrips;
}

enum AddDemoCouponResult { added, duplicate, invalid }

/// A session-scoped mock book. Only TAM10 is accepted because it is the
/// sole code supported by the existing mock ride-pricing contract.
class MockCouponBook extends ChangeNotifier {
  final List<DemoCoupon> _coupons = [
    DemoCoupon(
      code: 'NOW25',
      percent: 25,
      isAvailable: false,
      expiresAt: DateTime(2026, 9, 30),
      remainingTrips: 0,
      totalTrips: 2,
    ),
    DemoCoupon(
      code: 'SAVE15',
      percent: 15,
      isAvailable: false,
      expiresAt: DateTime(2026, 10, 4),
      remainingTrips: 0,
      totalTrips: 3,
    ),
  ];

  List<DemoCoupon> get coupons => List.unmodifiable(_coupons);

  AddDemoCouponResult add(String rawCode) {
    final code = rawCode.trim().toUpperCase();
    if (code != MockRidePricing.couponCode) {
      return AddDemoCouponResult.invalid;
    }
    if (_coupons.any((offer) => offer.code == code)) {
      return AddDemoCouponResult.duplicate;
    }
    _coupons.insert(
      0,
      const DemoCoupon(
        code: MockRidePricing.couponCode,
        percent: 10,
        isAvailable: true,
      ),
    );
    notifyListeners();
    return AddDemoCouponResult.added;
  }
}
