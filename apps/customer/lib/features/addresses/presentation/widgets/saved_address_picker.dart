import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';
import '../bloc/addresses_cubit.dart';
import '../bloc/addresses_state.dart';
import 'address_display.dart';

class SavedAddressPicker extends StatelessWidget {
  const SavedAddressPicker({
    super.key,
    required this.onSelected,
    required this.onManage,
  });
  final ValueChanged<TripLocation> onSelected;
  final VoidCallback onManage;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocBuilder<AddressesCubit, AddressesState>(
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.status == AddressesStatus.loading)
            Center(
              child: TamLoadingIndicator(semanticLabel: t.addressesLoading),
            ),
          if (state.failure != null) ...[
            Text(addressFailureMessage(t, state.failure)),
            TamButton.secondary(
              label: t.addressesRetry,
              onPressed: context.read<AddressesCubit>().load,
            ),
          ],
          if (state.status == AddressesStatus.ready && state.items.isEmpty)
            Text(t.addressesEmptyBody),
          for (final item in state.items)
            ListTile(
              key: Key('saved-address-${item.id}'),
              leading: Icon(addressIcon(item.input.icon)),
              title: Text(item.input.name),
              subtitle: Text(item.input.location.label),
              onTap: () => onSelected(item.input.location),
            ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: onManage,
            icon: const Icon(Icons.edit_location_alt_outlined),
            label: Text(t.addressesManage),
          ),
        ],
      ),
    );
  }
}
