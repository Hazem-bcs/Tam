import 'package:flutter/material.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/features/home/presentation/pages/home_page.dart';

Widget buildHomeFeature(
  BuildContext context, {
  required CustomerNavigation navigation,
  required FeatureDataMode dataMode,
  required Future<void> Function() logout,
  String? phoneE164,
}) => const HomePage();
