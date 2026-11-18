import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/di/service_locator.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/core/config/app_config.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/features/active_trip/domain/active_trip_repository.dart';
import 'package:tam_customer/features/active_trip/presentation/bloc/active_trip_cubit.dart';
import 'package:tam_customer/features/addresses/addresses_entry.dart';
import 'package:tam_customer/features/addresses/domain/addresses_repository.dart';
import 'package:tam_customer/features/addresses/presentation/bloc/preferred_address_selection.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/data/repositories/unavailable_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/domain/repositories/ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/domain/ride_coupon_offer.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/features/ride_request/presentation/pages/ride_request_page.dart';
import 'package:tam_customer/features/settings/presentation/coupon_book_scope.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/trip.dart';

Widget buildRideRequestFeature(
  BuildContext context, {
  required CustomerNavigation navigation,
  required FeatureDataMode dataMode,
  required MockTripStore mockTrips,
  AddressesRepository? addresses,
  PreferredAddressSelection? preferredAddress,
  ActiveTripRepository? activeTrips,
  String? tripId,
  DateTime Function()? now,
  bool simulatedTracking = false,
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
  final book = dataMode == FeatureDataMode.mock
      ? CouponBookScope.maybeOf(context)
      : null;
  final draft = BlocProvider<RideDraftBloc>(
    create: (_) => locator.isRegistered<RideDraftBloc>()
        ? locator<RideDraftBloc>(param1: repository, param2: prefill)
        : RideDraftBloc(
            repository: repository,
            prefill: prefill,
            schedulePolicy: AppConfig.rideSchedulePolicy,
          ),
    child: ListenableBuilder(
      listenable: book ?? const AlwaysStoppedAnimation(0),
      builder: (context, _) => RideRequestPage(
        couponOffers:
            [
                  for (final coupon in book?.coupons ?? [])
                    RideCouponOffer(
                      code: coupon.code,
                      percent: coupon.percent,
                      enabled: coupon.isAvailable,
                      expiresAt: coupon.expiresAt,
                      remainingTrips: coupon.remainingTrips,
                    ),
                ]
                .where(
                  (offer) => offer.availableAt(now?.call() ?? DateTime.now()),
                )
                .toList(),
        onActivateCoupon: (code) {
          book?.add(code);
        },
        navigation: navigation,
        hasActiveTracking: activeTrips != null,
        simulatedTracking: simulatedTracking,
        savedAddressPickerBuilder: addresses == null
            ? null
            : (onSelected) => buildSavedAddressPicker(
                repository: addresses,
                onSelected: onSelected,
                onManage: navigation.openAddresses,
                compact: true,
                preferredAddress: preferredAddress,
              ),
      ),
    ),
  );
  return activeTrips == null
      ? draft
      : BlocProvider<ActiveTripCubit>(
          create: (_) => ActiveTripCubit(
            activeTrips,
            tripId: tripId,
            policy: AppConfig.activeTripPolicy,
            now: now,
          ),
          child: draft,
        );
}
