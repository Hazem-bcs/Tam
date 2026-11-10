import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:tam_customer/core/cache/local_cache_store.dart';
import 'package:tam_customer/core/cache/sqlite_cache_store.dart';
import 'package:tam_customer/core/config/app_config.dart';
import 'package:tam_customer/core/network/api_client.dart';
import 'package:tam_customer/features/account_management/account_management_entry.dart';
import 'package:tam_customer/features/active_trip/active_trip_entry.dart';
import 'package:tam_customer/features/addresses/addresses_dependencies.dart';
import 'package:tam_customer/features/auth/auth_dependencies.dart';
import 'package:tam_customer/features/chat/chat_entry.dart';
import 'package:tam_customer/features/completion/completion_entry.dart';
import 'package:tam_customer/features/driver_contact/driver_contact_entry.dart';
import 'package:tam_customer/features/maps/maps_dependencies.dart';
import 'package:tam_customer/features/ride_request/ride_request_dependencies.dart';
import 'package:tam_customer/features/support/support_entry.dart';

final GetIt locator = GetIt.instance;

void configureDependencies() {
  locator.registerFactory<MapsDependencies>(
    () => MapsDependencies.configured(AppConfig.maps),
  );
  locator.registerLazySingleton<Dio>(
    () => buildApiClient(AppConfig.apiBaseUrl),
  );
  locator.registerLazySingleton<LocalCacheStore>(SqliteCacheStore.new);
  registerAuthDependencies(locator);
  registerRideRequestDependencies(locator);
  registerAddressesDependencies(locator);
  registerActiveTripDependencies(locator);
  registerChatDependencies(locator);
  registerCompletionDependencies(locator);
  registerSupportDependencies(locator);
  registerAccountManagementDependencies(locator);
  registerDriverContactDependencies(locator);
}
