import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:tam_customer/app/di/service_locator.dart';
import 'domain/driver_contact_repository.dart';
import 'presentation/bloc/driver_contact_cubit.dart';
import 'presentation/pages/driver_contact_page.dart';
export 'domain/driver_contact_repository.dart';

typedef DriverContactParams = ({
  String tripId,
  String driverId,
  PhoneDialer dialer,
  DateTime Function() now,
});
void registerDriverContactDependencies(GetIt dependencies) {
  dependencies.registerFactoryParam<
    DriverContactCubit,
    DriverContactRepository,
    DriverContactParams
  >(
    (repository, params) => DriverContactCubit(
      repository,
      params.dialer,
      tripId: params.tripId,
      driverId: params.driverId,
      now: params.now,
    ),
  );
}

Widget buildDriverContactFeature({
  required DriverContactRepository repository,
  required PhoneDialer dialer,
  required String tripId,
  required String driverId,
  required DateTime Function() now,
  required VoidCallback onBack,
}) => BlocProvider(
  key: ValueKey((repository, tripId, driverId)),
  create: (_) => locator.isRegistered<DriverContactCubit>()
      ? locator<DriverContactCubit>(
          param1: repository,
          param2: (
            tripId: tripId,
            driverId: driverId,
            dialer: dialer,
            now: now,
          ),
        )
      : DriverContactCubit(
          repository,
          dialer,
          tripId: tripId,
          driverId: driverId,
          now: now,
        ),
  child: DriverContactPage(onBack: onBack),
);
