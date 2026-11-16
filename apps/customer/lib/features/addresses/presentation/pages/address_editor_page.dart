import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';
import 'package:tam_customer/shared/widgets/tam_text_field.dart';

import '../../domain/saved_address.dart';
import '../bloc/address_editor_cubit.dart';
import '../bloc/address_editor_state.dart';
import '../widgets/address_display.dart';
import '../widgets/address_icon_picker.dart';
import '../widgets/address_location_picker.dart';
import '../widgets/address_location_summary.dart';

class AddressEditorPage extends StatefulWidget {
  const AddressEditorPage({super.key, required this.onBack});
  final VoidCallback onBack;
  @override
  State<AddressEditorPage> createState() => _AddressEditorPageState();
}

class _AddressEditorPageState extends State<AddressEditorPage> {
  final _name = TextEditingController();
  bool _initialized = false, _allowPop = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AddressEditorCubit>().state;
    if (state.phase == AddressEditorPhase.ready) {
      _name.text = state.name;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _back() async {
    final state = context.read<AddressEditorCubit>().state;
    if (state.busy) return;
    if (state.dirty) {
      final t = AppLocalizations.of(context);
      final discard = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(t.addressesDiscardTitle),
          content: Text(t.addressesDiscardBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(t.addressesKeepEditing),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(t.addressesDiscard),
            ),
          ],
        ),
      );
      if (discard != true || !mounted) return;
    }
    if (!mounted) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.pop(context);
      } else {
        widget.onBack();
      }
    });
  }

  Future<void> _chooseLocation() async {
    final cubit = context.read<AddressEditorCubit>();
    unawaited(cubit.search(''));
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: FractionallySizedBox(
          heightFactor: 0.85,
          child: BlocProvider.value(
            value: cubit,
            child: const AddressLocationPicker(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocConsumer<AddressEditorCubit, AddressEditorState>(
      listener: (context, state) {
        if (state.phase == AddressEditorPhase.ready && !_initialized) {
          _initialized = true;
          _name.text = state.name;
        }
        if (state.phase == AddressEditorPhase.saved) {
          if (Navigator.of(context).canPop()) {
            Navigator.pop(context, state.original);
          } else {
            widget.onBack();
          }
        }
      },
      builder: (context, state) => PopScope(
        canPop:
            _allowPop ||
            state.phase == AddressEditorPhase.saved ||
            (!state.dirty && !state.busy),
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _back();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              context.read<AddressEditorCubit>().id == null
                  ? t.addressesAdd
                  : t.addressesEdit,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            leading: IconButton(
              icon: const BackButtonIcon(),
              onPressed: state.busy ? null : _back,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            ),
          ),
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: _body(context, state),
              ),
            ),
          ),
          bottomNavigationBar:
              (state.phase == AddressEditorPhase.ready ||
                  state.phase == AddressEditorPhase.saving)
              ? SafeArea(
                  top: false,
                  child: Center(
                    heightFactor: 1,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppSpacing.xl,
                          AppSpacing.sm,
                          AppSpacing.xl,
                          AppSpacing.lg,
                        ),
                        child: TamButton.primary(
                          key: const Key('address-save'),
                          label: state.retryPending
                              ? t.addressesRetry
                              : t.addressesSave,
                          loadingLabel: t.addressesSaving,
                          isLoading: state.phase == AddressEditorPhase.saving,
                          onPressed:
                              state.busy ||
                                  (!state.dirty &&
                                      context.read<AddressEditorCubit>().id !=
                                          null)
                              ? null
                              : context.read<AddressEditorCubit>().save,
                        ),
                      ),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _body(BuildContext context, AddressEditorState state) {
    final t = AppLocalizations.of(context);
    final cubit = context.read<AddressEditorCubit>();
    if (state.phase == AddressEditorPhase.loading) {
      return Center(
        child: TamLoadingIndicator(semanticLabel: t.addressesLoading),
      );
    }
    if (state.phase == AddressEditorPhase.notFound ||
        state.phase == AddressEditorPhase.error) {
      return SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          children: [
            Text(addressFailureMessage(t, state.failure)),
            TamButton.secondary(
              label: state.phase == AddressEditorPhase.notFound
                  ? t.addressesTitle
                  : t.addressesRetry,
              onPressed: state.phase == AddressEditorPhase.notFound
                  ? widget.onBack
                  : cubit.load,
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      key: const Key('address-editor-scroll'),
      padding: AppSpacing.pagePadding,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AddressLocationSummary(
            locationLabel: state.location?.label,
            onTap: state.locked ? null : _chooseLocation,
          ),
          if (state.validationAttempted && state.location == null)
            Text(
              t.addressesLocationError,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const SizedBox(height: AppSpacing.xl),
          TamTextField(
            key: const Key('address-name'),
            labelText: t.addressesName,
            hintText: t.addressesNameHint,
            controller: _name,
            enabled: !state.locked,
            textInputAction: TextInputAction.done,
            onChanged: cubit.nameChanged,
            errorText:
                state.validationAttempted && !AddressInput.validName(state.name)
                ? t.addressesNameError(AddressInput.maxNameLength)
                : null,
          ),
          const SizedBox(height: AppSpacing.xl),
          AddressIconPicker(
            selected: state.icon,
            enabled: !state.locked,
            onSelected: cubit.iconChanged,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (state.retryPending) ...[
            Text(t.addressesRetryPending),
            const SizedBox(height: AppSpacing.md),
          ],
          if (state.failure != null) ...[
            Semantics(
              liveRegion: true,
              child: Text(
                addressFailureMessage(t, state.failure),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}
