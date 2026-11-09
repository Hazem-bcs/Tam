import 'package:equatable/equatable.dart';
import 'package:tam_customer/shared/domain/trip.dart';

bool canContactDriver(Trip trip) =>
    trip.live?.driver != null &&
    {
      TripStatus.confirmed,
      TripStatus.driverEnRoute,
      TripStatus.driverArrived,
      TripStatus.inProgress,
    }.contains(trip.status);

final class DriverContact extends Equatable {
  const DriverContact({
    required this.tripId,
    required this.driverId,
    required this.phoneE164,
    required this.expiresAt,
  });
  final String tripId, driverId, phoneE164;
  final DateTime expiresAt;
  @override
  List<Object?> get props => [tripId, driverId, phoneE164, expiresAt];
}

enum DialerResult { opened, simulated }

abstract interface class PhoneDialer {
  Future<DialerResult> open(String phoneE164);
}

/// Invalidates an observed trip binding; position-only updates are excluded.
final class DriverContactChange {
  const DriverContactChange({this.sessionReset = false, this.tripId});
  final bool sessionReset;
  final String? tripId;
}

abstract interface class DriverContactRepository {
  Future<DriverContact> fetch({
    required String tripId,
    required String driverId,
  });
  Stream<DriverContactChange> get changes;
}

final class DriverContactFailure implements Exception {
  const DriverContactFailure(this.code);
  final String code;
}
