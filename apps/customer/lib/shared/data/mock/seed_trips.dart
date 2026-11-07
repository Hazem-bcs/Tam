import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// Stable, synthetic places and historic trips. Never production account data.
List<Trip> seedMockTrips() {
  final pickup = TripLocation(
    label: 'المزة، شارع الجلاء',
    point: GeoPoint(latitude: 33.500, longitude: 36.250),
  );
  final destination = TripLocation(
    label: 'أبو رمانة، شارع الحمراء',
    point: GeoPoint(latitude: 33.519, longitude: 36.283),
  );
  TripBookingInput booking(int amount) => TripBookingInput(
    pickup: pickup,
    destination: destination,
    vehicleClassId: 'standard',
    fare: Money(amountMinor: amount),
  );
  return [
    Trip(
      id: 'mock-history-001',
      booking: booking(25000),
      createdAt: DateTime.utc(2026, 11, 1, 12),
      status: TripStatus.completed,
    ),
    Trip(
      id: 'mock-history-002',
      booking: booking(28000),
      createdAt: DateTime.utc(2026, 10, 30, 9),
      status: TripStatus.cancelled,
    ),
  ];
}
