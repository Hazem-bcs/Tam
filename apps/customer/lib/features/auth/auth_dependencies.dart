import 'package:get_it/get_it.dart';
import 'package:tam_customer/core/config/app_config.dart';
import 'package:tam_customer/features/auth/data/memory_auth_session_store.dart';
import 'package:tam_customer/features/auth/data/unconfigured_auth_repository.dart';
import 'package:tam_customer/features/auth/domain/auth_repository.dart';

final class AuthPresentationConfig {
  const AuthPresentationConfig({this.temporaryPhoneEntryEnabled = false});
  final bool temporaryPhoneEntryEnabled;
}

void registerAuthDependencies(GetIt locator) {
  locator.registerSingleton<AuthRepository>(const UnconfiguredAuthRepository());
  locator.registerSingleton<AuthPresentationConfig>(
    const AuthPresentationConfig(
      temporaryPhoneEntryEnabled: AppConfig.temporaryPhoneEntryEnabled,
    ),
  );
  // Replace with an OS-backed secure store when configuring a real repository.
  locator.registerLazySingleton<AuthSessionStore>(MemoryAuthSessionStore.new);
}
