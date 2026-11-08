import 'package:tam_customer/features/ride_request/domain/repositories/ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import '../domain/addresses_repository.dart';

/// Maps the existing places boundary; owns no new endpoint or place fixtures.
final class RideAddressPlaceSearch implements AddressPlaceSearch {
  const RideAddressPlaceSearch(this._places, {required this.languageCode});
  final RideRequestRepository _places;
  final String languageCode;

  @override
  Future<List<TripLocation>> search(String query) async {
    try {
      final results = await _places.searchPlaces(query);
      return List.unmodifiable(
        results.map(
          (place) => TripLocation(
            label: languageCode == 'ar'
                ? place.location.label
                : place.englishLabel,
            point: place.location.point,
          ),
        ),
      );
    } on RideRequestFailure catch (failure) {
      throw AddressFailure(
        failure.code == 'SERVICE_UNAVAILABLE'
            ? AddressFailureCode.unavailable
            : AddressFailureCode.network,
      );
    }
  }
}
