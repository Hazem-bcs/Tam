import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/maps/maps_entry.dart';
import 'package:tam_customer/features/maps/presentation/maps_scope.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';
import 'package:tam_customer/shared/widgets/tam_text_field.dart';

import '../bloc/address_editor_cubit.dart';
import '../bloc/address_editor_state.dart';
import 'address_display.dart';

class AddressLocationPicker extends StatefulWidget {
  const AddressLocationPicker({super.key});
  @override
  State<AddressLocationPicker> createState() => _AddressLocationPickerState();
}

class _AddressLocationPickerState extends State<AddressLocationPicker> {
  final _query = TextEditingController();
  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final cubit = context.read<AddressEditorCubit>();
    return BlocBuilder<AddressEditorCubit, AddressEditorState>(
      builder: (context, state) => ListView(
        padding: AppSpacing.pagePadding,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          Text(
            t.addressesChooseLocation,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          if (MapsScope.maybeOf(context) != null) ...[
            TamButton.secondary(
              key: const Key('address-pick-on-map'),
              label: t.mapsPickLocation,
              icon: Icons.map_outlined,
              onPressed: () async {
                final selected = await showMapLocationPicker(
                  context,
                  initial: state.location,
                );
                if (!context.mounted || selected == null) return;
                cubit.locationSelected(selected);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          TamTextField(
            key: const Key('address-location-search'),
            labelText: t.addressesSearch,
            controller: _query,
            prefixIcon: const Icon(Icons.search),
            onChanged: cubit.search,
          ),
          const SizedBox(height: AppSpacing.md),
          if (state.searching)
            Center(
              child: TamLoadingIndicator(semanticLabel: t.addressesLoading),
            )
          else if (state.searchFailure != null) ...[
            Text(addressFailureMessage(t, state.searchFailure)),
            TamButton.secondary(
              label: t.addressesRetry,
              onPressed: () => cubit.search(_query.text),
            ),
          ] else if (state.suggestions.isEmpty)
            Text(t.addressesNoPlaces)
          else
            for (final location in state.suggestions)
              ListTile(
                leading: const Icon(Icons.place_outlined),
                title: Text(location.label),
                onTap: () {
                  cubit.locationSelected(location);
                  Navigator.pop(context);
                },
              ),
        ],
      ),
    );
  }
}
