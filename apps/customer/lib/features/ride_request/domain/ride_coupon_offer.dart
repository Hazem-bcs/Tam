/// A selectable offer; server/pricing still validates its applicability.
final class RideCouponOffer {
  const RideCouponOffer({
    required this.code,
    required this.percent,
    required this.enabled,
    this.expiresAt,
    this.remainingTrips,
  });
  final String code;
  final int percent;
  final bool enabled;
  final DateTime? expiresAt;
  final int? remainingTrips;
  bool availableAt(DateTime now) =>
      enabled &&
      (expiresAt == null || now.isBefore(expiresAt!)) &&
      (remainingTrips == null || remainingTrips! > 0);
}
