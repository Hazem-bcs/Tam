import 'dart:async';

import 'package:tam_customer/features/maps/domain/maps_repository.dart';
import 'package:tam_customer/shared/domain/geo_path.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';

/// Prepares both simulated legs once, through the same routing boundary as maps.
/// Network completion never writes a trip or resurrects a cancelled session.
final class MockRoadRoutes {
  MockRoadRoutes(this.repository, {required this.now, required this.onChanged});
  final MapsRepository repository;
  final DateTime Function() now;
  final void Function() onChanged;
  final _entries = <String, MockRoadRoutePair>{};
  int _epoch = 0;

  MockRoadRoutePair prepare(Trip trip) {
    var pair = _entries[trip.id];
    if (pair == null ||
        pair.booking != trip.booking ||
        pair.createdAt != trip.createdAt) {
      pair = MockRoadRoutePair(trip);
      _entries[trip.id] = pair;
    }
    if (!pair.loading &&
        pair.readyAt == null &&
        (pair.retryAt == null || !now().isBefore(pair.retryAt!))) {
      pair.loading = true;
      unawaited(_load(trip, pair, _epoch));
    }
    return pair;
  }

  Future<void> _load(Trip trip, MockRoadRoutePair pair, int epoch) async {
    final pickup = trip.booking.pickup.point;
    final destination = trip.booking.destination.point;
    try {
      // The mock captain starts halfway between the chosen locations. OSRM
      // snaps that seed to a road; all subsequent fixes use its road geometry.
      pair.approach ??= _tracking(
        await repository.route(GeoPath.mix(pickup, destination, .5), pickup),
        trip.id,
        TrackingRouteLeg.toPickup,
      );
      if (epoch != _epoch || !identical(_entries[trip.id], pair)) return;
      pair.journey ??= _tracking(
        await repository.route(pickup, destination),
        trip.id,
        TrackingRouteLeg.toDestination,
      );
      pair.readyAt = pair.previouslyPrepared ? trip.createdAt : now().toUtc();
      pair.failed = false;
    } catch (_) {
      // Do not substitute synthetic geometry if a real route cannot be loaded.
      pair.failed = true;
      pair.retryAt = now().add(const Duration(seconds: 10));
    } finally {
      pair.loading = false;
      if (epoch == _epoch && identical(_entries[trip.id], pair)) onChanged();
    }
  }

  TripTrackingRoute _tracking(
    MapRoute route,
    String tripId,
    TrackingRouteLeg leg,
  ) {
    if (!route.roadAligned || route.points.length < 2) {
      throw const MapsFailure('INVALID_RESPONSE');
    }
    return TripTrackingRoute(
      id: 'osrm-$tripId-${leg.name}',
      leg: leg,
      points: route.points,
    );
  }

  void retain(Iterable<String> ids) {
    final active = ids.toSet();
    _entries.removeWhere((key, _) => !active.contains(key));
  }

  void clear() {
    _epoch++;
    _entries.clear();
  }
}

final class MockRoadRoutePair {
  MockRoadRoutePair(Trip trip)
    : booking = trip.booking,
      createdAt = trip.createdAt,
      previouslyPrepared =
          trip.live?.route?.roadAligned == true &&
          (trip.live?.route?.id.startsWith('osrm-') ?? false);
  final TripBookingInput booking;
  final DateTime createdAt;
  final bool previouslyPrepared;
  TripTrackingRoute? approach, journey;
  DateTime? readyAt, retryAt;
  bool loading = false, failed = false;

  /// Keep the accelerated preview below 18 m/s, even on long one-way detours.
  Duration travelTime(TripTrackingRoute? route, Duration minimum) {
    if (route == null) return minimum;
    final seconds = (GeoPath(route.points).length / 18).ceil();
    return Duration(
      seconds: seconds > minimum.inSeconds ? seconds : minimum.inSeconds,
    );
  }
}
