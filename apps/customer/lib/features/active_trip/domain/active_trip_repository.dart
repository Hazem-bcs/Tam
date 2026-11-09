import 'package:tam_customer/shared/domain/trip.dart';

final class ActiveTripFailure implements Exception {
  const ActiveTripFailure(this.code);
  final String code;
}

final class ActiveTripPolicy {
  const ActiveTripPolicy({
    this.pollInterval = const Duration(seconds: 5),
    this.staleAfter = const Duration(seconds: 15),
    this.positionStaleAfter = const Duration(seconds: 30),
  });
  final Duration pollInterval, staleAfter, positionStaleAfter;
}

abstract interface class ActiveTripRepository {
  /// Null means no visible active trip, not a network failure.
  Future<Trip?> current();
  Future<Trip?> fetch(String tripId);

  /// Existing cancellation operation; repeated calls are safe for the same id.
  Future<Trip> cancel(String tripId);

  /// Optional invalidation events. Polling also resynchronizes missed events.
  Stream<void> get changes;
}
