import 'package:equatable/equatable.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';

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
  inProgress,
  completed,
  cancelled,
}

final class TripBookingInput extends Equatable {
  const TripBookingInput({
    required this.pickup,
    required this.destination,
    required this.vehicleClassId,
    required this.fare,
    this.scheduledAt,
  });
  final TripLocation pickup;
  final TripLocation destination;
  final String vehicleClassId;
  final Money fare;
  final DateTime? scheduledAt;
  @override
  List<Object?> get props => [
    pickup,
    destination,
    vehicleClassId,
    fare,
    scheduledAt,
  ];
}

final class Trip extends Equatable {
  const Trip({
    required this.id,
    required this.booking,
    required this.createdAt,
    required this.status,
  });
  final String id;
  final TripBookingInput booking;
  final DateTime createdAt;
  final TripStatus status;
  bool get canCancel =>
      status == TripStatus.scheduled ||
      status == TripStatus.requested ||
      status == TripStatus.confirmed;
  Trip withStatus(TripStatus value) =>
      Trip(id: id, booking: booking, createdAt: createdAt, status: value);
  @override
  List<Object?> get props => [id, booking, createdAt, status];
}
