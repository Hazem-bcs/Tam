import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/di/service_locator.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/core/config/app_config.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/features/addresses/addresses_entry.dart';
import 'package:tam_customer/features/addresses/domain/addresses_repository.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/data/repositories/unavailable_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/domain/repositories/ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/features/ride_request/presentation/pages/ride_request_page.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/trip.dart';

Widget buildRideRequestFeature(
  BuildContext context, {
  required CustomerNavigation navigation,
  required FeatureDataMode dataMode,
  required MockTripStore mockTrips,
  AddressesRepository? addresses,
  TripPrefill? prefill,
}) {
  final RideRequestRepository repository = switch (dataMode) {
    FeatureDataMode.mock => MockRideRequestRepository(
      trips: mockTrips,
      schedulePolicy: AppConfig.rideSchedulePolicy,
    ),
    FeatureDataMode.api => const UnavailableRideRequestRepository(),
  };
  // Entry is the composition boundary; do not create a TripStore here.
  return BlocProvider<RideDraftBloc>(
    create: (_) => locator.isRegistered<RideDraftBloc>()
        ? locator<RideDraftBloc>(param1: repository, param2: prefill)
        : RideDraftBloc(
            repository: repository,
            prefill: prefill,
            schedulePolicy: AppConfig.rideSchedulePolicy,
          ),
    child: RideRequestPage(
      navigation: navigation,
      savedAddressPickerBuilder: addresses == null
          ? null
          : (onSelected) => buildSavedAddressPicker(
              repository: addresses,
              onSelected: onSelected,
              onManage: navigation.openAddresses,
              compact: true,
            ),
    ),
  );
}
