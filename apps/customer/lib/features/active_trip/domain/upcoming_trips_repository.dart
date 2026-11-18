import 'package:tam_customer/shared/domain/trip.dart';

/// Upcoming reservations are separate from the immediate journey selected by
/// ActiveTripRepository.current. Each reservation remains addressable by id.
abstract interface class UpcomingTripsRepository {
  Future<List<Trip>> upcoming();
  Stream<void> get changes;
}
