import 'package:tam_customer/features/active_trip/domain/active_trip_repository.dart';
import 'package:tam_customer/shared/data/trip_live_codec.dart';
import 'package:tam_customer/shared/data/trip_wire_codec.dart';
import 'package:tam_customer/shared/domain/trip.dart';

abstract final class ActiveTripCodec {
  static Trip? response(Map<String, dynamic> json, {bool allowEmpty = false}) {
    if (allowEmpty && json.containsKey('data') && json['data'] == null) {
      return null;
    }
    final trip = TripWireCodec.fromJson(TripLiveCodec.object(json['data']));
    final live = trip.live;
    if (allowEmpty && !trip.status.isActive) {
      throw const FormatException('Current trip must be active');
    }
    if (live == null ||
        live.statusChangedAt.isBefore(trip.createdAt) ||
        live.updatedAt.isBefore(trip.createdAt)) {
      throw const FormatException('Missing/invalid live snapshot');
    }
    final needsDriver = {
      TripStatus.confirmed,
      TripStatus.driverEnRoute,
      TripStatus.driverArrived,
      TripStatus.inProgress,
    }.contains(trip.status);
    if (needsDriver && live.driver == null) {
      throw const FormatException('Missing driver');
    }
    if ({
          TripStatus.scheduled,
          TripStatus.requested,
          TripStatus.noDriver,
        }.contains(trip.status) &&
        (live.driver != null ||
            live.position != null ||
            live.etaSeconds != null)) {
      throw const FormatException('Unexpected assignment');
    }
    if (!trip.status.isActive &&
        (live.position != null || live.etaSeconds != null)) {
      throw const FormatException('Terminal trip cannot have live tracking');
    }
    return trip;
  }

  static ActiveTripFailure failure(Map<String, dynamic> json) {
    final error = TripLiveCodec.object(json['error']);
    final message = TripLiveCodec.object(error['message']);
    TripLiveCodec.text(message, 'ar');
    TripLiveCodec.text(message, 'en');
    return ActiveTripFailure(TripLiveCodec.text(error, 'code'));
  }
}
