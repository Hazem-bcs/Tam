import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/features/active_trip/domain/active_trip_repository.dart';
import 'package:tam_customer/shared/domain/ride_schedule_policy.dart';

abstract final class AppConfig {
  static const rideSchedulePolicy = RideSchedulePolicy();
  static const activeTripPolicy = ActiveTripPolicy();
  static const activeTripMockScenario = String.fromEnvironment(
    'ACTIVE_TRIP_MOCK_SCENARIO',
    defaultValue: 'success',
  );

  /// Use --dart-define=API_BASE_URL=https://your-service.example/v1.
  /// Never put privileged server credentials in a mobile binary.
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static FeatureDataModes get featureDataModes => FeatureDataModes.parse(
    defaultValue: const String.fromEnvironment(
      'DATA_MODE',
      defaultValue: 'mock',
    ),
    overrides: const {
      CustomerFeature.home: String.fromEnvironment('HOME_DATA_MODE'),
      CustomerFeature.rideRequest: String.fromEnvironment(
        'RIDE_REQUEST_DATA_MODE',
      ),
      CustomerFeature.trips: String.fromEnvironment('TRIPS_DATA_MODE'),
      CustomerFeature.notifications: String.fromEnvironment(
        'NOTIFICATIONS_DATA_MODE',
      ),
      CustomerFeature.settings: String.fromEnvironment('SETTINGS_DATA_MODE'),
      CustomerFeature.addresses: String.fromEnvironment('ADDRESSES_DATA_MODE'),
      CustomerFeature.activeTrip: String.fromEnvironment(
        'ACTIVE_TRIP_DATA_MODE',
      ),
    },
  );

  /// Temporary local phone entry until the Auth API is connected.
  /// This opens the app without creating an authenticated backend session.
  static const temporaryPhoneEntryEnabled = bool.fromEnvironment(
    'TEMPORARY_PHONE_ENTRY',
    defaultValue: true,
  );
}
