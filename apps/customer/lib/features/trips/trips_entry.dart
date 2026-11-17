import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/features/completion/domain/completion_repository.dart';
import 'package:tam_customer/features/completion/presentation/widgets/inline_trip_rating.dart';
import 'package:tam_customer/features/trips/data/api/unavailable_trips_repository.dart';
import 'package:tam_customer/features/trips/data/mock/mock_trips_repository.dart';
import 'package:tam_customer/features/trips/domain/trips_repository.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trip_details_cubit.dart';
import 'package:tam_customer/features/trips/presentation/bloc/trips_list_cubit.dart';
import 'package:tam_customer/features/trips/presentation/pages/trip_details_page.dart';
import 'package:tam_customer/features/trips/presentation/pages/trips_list_page.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';

/// The feature composition root is the only place choosing mock versus API.
Widget buildTripsFeature(
  BuildContext context, {
  required CustomerNavigation navigation,
  required FeatureDataMode dataMode,
  required MockTripStore mockTrips,
  String? tripId,
  CompletionRepository? completionRepository,
}) {
  final TripsRepository repository = switch (dataMode) {
    FeatureDataMode.mock => MockTripsRepository(mockTrips),
    FeatureDataMode.api => const UnavailableTripsRepository(),
  };
  return RepositoryProvider<TripsRepository>.value(
    value: repository,
    child: tripId == null
        ? BlocProvider(
            create: (_) => TripsListCubit(repository),
            child: TripsListPage(navigation: navigation),
          )
        : BlocProvider(
            key: ValueKey(tripId),
            create: (_) => TripDetailsCubit(repository, tripId),
            child: TripDetailsPage(
              navigation: navigation,
              ratingBuilder: completionRepository == null
                  ? null
                  : (id) => InlineTripRating(
                      repository: completionRepository,
                      tripId: id,
                      onSupport: () => navigation.openSupport(tripId: id),
                    ),
            ),
          ),
  );
}
