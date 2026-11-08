import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/di/service_locator.dart';
import 'package:tam_customer/shared/domain/trip.dart';

import 'domain/addresses_repository.dart';
import 'presentation/bloc/address_editor_cubit.dart';
import 'presentation/bloc/addresses_cubit.dart';
import 'presentation/pages/address_editor_page.dart';
import 'presentation/pages/addresses_page.dart';
import 'presentation/widgets/saved_address_picker.dart';

AddressesCubit _listCubit(AddressesRepository repository) =>
    locator.isRegistered<AddressesCubit>()
    ? locator<AddressesCubit>(param1: repository)
    : AddressesCubit(repository);

Widget buildAddressesFeature(
  BuildContext context, {
  required AddressesRepository repository,
  required VoidCallback onAdd,
  required ValueChanged<String> onEdit,
  required VoidCallback onBack,
}) => BlocProvider(
  create: (_) => _listCubit(repository)..load(),
  child: AddressesPage(onAdd: onAdd, onEdit: onEdit, onBack: onBack),
);

Widget buildAddressEditorFeature(
  BuildContext context, {
  required AddressesRepository repository,
  required AddressPlaceSearch places,
  required VoidCallback onBack,
  String? id,
}) => BlocProvider(
  key: ValueKey((id, repository)),
  create: (_) =>
      (locator.isRegistered<AddressEditorCubit>()
            ? locator<AddressEditorCubit>(
                param1: repository,
                param2: (places: places, id: id),
              )
            : AddressEditorCubit(repository, places, id: id))
        ..load(),
  child: AddressEditorPage(onBack: onBack),
);

Widget buildSavedAddressPicker({
  required AddressesRepository repository,
  required ValueChanged<TripLocation> onSelected,
  required VoidCallback onManage,
}) => BlocProvider(
  create: (_) => _listCubit(repository)..load(),
  child: SavedAddressPicker(onSelected: onSelected, onManage: onManage),
);
