import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';

/// Stable, synthetic places and historic trips. Never production account data.
List<Trip> seedMockTrips({bool includeReceiptPreview = false}) {
  final pickup = TripLocation(
    label: 'المزة، شارع الجلاء',
    point: GeoPoint(latitude: 33.500, longitude: 36.250),
  );
  final destination = TripLocation(
    label: 'أبو رمانة، شارع الحمراء',
    point: GeoPoint(latitude: 33.519, longitude: 36.283),
  );
  TripBookingInput booking(int amount, {String? coupon}) => TripBookingInput(
    pickup: pickup,
    destination: destination,
    vehicleClassId: 'standard',
    fare: Money(amountMinor: amount),
    couponCode: coupon,
  );
  return [
    Trip(
      id: 'mock-history-001',
      booking: booking(25000, coupon: includeReceiptPreview ? 'TAM20' : null),
      createdAt: DateTime.utc(2026, 11, 1, 12),
      status: TripStatus.completed,
      receipt: !includeReceiptPreview
          ? null
          : TripReceipt(
              distanceMeters: 7800,
              durationSeconds: 1080,
              baseFare: Money(amountMinor: 30000),
              discount: Money(amountMinor: 5000),
              settled: true,
              isSimulated: true,
            ),
      live: !includeReceiptPreview
          ? null
          : TripLiveDetails(
              revision: 1,
              updatedAt: DateTime.utc(2026, 11, 1, 12, 18),
              statusChangedAt: DateTime.utc(2026, 11, 1, 12, 18),
              driver: const TripDriver(
                id: 'mock-history-driver-001',
                name: 'محمد أحمد',
                nameEn: 'Mohammad Ahmad',
                vehicle: 'كيا سيراتو · أبيض',
                vehicleEn: 'Kia Cerato · White',
                plate: '12345',
                rating: 4.9,
              ),
            ),
    ),
    Trip(
      id: 'mock-history-002',
      booking: booking(28000),
      createdAt: DateTime.utc(2026, 10, 30, 9),
      status: TripStatus.cancelled,
    ),
  ];
}
