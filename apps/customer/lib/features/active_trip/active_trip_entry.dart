import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:tam_customer/app/di/service_locator.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/features/active_trip/domain/active_trip_repository.dart';
import 'package:tam_customer/features/active_trip/presentation/bloc/active_trip_cubit.dart';
import 'package:tam_customer/features/active_trip/presentation/pages/active_trip_page.dart';

typedef ActiveTripParams = ({
  String? id,
  ActiveTripPolicy policy,
  DateTime Function()? now,
});
void registerActiveTripDependencies(GetIt dependencies) {
  dependencies.registerFactoryParam<
    ActiveTripCubit,
    ActiveTripRepository,
    ActiveTripParams
  >(
    (repository, params) => ActiveTripCubit(
      repository,
      tripId: params.id,
      policy: params.policy,
      now: params.now,
    ),
  );
}

Widget buildActiveTripFeature({
  required ActiveTripRepository repository,
  required CustomerNavigation navigation,
  required ActiveTripPolicy policy,
  String? tripId,
  DateTime Function()? now,
}) => BlocProvider(
  key: ValueKey((tripId, repository)),
  create: (_) => locator.isRegistered<ActiveTripCubit>()
      ? locator<ActiveTripCubit>(
          param1: repository,
          param2: (id: tripId, policy: policy, now: now),
        )
      : ActiveTripCubit(repository, tripId: tripId, policy: policy, now: now),
  child: ActiveTripPage(navigation: navigation),
);
