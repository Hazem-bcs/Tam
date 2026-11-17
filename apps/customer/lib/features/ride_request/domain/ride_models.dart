import 'package:equatable/equatable.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// Stable identifiers used by the future API and the mock quote provider.
enum RideVehicleClass { standard, comfort, van, motorbike }

final class RidePlace extends Equatable {
  const RidePlace({
    required this.id,
    required this.location,
    required this.englishLabel,
  });

  final String id;
  final TripLocation location;
  final String englishLabel;

  @override
  List<Object?> get props => [id, location, englishLabel];
}

final class RideQuote extends Equatable {
  const RideQuote({
    required this.id,
    required this.pickup,
    required this.destination,
    required this.vehicleClass,
    required this.fare,
    required this.distanceMeters,
    required this.durationMinutes,
    required this.expiresAt,
    this.scheduledAt,
    this.paymentMethod = TripPaymentMethod.cash,
    this.couponCode,
    this.discount,
  });

  final String id;
  final TripLocation pickup;
  final TripLocation destination;
  final RideVehicleClass vehicleClass;
  final Money fare;
  final int distanceMeters;
  final int durationMinutes;
  final DateTime expiresAt;
  final DateTime? scheduledAt;
  final TripPaymentMethod paymentMethod;
  final String? couponCode;
  final Money? discount;

  bool isValidAt(DateTime now) => now.toUtc().isBefore(expiresAt.toUtc());

  @override
  List<Object?> get props => [
    id,
    pickup,
    destination,
    vehicleClass,
    fare,
    distanceMeters,
    durationMinutes,
    expiresAt,
    scheduledAt,
    paymentMethod,
    couponCode,
    discount,
  ];
}

final class RideRequestFailure implements Exception {
  const RideRequestFailure(this.code);

  final String code;

  @override
  String toString() => 'RideRequestFailure($code)';
}
