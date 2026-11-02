import 'package:get_it/get_it.dart';
import 'package:mashwar_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';

void registerRideRequestDependencies(GetIt locator) {
  locator.registerFactory<RideDraftBloc>(RideDraftBloc.new);
}
