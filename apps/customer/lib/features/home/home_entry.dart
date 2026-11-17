import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/features/addresses/domain/addresses_repository.dart';
import 'package:tam_customer/features/addresses/domain/saved_address.dart';
import 'package:tam_customer/features/addresses/presentation/bloc/addresses_cubit.dart';
import 'package:tam_customer/features/addresses/presentation/bloc/addresses_state.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tam_customer/features/home/data/mock/mock_home_repository.dart';
import 'package:tam_customer/features/home/data/unavailable_home_repository.dart';
import 'package:tam_customer/features/home/domain/repositories/home_repository.dart';
import 'package:tam_customer/features/home/presentation/bloc/home_cubit.dart';
import 'package:tam_customer/features/home/presentation/bloc/home_unread_count_cubit.dart';
import 'package:tam_customer/features/home/presentation/pages/home_page.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_address_bar.dart';
import 'package:tam_customer/features/home/presentation/widgets/home_notifications_button.dart';
import 'package:tam_customer/features/notifications/domain/notifications_repository.dart';

Widget buildHomeFeature(
  BuildContext context, {
  required CustomerNavigation navigation,
  required FeatureDataMode dataMode,
  required Future<void> Function() logout,
  String? phoneE164,
  NotificationsUnreadCountSource? unreadCountSource,
  AddressesRepository? addressesRepository,
}) {
  final HomeRepository repository = switch (dataMode) {
    FeatureDataMode.mock => const MockHomeRepository(),
    FeatureDataMode.api => const UnavailableHomeRepository(),
  };
  final status = context.watch<AuthCubit>().state.status;
  Widget page({Widget? addressBar}) => HomePage(
    navigation: navigation,
    phoneE164: phoneE164,
    isAuthenticated: status == AuthStatus.authenticated,
    isGuest: status == AuthStatus.guest,
    logout: logout,
    addressBar: addressBar,
    notificationsButton: unreadCountSource == null
        ? null
        : BlocProvider(
            create: (_) => HomeUnreadCountCubit(unreadCountSource)..load(),
            child: HomeNotificationsButton(
              onPressed: navigation.openNotifications,
            ),
          ),
  );
  return BlocProvider(
    create: (_) => HomeCubit(repository)..load(),
    child: addressesRepository == null
        ? page()
        : BlocProvider(
            key: ValueKey((addressesRepository, status, phoneE164)),
            create: (_) => AddressesCubit(addressesRepository)..load(),
            child: BlocBuilder<AddressesCubit, AddressesState>(
              builder: (context, state) {
                final address =
                    state.items
                        .where((item) => item.input.icon == AddressIcon.home)
                        .firstOrNull ??
                    state.items.firstOrNull;
                return page(
                  addressBar: HomeAddressBar(
                    label: address?.input.location.label,
                    loading: state.status == AddressesStatus.loading,
                    onManage: navigation.openAddresses,
                  ),
                );
              },
            ),
          ),
  );
}
