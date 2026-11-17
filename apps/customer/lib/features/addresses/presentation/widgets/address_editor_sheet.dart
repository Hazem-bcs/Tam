import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';

import '../bloc/address_editor_cubit.dart';
import '../bloc/address_editor_state.dart';
import 'address_editor_form.dart';

/// The map remains mounted behind the sheet while the user resizes it.
class AddressEditorSheet extends StatelessWidget {
  const AddressEditorSheet({
    super.key,
    required this.state,
    required this.nameController,
  });

  final AddressEditorState state;
  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    final editor = context.read<AddressEditorCubit>();
    final canSave =
        state.valid && !state.locked && (editor.id == null || state.dirty);

    return DraggableScrollableSheet(
      key: const Key('address-editor-sheet'),
      expand: true,
      initialChildSize: .52,
      minChildSize: .16,
      maxChildSize: .90,
      snap: true,
      snapSizes: const [.52],
      builder: (context, scrollController) => Material(
        key: const Key('address-sheet-surface'),
        elevation: AppElevation.raised,
        color: colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.sheet),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          key: const Key('address-editor-scroll'),
          controller: scrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Semantics(
                  label: t.addressesAdd,
                  child: Container(
                    key: const Key('address-sheet-handle'),
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colors.outlineVariant,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                  ),
                ),
              ),
              AddressEditorForm(state: state, nameController: nameController),
              const SizedBox(height: AppSpacing.xl),
              TamButton.primary(
                key: const Key('address-save'),
                label: state.retryPending ? t.addressesRetry : t.addressesSave,
                loadingLabel: t.addressesSaving,
                isLoading: state.phase == AddressEditorPhase.saving,
                onPressed: canSave ? editor.save : null,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}
