import 'package:tam_customer/features/ride_request/domain/ride_models.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// Synthetic fixture: not GPS, saved addresses, or a live places service.
const mockRidePlaceFixtureVersion = 'ride-places-v1';

final mockRidePlaces = List<RidePlace>.unmodifiable([
  RidePlace(
    id: 'place-mezzeh',
    location: TripLocation(
      label: 'المزة، شارع الجلاء',
      point: GeoPoint(latitude: 33.500, longitude: 36.250),
    ),
    englishLabel: 'Mezzeh, Al-Jalaa Street',
  ),
  RidePlace(
    id: 'place-abou-rommaneh',
    location: TripLocation(
      label: 'أبو رمانة، شارع الحمراء',
      point: GeoPoint(latitude: 33.519, longitude: 36.283),
    ),
    englishLabel: 'Abu Rummaneh, Al-Hamra Street',
  ),
  RidePlace(
    id: 'place-omayyad',
    location: TripLocation(
      label: 'ساحة الأمويين',
      point: GeoPoint(latitude: 33.516, longitude: 36.271),
    ),
    englishLabel: 'Umayyad Square',
  ),
  RidePlace(
    id: 'place-saadallah',
    location: TripLocation(
      label: 'ساحة سعد الله الجابري، حلب',
      point: GeoPoint(latitude: 36.200, longitude: 37.155),
    ),
    englishLabel: 'Saadallah Al-Jabiri Square, Aleppo',
  ),
  RidePlace(
    id: 'place-citadel',
    location: TripLocation(
      label: 'قلعة حلب',
      point: GeoPoint(latitude: 36.199, longitude: 37.163),
    ),
    englishLabel: 'Aleppo Citadel',
  ),
]);
