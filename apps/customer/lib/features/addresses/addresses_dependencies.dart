import 'package:get_it/get_it.dart';

import 'domain/addresses_repository.dart';
import 'presentation/bloc/address_editor_cubit.dart';
import 'presentation/bloc/addresses_cubit.dart';
import 'presentation/bloc/preferred_address_selection.dart';

typedef AddressEditorParams = ({AddressPlaceSearch places, String? id});

void registerAddressesDependencies(GetIt locator) {
  locator.registerLazySingleton<PreferredAddressSelection>(
    PreferredAddressSelection.new,
  );
  locator.registerFactoryParam<AddressesCubit, AddressesRepository, void>(
    (repository, _) => AddressesCubit(repository),
  );
  locator.registerFactoryParam<
    AddressEditorCubit,
    AddressesRepository,
    AddressEditorParams
  >(
    (repository, params) =>
        AddressEditorCubit(repository, params.places, id: params.id),
  );
}
