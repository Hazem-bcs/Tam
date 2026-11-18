import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/features/addresses/presentation/bloc/addresses_cubit.dart';
import 'package:tam_customer/features/addresses/presentation/bloc/addresses_state.dart';
import 'package:tam_customer/features/addresses/presentation/bloc/preferred_address_selection.dart';
import 'package:tam_customer/features/addresses/presentation/widgets/address_display.dart';
import 'package:tam_customer/features/addresses/presentation/widgets/address_selection_sheet.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

import 'home_address_bar.dart';

/// Shows the session's confirmed saved address, not the device's GPS fix.
class HomePreferredAddressBar extends StatelessWidget {
  const HomePreferredAddressBar({super.key, required this.onManage});
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddressesCubit, AddressesState>(
      listenWhen: (_, state) =>
          state.status == AddressesStatus.ready && !state.refreshing,
      listener: (context, state) => context
          .read<PreferredAddressSelection>()
          .clearIfMissing(state.items.map((item) => item.id)),
      builder: (context, state) {
        final preferredId = context.watch<PreferredAddressSelection>().state;
        final address = state.items
            .where((item) => item.id == preferredId)
            .firstOrNull;
        final label = state.status == AddressesStatus.error
            ? addressFailureMessage(AppLocalizations.of(context), state.failure)
            : address?.input.location.label;
        return HomeAddressBar(
          label: label,
          loading: state.status == AddressesStatus.loading,
          onManage: () =>
              showAddressSelectionSheet(context, onManage: onManage),
        );
      },
    );
  }
}
