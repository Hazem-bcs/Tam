import 'package:get_it/get_it.dart';
import 'package:tam_customer/core/config/app_config.dart';
import 'package:tam_customer/features/ride_request/domain/repositories/ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/shared/domain/trip.dart';

void registerRideRequestDependencies(GetIt locator) {
  locator
      .registerFactoryParam<RideDraftBloc, RideRequestRepository, TripPrefill?>(
        (repository, prefill) => RideDraftBloc(
          repository: repository,
          prefill: prefill,
          schedulePolicy: AppConfig.rideSchedulePolicy,
        ),
      );
}
