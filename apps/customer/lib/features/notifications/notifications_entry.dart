import 'package:flutter/material.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/feature_unavailable_page.dart';

Widget buildNotificationsFeature(
  BuildContext context, {
  required CustomerNavigation navigation,
  required FeatureDataMode dataMode,
}) => FeatureUnavailablePage(
  title: AppLocalizations.of(context).navNotifications,
);
