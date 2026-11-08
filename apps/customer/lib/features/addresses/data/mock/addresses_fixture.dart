import '../../domain/saved_address.dart';
import '../addresses_codec.dart';

/// Synthetic account fixtures; never the device's location or production data.
const addressesFixture = [
  {
    'id': 'address-home-001',
    'name': 'المنزل',
    'icon': 'home',
    'location': {
      'label': 'المزة، شارع الجلاء',
      'latitude': 33.500,
      'longitude': 36.250,
    },
    'created_at': '2026-11-07T09:00:00Z',
    'updated_at': '2026-11-07T09:00:00Z',
  },
  {
    'id': 'address-work-001',
    'name': 'العمل',
    'icon': 'work',
    'location': {
      'label': 'أبو رمانة، شارع الحمراء',
      'latitude': 33.519,
      'longitude': 36.283,
    },
    'created_at': '2026-11-07T08:00:00Z',
    'updated_at': '2026-11-07T08:00:00Z',
  },
];

List<SavedAddress> seedAddresses() =>
    List.unmodifiable(addressesFixture.map(AddressesCodec.item));
