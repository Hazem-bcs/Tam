import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

import '../../domain/saved_address.dart';
import '../bloc/address_editor_cubit.dart';
import '../bloc/address_editor_state.dart';
import 'address_display.dart';
import 'address_icon_picker.dart';
import 'address_location_summary.dart';

/// Only the form: map selection, sheet drag and save action stay outside it.
class AddressEditorForm extends StatelessWidget {
  const AddressEditorForm({
    super.key,
    required this.state,
    required this.nameController,
  });

  final AddressEditorState state;
  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddressEditorCubit>();
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final type = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AddressLocationSummary(hasLocation: state.location != null),
        if (state.validationAttempted && state.location == null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              t.addressesLocationError,
              style: type.bodySmall?.copyWith(color: colors.error),
            ),
          ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          key: const Key('address-name'),
          controller: nameController,
          enabled: !state.locked,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.sentences,
          // Keep the entered name normal, not an underlined text style.
          style: type.bodyMedium?.copyWith(
            color: colors.onSurface,
            decoration: TextDecoration.none,
          ),
          onChanged: cubit.nameChanged,
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
          decoration: InputDecoration(
            labelText: t.addressesName,
            hintText: t.addressesNameHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
              borderSide: BorderSide(color: colors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
              borderSide: BorderSide(color: colors.primary),
            ),
            errorText:
                state.name.isNotEmpty && !AddressInput.validName(state.name)
                ? t.addressesNameError(AddressInput.maxNameLength)
                : null,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AddressIconPicker(
          selected: state.icon,
          enabled: !state.locked,
          onSelected: cubit.iconChanged,
        ),
        if (state.retryPending || state.failure != null) ...[
          const SizedBox(height: AppSpacing.md),
          if (state.retryPending)
            Text(t.addressesRetryPending, style: type.bodySmall),
          if (state.failure != null)
            Semantics(
              liveRegion: true,
              child: Text(
                addressFailureMessage(t, state.failure),
                style: type.bodySmall?.copyWith(color: colors.error),
              ),
            ),
        ],
      ],
    );
  }
}
