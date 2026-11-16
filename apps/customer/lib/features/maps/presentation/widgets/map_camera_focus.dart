import 'package:equatable/equatable.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';

/// A one-shot camera intention. Its revision allows centering the same fix again
/// without changing the booking's pickup or destination.
final class MapCameraFocus extends Equatable {
  const MapCameraFocus(this.point, this.revision);
  final GeoPoint point;
  final int revision;
  @override
  List<Object> get props => [point, revision];
}
