import 'package:tam_customer/shared/data/trip_live_codec.dart';
import 'package:tam_customer/shared/domain/trip_live_details.dart';

import 'active_trip_scenario.dart';

/// Synthetic assignment metadata belongs to the mock, never the UI or API.
TripDriver mockVehicleDriver(String classId, {TripDriver? existing}) {
  if (existing != null && !existing.id.startsWith('mock-driver-')) {
    return existing;
  }
  final vehicle = switch (classId) {
    'motorbike' => ('موتور · أسود', 'Motorbike · Black'),
    'van' => ('فان · أبيض', 'Van · White'),
    _ => (mockDriverJson['vehicle']!, mockDriverJson['vehicle_en']!),
  };
  return TripLiveCodec.driverFromJson({
    ...mockDriverJson,
    'vehicle': vehicle.$1,
    'vehicle_en': vehicle.$2,
  });
}
