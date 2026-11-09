import 'package:tam_customer/features/active_trip/data/mock/active_trip_scenario.dart';
import 'package:tam_customer/shared/data/trip_live_codec.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';

/// Pure deterministic driver-side simulation. The customer never issues these
/// transitions; the data adapter commits them to the shared store atomically.
final class ActiveTripSimulation {
  const ActiveTripSimulation(this.timings, this.scenario);
  final ActiveTripTimings timings;
  final ActiveTripScenario scenario;

  Trip? next(Trip trip, DateTime now) {
    if (!trip.status.isActive) return null;
    final live = trip.live;
    if (live != null && now.isBefore(live.updatedAt)) return null;
    final changedAt = live?.statusChangedAt ?? trip.createdAt;
    var nextStatus = trip.status;
    var phaseTime = changedAt;
    final due = switch (trip.status) {
      TripStatus.scheduled => trip.booking.scheduledAt!,
      TripStatus.requested => changedAt.add(timings.search),
      TripStatus.confirmed => changedAt.add(timings.assignment),
      TripStatus.driverEnRoute => changedAt.add(timings.approach),
      TripStatus.driverArrived => changedAt.add(timings.waiting),
      TripStatus.inProgress => changedAt.add(timings.journey),
      _ => now,
    };
    if (!now.isBefore(due)) {
      nextStatus = switch (trip.status) {
        TripStatus.scheduled => TripStatus.requested,
        TripStatus.requested =>
          scenario == ActiveTripScenario.noDriver
              ? TripStatus.noDriver
              : TripStatus.confirmed,
        TripStatus.confirmed => TripStatus.driverEnRoute,
        TripStatus.driverEnRoute => TripStatus.driverArrived,
        TripStatus.driverArrived => TripStatus.inProgress,
        TripStatus.inProgress => TripStatus.completed,
        _ => trip.status,
      };
      phaseTime = due;
    }
    final assigned = {
      TripStatus.confirmed,
      TripStatus.driverEnRoute,
      TripStatus.driverArrived,
      TripStatus.inProgress,
      TripStatus.completed,
    }.contains(nextStatus);
    final driver = assigned
        ? live?.driver ?? TripLiveCodec.driverFromJson(mockDriverJson)
        : null;
    final tracking = {
      TripStatus.driverEnRoute,
      TripStatus.driverArrived,
      TripStatus.inProgress,
    }.contains(nextStatus);
    DriverPosition? position;
    int? eta;
    if (tracking) {
      final duration = nextStatus == TripStatus.inProgress
          ? timings.journey
          : timings.approach;
      final elapsed = now.difference(phaseTime);
      final fraction = (elapsed.inMilliseconds / duration.inMilliseconds).clamp(
        0.0,
        1.0,
      );
      final pickup = trip.booking.pickup.point;
      final destination = trip.booking.destination.point;
      final origin = nextStatus == TripStatus.inProgress
          ? pickup
          : GeoPoint(
              latitude:
                  pickup.latitude +
                  (destination.latitude - pickup.latitude) * 0.5,
              longitude:
                  pickup.longitude +
                  (destination.longitude - pickup.longitude) * 0.5,
            );
      final target = nextStatus == TripStatus.inProgress ? destination : pickup;
      final point = nextStatus == TripStatus.driverArrived
          ? pickup
          : GeoPoint(
              latitude:
                  origin.latitude +
                  (target.latitude - origin.latitude) * fraction,
              longitude:
                  origin.longitude +
                  (target.longitude - origin.longitude) * fraction,
            );
      position = DriverPosition(point: point, recordedAt: now);
      eta = nextStatus == TripStatus.driverArrived
          ? 0
          : ((duration - elapsed).inSeconds).clamp(0, duration.inSeconds);
    }
    if (live != null &&
        nextStatus == trip.status &&
        (position == null ||
            now.difference(live.updatedAt) < const Duration(seconds: 1))) {
      return null;
    }
    return trip.withLive(
      nextStatus,
      TripLiveDetails(
        revision: (live?.revision ?? 0) + 1,
        updatedAt: now,
        statusChangedAt: phaseTime,
        driver: driver ?? live?.driver,
        position: position,
        etaSeconds: eta,
      ),
    );
  }
}
