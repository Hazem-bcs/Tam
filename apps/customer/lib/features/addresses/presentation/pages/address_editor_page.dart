import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/maps/presentation/maps_scope.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';

import '../bloc/address_editor_cubit.dart';
import '../bloc/address_editor_state.dart';
import '../bloc/address_map_selection_cubit.dart';
import '../widgets/address_display.dart';
import '../widgets/address_editor_sheet.dart';
import '../widgets/address_map_preview.dart';

/// One screen: a real interactive map and a draggable details sheet.
class AddressEditorPage extends StatefulWidget {
  const AddressEditorPage({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  State<AddressEditorPage> createState() => _AddressEditorPageState();
}

class _AddressEditorPageState extends State<AddressEditorPage> {
  final _name = TextEditingController();
  AddressMapSelectionCubit? _mapSelection;
  bool _initialized = false;
  bool _allowPop = false;

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
    if (_mapSelection != null) unawaited(_mapSelection!.close());
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
          appBar:
              state.phase == AddressEditorPhase.loading ||
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
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).backButtonTooltip,
                  ),
                )
              : null,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 840),
                child: _body(context, state),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, AddressEditorState state) {
    final t = AppLocalizations.of(context);
    final editor = context.read<AddressEditorCubit>();
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
                  : editor.load,
            ),
          ],
        ),
      );
    }

    final dependencies = MapsScope.maybeOf(context);
    if (dependencies == null) {
      return Stack(
        children: [
          Positioned.fill(
            child: AddressMapPreview(
              location: state.location,
              onSelected: null,
              onBack: state.busy ? null : _back,
              onLocate: null,
            ),
          ),
          AddressEditorSheet(state: state, nameController: _name),
        ],
      );
    }

    _mapSelection ??= AddressMapSelectionCubit(
      repository: dependencies.repository,
      deviceLocation: dependencies.deviceLocation,
      reverseAvailable: dependencies.configuration.hasServices,
      language: Localizations.localeOf(context).languageCode,
      initialLocation: state.location,
    );

    return BlocProvider<AddressMapSelectionCubit>.value(
      value: _mapSelection!,
      child: BlocListener<AddressMapSelectionCubit, AddressMapSelectionState>(
        listenWhen: (previous, current) =>
            previous.location != current.location && current.location != null,
        listener: (context, mapState) {
          if (editor.state.location != mapState.location) {
            editor.locationSelected(mapState.location!);
          }
        },
        child: BlocBuilder<AddressMapSelectionCubit, AddressMapSelectionState>(
          builder: (context, mapState) => Stack(
            children: [
              Positioned.fill(
                child: AddressMapPreview(
                  location: mapState.location,
                  onSelected: state.locked ? null : _mapSelection!.select,
                  onBack: state.busy ? null : _back,
                  onLocate: state.locked || mapState.locating
                      ? null
                      : _mapSelection!.locate,
                  locating: mapState.locating,
                ),
              ),
              AddressEditorSheet(state: state, nameController: _name),
            ],
          ),
        ),
      ),
    );
  }
}
