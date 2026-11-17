import 'package:equatable/equatable.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';

final class Money extends Equatable {
  Money({
    required this.amountMinor,
    this.currency = 'SYP',
    this.minorUnit = 0,
  }) {
    if (amountMinor < 0 ||
        minorUnit < 0 ||
        minorUnit > 3 ||
        !RegExp(r'^[A-Z]{3}$').hasMatch(currency)) {
      throw ArgumentError('Invalid money value');
    }
  }
  final int amountMinor;
  final String currency;
  final int minorUnit;
  @override
  List<Object?> get props => [amountMinor, currency, minorUnit];
}

final class TripLocation extends Equatable {
  const TripLocation({required this.label, required this.point});
  final String label;
  final GeoPoint point;
  @override
  List<Object?> get props => [label, point];
}

/// Rebooking carries locations only, never an old fare or confirmation.
final class TripPrefill extends Equatable {
  const TripPrefill({required this.pickup, required this.destination});
  final TripLocation pickup;
  final TripLocation destination;
  @override
  List<Object?> get props => [pickup, destination];
}

enum TripStatus {
  scheduled,
  requested,
  confirmed,
  driverEnRoute,
  driverArrived,
  inProgress,
  completed,
  cancelled,
  noDriver,
}

extension TripStatusRules on TripStatus {
  bool get isActive => !{
    TripStatus.completed,
    TripStatus.cancelled,
    TripStatus.noDriver,
  }.contains(this);
  bool get canCancel => {
    TripStatus.scheduled,
    TripStatus.requested,
    TripStatus.confirmed,
    TripStatus.driverEnRoute,
    TripStatus.driverArrived,
  }.contains(this);
  bool canTransitionTo(TripStatus next) =>
      this == next ||
      (next == TripStatus.cancelled && canCancel) ||
      switch (this) {
        TripStatus.scheduled => next == TripStatus.requested,
        TripStatus.requested =>
          next == TripStatus.confirmed || next == TripStatus.noDriver,
        TripStatus.confirmed => next == TripStatus.driverEnRoute,
        TripStatus.driverEnRoute => next == TripStatus.driverArrived,
        TripStatus.driverArrived => next == TripStatus.inProgress,
        TripStatus.inProgress => next == TripStatus.completed,
        _ => false,
      };
}

enum TripPaymentMethod { cash, wallet }

final class TripBookingInput extends Equatable {
  const TripBookingInput({
    required this.pickup,
    required this.destination,
    required this.vehicleClassId,
    required this.fare,
    this.scheduledAt,
    this.paymentMethod = TripPaymentMethod.cash,
    this.couponCode,
  });
  final TripLocation pickup;
  final TripLocation destination;
  final String vehicleClassId;
  final Money fare;
  final DateTime? scheduledAt;
  final TripPaymentMethod paymentMethod;
  final String? couponCode;
  @override
  List<Object?> get props => [
    pickup,
    destination,
    vehicleClassId,
    fare,
    scheduledAt,
    paymentMethod,
    couponCode,
  ];
}

/// Optional recorded receipt facts; absent values must never be inferred.
final class TripReceipt extends Equatable {
  const TripReceipt({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.baseFare,
    required this.discount,
    required this.settled,
    this.isSimulated = false,
  });
  final int distanceMeters, durationSeconds;
  final Money baseFare, discount;
  final bool settled;
  final bool isSimulated;
  @override
  List<Object?> get props => [
    distanceMeters,
    durationSeconds,
    baseFare,
    discount,
    settled,
    isSimulated,
  ];
}

final class Trip extends Equatable {
  const Trip({
    required this.id,
    required this.booking,
    required this.createdAt,
    required this.status,
    this.live,
    this.receipt,
  });
  final String id;
  final TripBookingInput booking;
  final DateTime createdAt;
  final TripStatus status;
  final TripLiveDetails? live;
  final TripReceipt? receipt;
  bool get canCancel => status.canCancel;
  Trip withStatus(TripStatus value) => Trip(
    id: id,
    booking: booking,
    createdAt: createdAt,
    status: value,
    live: live,
    receipt: receipt,
  );
  Trip withLive(TripStatus status, TripLiveDetails details) => Trip(
    id: id,
    booking: booking,
    createdAt: createdAt,
    status: status,
    live: details,
    receipt: receipt,
  );
  @override
  List<Object?> get props => [id, booking, createdAt, status, live, receipt];
}
