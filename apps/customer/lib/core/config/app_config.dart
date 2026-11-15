import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/core/config/map_configuration.dart';
import 'package:tam_customer/features/account_management/domain/account_management_repository.dart';
import 'package:tam_customer/features/active_trip/domain/active_trip_repository.dart';
import 'package:tam_customer/features/chat/domain/chat_repository.dart';
import 'package:tam_customer/features/completion/domain/completion_repository.dart';
import 'package:tam_customer/features/maps/domain/location_fix.dart';
import 'package:tam_customer/features/support/domain/support_repository.dart';
import 'package:tam_customer/shared/domain/ride_schedule_policy.dart';

abstract final class AppConfig {
  static const locationPolicy = LocationPolicy();
  static MapConfiguration get maps => MapConfiguration.parse(
    // Liberty uses OpenFreeMap vector tiles. Legacy raster requires explicitly
    // disabling the vector asset; errors never fall back to another provider.
    vectorStyleAsset: const String.fromEnvironment(
      'MAP_VECTOR_STYLE_ASSET',
      defaultValue: MapConfiguration.libertyStyleAsset,
    ),
    tileUrl: const String.fromEnvironment(
      'MAP_TILES_URL_TEMPLATE',
      defaultValue: '',
    ),
    apiBaseUrl: const String.fromEnvironment('MAP_API_BASE_URL'),
    allowLocalHttp: const bool.fromEnvironment('MAP_ALLOW_LOCAL_HTTP'),
  );
  static const rideSchedulePolicy = RideSchedulePolicy();
  static const activeTripPolicy = ActiveTripPolicy();
  static const chatPolicy = ChatPolicy();
  static const completionPolicy = CompletionPolicy();
  static const accountPolicy = AccountPolicy();
  static const accountMockScenario = String.fromEnvironment(
    'ACCOUNT_MOCK_SCENARIO',
    defaultValue: 'success',
  );
  static const driverContactMockScenario = String.fromEnvironment(
    'DRIVER_CONTACT_MOCK_SCENARIO',
    defaultValue: 'success',
  );
  static const supportPolicy = SupportPolicy();
  static const completionMockScenario = String.fromEnvironment(
    'COMPLETION_MOCK_SCENARIO',
    defaultValue: 'success',
  );
  static const supportMockScenario = String.fromEnvironment(
    'SUPPORT_MOCK_SCENARIO',
    defaultValue: 'success',
  );
  static const chatMockScenario = String.fromEnvironment(
    'CHAT_MOCK_SCENARIO',
    defaultValue: 'success',
  );
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
      CustomerFeature.accountManagement: String.fromEnvironment(
        'ACCOUNT_MANAGEMENT_DATA_MODE',
      ),
      CustomerFeature.driverContact: String.fromEnvironment(
        'DRIVER_CONTACT_DATA_MODE',
      ),
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
      CustomerFeature.chat: String.fromEnvironment('CHAT_DATA_MODE'),
      CustomerFeature.completion: String.fromEnvironment(
        'COMPLETION_DATA_MODE',
      ),
      CustomerFeature.support: String.fromEnvironment('SUPPORT_DATA_MODE'),
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
