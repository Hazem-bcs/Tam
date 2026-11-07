import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/locale/app_locale_controller.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/features/settings/data/api/unavailable_settings_repository.dart';
import 'package:tam_customer/features/settings/data/mock/mock_settings_repository.dart';
import 'package:tam_customer/features/settings/domain/settings_repository.dart';
import 'package:tam_customer/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:tam_customer/features/settings/presentation/pages/settings_page.dart';

/// Feature-scoped, weakly keyed per application locale controller.
/// Saved mock edits survive route re-entry, but not app process restart.
final Expando<_RepositorySelection> _repositories =
    Expando<_RepositorySelection>('settings repositories');

final class _RepositorySelection {
  const _RepositorySelection(this.mode, this.repository);
  final FeatureDataMode mode;
  final SettingsRepository repository;
}

Widget buildSettingsFeature(
  BuildContext context, {
  required CustomerNavigation navigation,
  required FeatureDataMode dataMode,
  required AppLocaleController locale,
  required Future<void> Function() logout,
  String? phoneE164,
}) {
  var selected = _repositories[locale];
  if (selected == null || selected.mode != dataMode) {
    selected = _RepositorySelection(dataMode, switch (dataMode) {
      FeatureDataMode.mock => MockSettingsRepository(),
      FeatureDataMode.api => const UnavailableSettingsRepository(),
    });
    _repositories[locale] = selected;
  }

  return BlocProvider(
    create: (_) => SettingsCubit(selected!.repository)..load(),
    child: SettingsPage(
      navigation: navigation,
      locale: locale,
      logout: logout,
      phoneE164: phoneE164,
    ),
  );
}
