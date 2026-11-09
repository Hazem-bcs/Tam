enum ActiveTripScenario {
  success,
  noDriver,
  disconnect;

  static ActiveTripScenario parse(String value) => switch (value) {
    'success' => success,
    'no_driver' => noDriver,
    'disconnect' => disconnect,
    _ => throw ArgumentError.value(value, 'ACTIVE_TRIP_MOCK_SCENARIO'),
  };
}

final class ActiveTripTimings {
  const ActiveTripTimings({
    this.search = const Duration(seconds: 12),
    this.assignment = const Duration(seconds: 5),
    this.approach = const Duration(seconds: 25),
    this.waiting = const Duration(seconds: 15),
    this.journey = const Duration(seconds: 30),
  });
  final Duration search, assignment, approach, waiting, journey;
}

const mockDriverJson = {
  'id': 'mock-driver-001',
  'name': 'محمد أحمد',
  'name_en': 'Mohammad Ahmad',
  'vehicle': 'كيا سيراتو · أبيض',
  'vehicle_en': 'Kia Cerato · White',
  'plate': 'دمشق ١٢٣٤٥٦',
  'rating': 4.9,
};
