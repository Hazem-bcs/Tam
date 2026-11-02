import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:mashwar_customer/core/cache/local_cache_store.dart';
import 'package:mashwar_customer/core/cache/sqlite_cache_store.dart';
import 'package:mashwar_customer/core/config/app_config.dart';
import 'package:mashwar_customer/core/network/api_client.dart';
import 'package:mashwar_customer/features/ride_request/ride_request_dependencies.dart';

final GetIt locator = GetIt.instance;

void configureDependencies() {
  locator.registerLazySingleton<Dio>(
    () => buildApiClient(AppConfig.apiBaseUrl),
  );
  locator.registerLazySingleton<LocalCacheStore>(SqliteCacheStore.new);
  registerRideRequestDependencies(locator);
}
