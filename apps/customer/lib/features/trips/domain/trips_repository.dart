import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:tam_customer/shared/domain/trip.dart';

enum TripsFilter { all, active, completed, cancelled }

extension TripsFilterRules on TripsFilter {
  bool includes(Trip trip) => switch (this) {
    TripsFilter.all => true,
    TripsFilter.active => switch (trip.status) {
      TripStatus.requested ||
      TripStatus.confirmed ||
      TripStatus.inProgress => true,
      _ => false,
    },
    TripsFilter.completed => trip.status == TripStatus.completed,
    TripsFilter.cancelled => trip.status == TripStatus.cancelled,
  };
}

final class TripsPage extends Equatable {
  const TripsPage({required this.items, required this.nextCursor});

  final List<Trip> items;
  final String? nextCursor;

  @override
  List<Object?> get props => [items, nextCursor];
}

/// Stable error codes are shared with the proposed trips v1 HTTP contract.
final class TripsFailure implements Exception {
  const TripsFailure(this.code);
  final String code;

  @override
  String toString() => 'TripsFailure($code)';
}

/// Domain boundary: no HTTP, JSON, MockTripStore, or Flutter dependency.
abstract interface class TripsRepository {
  Future<TripsPage> list({
    TripsFilter filter = TripsFilter.all,
    String? cursor,
    int limit = 20,
  });

  Future<Trip?> find(String tripId);
  Future<Trip> cancel(String tripId);

  /// Invalidation events; consumers request a fresh snapshot on change.
  Stream<void> get changes;
}
