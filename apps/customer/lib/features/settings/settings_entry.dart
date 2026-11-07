import 'package:flutter/material.dart';
import 'package:tam_customer/app/locale/app_locale_controller.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/feature_unavailable_page.dart';

Widget buildSettingsFeature(
  BuildContext context, {
  required CustomerNavigation navigation,
  required FeatureDataMode dataMode,
  required AppLocaleController locale,
  required Future<void> Function() logout,
  String? phoneE164,
}) => FeatureUnavailablePage(title: AppLocalizations.of(context).navSettings);
