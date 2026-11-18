/// Presentation artwork selected from the booking, never inferred from a name.
/// Car classes share a road silhouette; unknown future classes use the car.
enum VehicleMarkerKind {
  car('assets/maps/car-top.svg', 'tam-car'),
  van('assets/maps/van-top.svg', 'tam-van'),
  motorbike('assets/maps/motorbike-top.svg', 'tam-motorbike');

  const VehicleMarkerKind(this.asset, this.spriteId);
  final String asset, spriteId;

  static VehicleMarkerKind fromClassId(String? id) => switch (id) {
    'motorbike' => motorbike,
    'van' => van,
    _ => car,
  };
}
