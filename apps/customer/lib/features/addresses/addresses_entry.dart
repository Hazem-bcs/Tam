import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/di/service_locator.dart';
import 'package:tam_customer/shared/domain/trip.dart';

import 'domain/addresses_repository.dart';
import 'presentation/bloc/address_editor_cubit.dart';
import 'presentation/bloc/addresses_cubit.dart';
import 'presentation/bloc/preferred_address_selection.dart';
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
  PreferredAddressSelection? preferredAddress,
}) => MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => _listCubit(repository)..load()),
    _selectionProvider(preferredAddress),
  ],
  child: AddressesPage(onAdd: onAdd, onEdit: onEdit, onBack: onBack),
);

BlocProvider<PreferredAddressSelection> _selectionProvider(
  PreferredAddressSelection? selection,
) => selection != null
    ? BlocProvider.value(value: selection)
    : locator.isRegistered<PreferredAddressSelection>()
    ? BlocProvider.value(value: locator<PreferredAddressSelection>())
    : BlocProvider(create: (_) => PreferredAddressSelection());

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
  bool compact = false,
  PreferredAddressSelection? preferredAddress,
}) => MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => _listCubit(repository)..load()),
    _selectionProvider(preferredAddress),
  ],
  child: SavedAddressPicker(
    onSelected: onSelected,
    onManage: onManage,
    compact: compact,
  ),
);
