import 'package:tam_customer/features/trips/domain/trips_repository.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// Explicit failure until a real, authenticated HTTP adapter is delivered.
final class UnavailableTripsRepository implements TripsRepository {
  const UnavailableTripsRepository();

  @override
  Stream<void> get changes => const Stream<void>.empty();

  @override
  Future<TripsPage> list({
    TripsFilter filter = TripsFilter.all,
    String? cursor,
    int limit = 20,
  }) async => throw const TripsFailure('SERVICE_UNAVAILABLE');

  @override
  Future<Trip?> find(String tripId) async =>
      throw const TripsFailure('SERVICE_UNAVAILABLE');

  @override
  Future<Trip> cancel(String tripId) async =>
      throw const TripsFailure('SERVICE_UNAVAILABLE');
}
