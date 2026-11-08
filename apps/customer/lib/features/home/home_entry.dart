import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tam_customer/features/home/data/mock/mock_home_repository.dart';
import 'package:tam_customer/features/home/data/unavailable_home_repository.dart';
import 'package:tam_customer/features/home/domain/repositories/home_repository.dart';
import 'package:tam_customer/features/home/presentation/bloc/home_cubit.dart';
import 'package:tam_customer/features/home/presentation/bloc/home_unread_count_cubit.dart';
import 'package:tam_customer/features/home/presentation/pages/home_page.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_notifications_button.dart';
import 'package:tam_customer/features/notifications/domain/notifications_repository.dart';

Widget buildHomeFeature(
  BuildContext context, {
  required CustomerNavigation navigation,
  required FeatureDataMode dataMode,
  required Future<void> Function() logout,
  String? phoneE164,
  NotificationsUnreadCountSource? unreadCountSource,
}) {
  final HomeRepository repository = switch (dataMode) {
    FeatureDataMode.mock => const MockHomeRepository(),
    FeatureDataMode.api => const UnavailableHomeRepository(),
  };
  final status = context.watch<AuthCubit>().state.status;
  return BlocProvider(
    create: (_) => HomeCubit(repository)..load(),
    child: HomePage(
      navigation: navigation,
      phoneE164: phoneE164,
      isAuthenticated: status == AuthStatus.authenticated,
      isGuest: status == AuthStatus.guest,
      logout: logout,
      notificationsButton: unreadCountSource == null
          ? null
          : BlocProvider(
              create: (_) => HomeUnreadCountCubit(unreadCountSource)..load(),
              child: HomeNotificationsButton(
                onPressed: navigation.openNotifications,
              ),
            ),
    ),
  );
}
