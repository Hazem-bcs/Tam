import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';

import 'data/mock/mock_notifications_repository.dart';
import 'data/unavailable_notifications_repository.dart';
import 'domain/notifications_repository.dart';
import 'presentation/bloc/notifications_cubit.dart';
import 'presentation/pages/notifications_page.dart';

/// Feature-owned lifetime until TamApp can own this repository in the common DI
/// root (supervisor integration request in HANDOFF). Never recreate per page.
final MockNotificationsRepository _mockInbox = MockNotificationsRepository();
const UnavailableNotificationsRepository _unavailableInbox =
    UnavailableNotificationsRepository();

NotificationsRepository _repositoryFor(FeatureDataMode mode) =>
    mode == FeatureDataMode.mock ? _mockInbox : _unavailableInbox;

/// Supervisor badge seam. One repository, no duplicate counter or fixed badge.
NotificationsUnreadCountSource notificationsUnreadCountSourceFor(
  FeatureDataMode mode,
) => _repositoryFor(mode);

Widget buildNotificationsFeature(
  BuildContext context, {
  required CustomerNavigation navigation,
  required FeatureDataMode dataMode,
}) => BlocProvider(
  create: (_) => NotificationsCubit(_repositoryFor(dataMode))..load(),
  child: NotificationsPage(navigation: navigation),
);
