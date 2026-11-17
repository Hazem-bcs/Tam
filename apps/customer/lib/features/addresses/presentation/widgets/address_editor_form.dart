import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_text_field.dart';

import '../../domain/saved_address.dart';
import '../bloc/address_editor_cubit.dart';
import '../bloc/address_editor_state.dart';
import 'address_display.dart';
import 'address_icon_picker.dart';
import 'address_location_summary.dart';

/// The form lives in the sheet while the map/navigation stay in the page.
class AddressEditorForm extends StatelessWidget {
  const AddressEditorForm({
    super.key,
    required this.state,
    required this.nameController,
    required this.onChooseLocation,
  });

  final AddressEditorState state;
  final TextEditingController nameController;
  final VoidCallback onChooseLocation;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddressEditorCubit>();
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final type = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          cubit.id == null ? t.addressesSave : t.addressesEdit,
          style: type.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
        AddressLocationSummary(
          locationLabel: state.location?.label,
          onTap: state.locked ? null : onChooseLocation,
        ),
        if (state.validationAttempted && state.location == null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              t.addressesLocationError,
              style: type.bodySmall?.copyWith(color: colors.error),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        TamTextField(
          key: const Key('address-name'),
          labelText: t.addressesName,
          hintText: t.addressesNameHint,
          controller: nameController,
          enabled: !state.locked,
          textInputAction: TextInputAction.done,
          onChanged: cubit.nameChanged,
          errorText:
              state.validationAttempted && !AddressInput.validName(state.name)
              ? t.addressesNameError(AddressInput.maxNameLength)
              : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        AddressIconPicker(
          selected: state.icon,
          enabled: !state.locked,
          onSelected: cubit.iconChanged,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (state.retryPending) ...[
          Text(t.addressesRetryPending),
          const SizedBox(height: AppSpacing.md),
        ],
        if (state.failure != null)
          Semantics(
            liveRegion: true,
            child: Text(
              addressFailureMessage(t, state.failure),
              style: type.bodyMedium?.copyWith(color: colors.error),
            ),
          ),
      ],
    );
  }
}
