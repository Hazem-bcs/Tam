import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/maps/maps_entry.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';

import '../../domain/saved_address.dart';
import '../bloc/address_editor_cubit.dart';
import '../bloc/address_editor_state.dart';
import '../widgets/address_display.dart';
import '../widgets/address_editor_form.dart';
import '../widgets/address_location_picker.dart';
import '../widgets/address_map_preview.dart';

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

  Future<void> _chooseOnMap() async {
    final cubit = context.read<AddressEditorCubit>();
    final selected = await showMapLocationPicker(
      context,
      initial: cubit.state.location,
    );
    if (!mounted || selected == null) return;
    cubit.locationSelected(selected);
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
          // The ready editor uses its map as the hero and hosts back there.
          // Loading and failure states still expose an accessible back action.
          appBar: state.phase == AddressEditorPhase.loading ||
                  state.phase == AddressEditorPhase.error ||
                  state.phase == AddressEditorPhase.notFound
              ? AppBar(
                  title: Text(
                    context.read<AddressEditorCubit>().id == null
                        ? t.addressesAdd
                        : t.addressesEdit,
                  ),
                  leading: IconButton(
                    icon: const BackButtonIcon(),
                    onPressed: state.busy ? null : _back,
                    tooltip:
                        MaterialLocalizations.of(context).backButtonTooltip,
                  ),
                )
              : null,
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
    return LayoutBuilder(
      builder: (context, bounds) {
        final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
        final mapHeight = keyboardOpen
            ? (bounds.maxHeight * .25).clamp(64.0, 104.0)
            : (bounds.maxHeight * .46).clamp(145.0, 340.0);
        return Stack(
          children: [
            PositionedDirectional(
              top: 0,
              start: 0,
              end: 0,
              height: mapHeight,
              child: AddressMapPreview(
                location: state.location,
                onChooseLocation: state.locked ? null : _chooseOnMap,
                onBack: state.busy ? null : _back,
              ),
            ),
            Positioned.fill(
              top: mapHeight - AppSpacing.xl,
              child: Material(
                key: const Key('address-editor-sheet'),
                elevation: AppElevation.raised,
                color: Theme.of(context).colorScheme.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadii.sheet),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                        child: const SizedBox(width: 36, height: 4),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        key: const Key('address-editor-scroll'),
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppSpacing.xl,
                          AppSpacing.lg,
                          AppSpacing.xl,
                          AppSpacing.xl,
                        ),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: AddressEditorForm(
                          state: state,
                          nameController: _name,
                          onChooseLocation: _chooseLocation,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

}
