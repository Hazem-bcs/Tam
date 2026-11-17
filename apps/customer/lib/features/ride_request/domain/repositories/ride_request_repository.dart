import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// Returns domain values only; the API adapter must never fall back to mock.
abstract interface class RideRequestRepository {
  Future<List<RidePlace>> searchPlaces(String query);

  Future<RideQuote> requestQuote({
    required TripLocation pickup,
    required TripLocation destination,
    required RideVehicleClass vehicleClass,
    DateTime? scheduledAt,
    TripPaymentMethod paymentMethod = TripPaymentMethod.cash,
    String? couponCode,
  });

  /// Keep the same idempotency key on retries of this exact booking.
  Future<Trip> confirm({
    required RideQuote quote,
    required String idempotencyKey,
  });
}
