import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';

import '../domain/addresses_repository.dart';
import '../domain/saved_address.dart';

abstract final class AddressesCodec {
  static SavedAddress item(Map<String, dynamic> json) {
    try {
      final created = _date(json['created_at']);
      final updated = _date(json['updated_at']);
      if (updated.isBefore(created)) {
        throw const FormatException('Invalid dates');
      }
      return SavedAddress(
        id: _string(json['id']),
        input: input(json),
        createdAt: created,
        updatedAt: updated,
      );
    } on ArgumentError {
      throw const FormatException('Invalid address');
    }
  }

  static AddressInput input(Map<String, dynamic> json) {
    final location = json['location'];
    if (location is! Map<String, dynamic>) {
      throw const FormatException('Missing location');
    }
    final lat = location['latitude'], lon = location['longitude'];
    if (lat is! num || lon is! num) {
      throw const FormatException('Invalid coordinates');
    }
    final icon = AddressIcon.values
        .where((v) => v.name == json['icon'])
        .firstOrNull;
    if (icon == null) throw const FormatException('Invalid icon');
    try {
      return AddressInput(
        name: _string(json['name']),
        icon: icon,
        location: TripLocation(
          label: _string(location['label']),
          point: GeoPoint(latitude: lat.toDouble(), longitude: lon.toDouble()),
        ),
      );
    } on ArgumentError {
      throw const FormatException('Invalid address input');
    }
  }

  static List<SavedAddress> list(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! List || data.length > AddressesRepository.maxAddresses) {
      throw const FormatException('Invalid address list');
    }
    final result = data.map((raw) {
      if (raw is! Map<String, dynamic>) {
        throw const FormatException('Invalid item');
      }
      return item(raw);
    }).toList();
    if (result.map((value) => value.id).toSet().length != result.length) {
      throw const FormatException('Duplicate address IDs');
    }
    return List.unmodifiable(result);
  }

  static SavedAddress response(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Missing data');
    }
    return item(data);
  }

  static String _string(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      throw const FormatException('Missing text');
    }
    return value;
  }

  static DateTime _date(Object? value) {
    if (value is! String) throw const FormatException('Missing date');
    final match = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(?:\.\d+)?Z$',
    ).firstMatch(value);
    if (match == null) throw const FormatException('Expected UTC date');
    final parsed = DateTime.parse(value);
    final components = [
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
    ];
    for (var i = 0; i < components.length; i++) {
      if (components[i] != int.parse(match.group(i + 1)!)) {
        throw const FormatException('Invalid calendar date');
      }
    }
    return parsed;
  }
}
