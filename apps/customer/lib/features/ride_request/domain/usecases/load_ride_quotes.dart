import 'package:tam_customer/features/ride_request/domain/repositories/ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// Loads comparable quotes for one immutable intent; failures on an unselected
/// class don't hide the selected quote. The caller owns revision/expiry checks.
class LoadRideQuotes {
  const LoadRideQuotes(this.repository);
  final RideRequestRepository repository;

  Future<Map<RideVehicleClass, RideQuote>> call({
    required TripLocation pickup,
    required TripLocation destination,
    required RideVehicleClass selected,
    required TripPaymentMethod paymentMethod,
    required String? couponCode,
    DateTime? scheduledAt,
  }) async {
    final quotes = <RideVehicleClass, RideQuote>{};
    RideRequestFailure? selectedFailure;
    await Future.wait(
      RideVehicleClass.values.map((vehicle) async {
        try {
          final quote = await repository.requestQuote(
            pickup: pickup,
            destination: destination,
            vehicleClass: vehicle,
            scheduledAt: scheduledAt,
            paymentMethod: paymentMethod,
            couponCode: couponCode,
          );
          if (quote.pickup != pickup ||
              quote.destination != destination ||
              quote.vehicleClass != vehicle ||
              quote.scheduledAt != scheduledAt ||
              quote.paymentMethod != paymentMethod ||
              quote.couponCode != couponCode ||
              (quote.discount == null) != (couponCode == null) ||
              (quote.discount != null &&
                  (quote.discount!.currency != quote.fare.currency ||
                      quote.discount!.minorUnit != quote.fare.minorUnit))) {
            throw const RideRequestFailure('INVALID_RESPONSE');
          }
          quotes[vehicle] = quote;
        } on RideRequestFailure catch (error) {
          if (vehicle == selected) selectedFailure = error;
        }
      }),
    );
    if (selectedFailure != null) throw selectedFailure!;
    return Map.unmodifiable(quotes);
  }
}
