import 'package:tam_customer/features/active_trip/domain/active_trip_repository.dart';
import 'package:tam_customer/features/active_trip/domain/upcoming_trips_repository.dart';
import 'package:tam_customer/shared/domain/trip.dart';

final class UnavailableActiveTripRepository
    implements ActiveTripRepository, UpcomingTripsRepository {
  const UnavailableActiveTripRepository();
  Never _unavailable() => throw const ActiveTripFailure('SERVICE_UNAVAILABLE');
  @override
  Future<Trip?> current() async => _unavailable();
  @override
  Future<List<Trip>> upcoming() async => _unavailable();
  @override
  Future<Trip?> fetch(String tripId) async => _unavailable();
  @override
  Future<Trip> cancel(String tripId) async => _unavailable();
  @override
  Stream<void> get changes => const Stream.empty();
}
