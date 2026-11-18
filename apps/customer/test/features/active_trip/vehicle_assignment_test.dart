import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/active_trip/data/mock/mock_vehicle_driver.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';

import 'active_trip_test_support.dart';

void main() {
  for (final classId in ['motorbike', 'van', 'standard', 'comfort']) {
    test(
      '$classId assignment describes the booked vehicle in both languages',
      () async {
        final f = ActiveTripFixture();
        addTearDown(f.dispose);
        final booked = f.book(vehicleClassId: classId);
        await f.repository.fetch(booked.id);
        f.advance(3);
        final trip = (await f.repository.fetch(booked.id))!;
        final driver = trip.live!.driver!;
        expect(trip.booking.vehicleClassId, classId);
        if (classId == 'motorbike') {
          expect(driver.vehicle, contains('موتور'));
          expect(driver.vehicleEn, contains('Motorbike'));
        } else if (classId == 'van') {
          expect(driver.vehicle, contains('فان'));
          expect(driver.vehicleEn, contains('Van'));
        } else {
          expect(driver.vehicle, contains('سيراتو'));
        }
      },
    );
  }
  test('new artwork does not rewrite a real driver record', () {
    const driver = TripDriver(
      id: 'api-driver',
      name: 'أحمد',
      nameEn: 'Ahmad',
      vehicle: 'مركبة السائق',
      vehicleEn: 'Driver vehicle',
      plate: '123',
      rating: 4.9,
      vehicleImageUrl: 'https://tam.invalid/vehicle.png',
    );
    expect(
      identical(mockVehicleDriver('motorbike', existing: driver), driver),
      isTrue,
    );
  });
  test(
    'old persisted mock car metadata is corrected for a motorbike booking',
    () {
      final previous = mockVehicleDriver('standard');
      final corrected = mockVehicleDriver('motorbike', existing: previous);
      expect(corrected.vehicle, contains('موتور'));
      expect(corrected.id, previous.id);
    },
  );
}
