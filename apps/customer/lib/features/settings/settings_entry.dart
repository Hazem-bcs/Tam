import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/di/service_locator.dart';
import 'package:tam_customer/app/locale/app_locale_controller.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_theme.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/features/settings/data/api/unavailable_settings_repository.dart';
import 'package:tam_customer/features/settings/data/mock/mock_settings_repository.dart';
import 'package:tam_customer/features/settings/domain/profile_photo_picker.dart';
import 'package:tam_customer/features/settings/domain/settings_repository.dart';
import 'package:tam_customer/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:tam_customer/features/settings/presentation/pages/settings_page.dart';

/// Feature-scoped, weakly keyed per application locale controller.
/// Saved mock edits survive route re-entry, but not app process restart.
final Expando<_RepositorySelection> _repositories =
    Expando<_RepositorySelection>('settings repositories');

final class _RepositorySelection {
  const _RepositorySelection(this.mode, this.phoneE164, this.repository);
  final FeatureDataMode mode;
  final String? phoneE164;
  final SettingsRepository repository;
}

/// Called by the app session owner whenever an entered session ends.
/// Locale belongs to the device; account mock data belongs to the session.
void resetSettingsFeatureSession(AppLocaleController locale) {
  _repositories[locale] = null;
}

Widget buildSettingsFeature(
  BuildContext context, {
  required CustomerNavigation navigation,
  required FeatureDataMode dataMode,
  required AppLocaleController locale,
  required Future<void> Function() logout,
  String? phoneE164,
  VoidCallback? onBack,
}) {
  var selected = _repositories[locale];
  if (selected == null ||
      selected.mode != dataMode ||
      selected.phoneE164 != phoneE164) {
    selected = _RepositorySelection(dataMode, phoneE164, switch (dataMode) {
      FeatureDataMode.mock => MockSettingsRepository(),
      FeatureDataMode.api => const UnavailableSettingsRepository(),
    });
    _repositories[locale] = selected;
  }

  return Theme(
    data: AppTheme.account(Theme.of(context)),
    child: BlocProvider(
      key: ObjectKey(selected.repository),
      create: (_) => SettingsCubit(
        selected!.repository,
        photoPicker: locator.isRegistered<ProfilePhotoPicker>()
            ? locator<ProfilePhotoPicker>()
            : null,
      )..load(),
      child: SettingsPage(
        navigation: navigation,
        onBack: onBack,
        locale: locale,
        logout: () async {
          await logout();
          resetSettingsFeatureSession(locale);
        },
        phoneE164: phoneE164,
      ),
    ),
  );
}
