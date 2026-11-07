import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:tam_customer/core/cache/local_cache_store.dart';
import 'package:tam_customer/core/cache/sqlite_cache_store.dart';
import 'package:tam_customer/core/config/app_config.dart';
import 'package:tam_customer/core/network/api_client.dart';
import 'package:tam_customer/features/auth/auth_dependencies.dart';
import 'package:tam_customer/features/ride_request/ride_request_dependencies.dart';

final GetIt locator = GetIt.instance;

void configureDependencies() {
  locator.registerLazySingleton<Dio>(
    () => buildApiClient(AppConfig.apiBaseUrl),
  );
  locator.registerLazySingleton<LocalCacheStore>(SqliteCacheStore.new);
  registerAuthDependencies(locator);
  registerRideRequestDependencies(locator);
}
