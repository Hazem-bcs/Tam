import 'package:equatable/equatable.dart';
import 'package:tam_customer/shared/domain/trip.dart';

enum AddressIcon { home, work, study, gym, other }

final class AddressInput extends Equatable {
  AddressInput({
    required String name,
    required this.icon,
    required TripLocation location,
  }) : location = TripLocation(
         label: location.label.trim(),
         point: location.point,
       ),
       name = name.trim() {
    if (!validName(this.name) || !validLocation(location)) {
      throw ArgumentError('Invalid saved address');
    }
  }

  static const maxNameLength = 50;
  static const maxLocationLength = 200;
  final String name;
  final AddressIcon icon;
  final TripLocation location;

  static bool validName(String name) =>
      name.trim().isNotEmpty && name.trim().runes.length <= maxNameLength;
  static bool validLocation(TripLocation location) =>
      location.label.trim().isNotEmpty &&
      location.label.trim().runes.length <= maxLocationLength;

  @override
  List<Object?> get props => [name, icon, location];
}

final class SavedAddress extends Equatable {
  const SavedAddress({
    required this.id,
    required this.input,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final AddressInput input;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, input, createdAt, updatedAt];
}
