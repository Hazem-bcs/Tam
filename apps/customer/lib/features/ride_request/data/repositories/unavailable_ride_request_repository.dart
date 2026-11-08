import 'package:tam_customer/features/ride_request/domain/repositories/ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// Explicit API-mode boundary until an authenticated transport is implemented.
final class UnavailableRideRequestRepository implements RideRequestRepository {
  const UnavailableRideRequestRepository();

  Never _unavailable() => throw const RideRequestFailure('SERVICE_UNAVAILABLE');

  @override
  Future<List<RidePlace>> searchPlaces(String query) async => _unavailable();

  @override
  Future<RideQuote> requestQuote({
    required TripLocation pickup,
    required TripLocation destination,
    required RideVehicleClass vehicleClass,
  }) async => _unavailable();

  @override
  Future<Trip> confirm({
    required RideQuote quote,
    required String idempotencyKey,
  }) async => _unavailable();
}
