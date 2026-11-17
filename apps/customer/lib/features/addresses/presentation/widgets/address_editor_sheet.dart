import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';

import '../bloc/address_editor_cubit.dart';
import '../bloc/address_editor_state.dart';
import 'address_editor_form.dart';

/// Content-sized details with only two states: visible or folded away.
/// Unlike a tall draggable sheet, it cannot cover most of the map.
class AddressEditorSheet extends StatefulWidget {
  const AddressEditorSheet({
    super.key,
    required this.state,
    required this.nameController,
  });

  final AddressEditorState state;
  final TextEditingController nameController;

  @override
  State<AddressEditorSheet> createState() => _AddressEditorSheetState();
}

class _AddressEditorSheetState extends State<AddressEditorSheet> {
  bool _collapsed = false;
  double _dragDistance = 0;

  void _toggle() => setState(() => _collapsed = !_collapsed);

  void _dragEnded(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final collapse = _dragDistance > 40 || velocity > 100;
    final expand = _dragDistance < -40 || velocity < -100;
    if (collapse && !_collapsed) {
      setState(() => _collapsed = true);
    } else if (expand && _collapsed) {
      setState(() => _collapsed = false);
    }
    _dragDistance = 0;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    final editor = context.read<AddressEditorCubit>();
    final state = widget.state;
    final canSave =
        state.valid && !state.locked && (editor.id == null || state.dirty);

    return LayoutBuilder(
      builder: (context, size) => Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedSize(
          alignment: Alignment.bottomCenter,
          curve: AppMotion.easeOut,
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : AppMotion.medium,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              // Only limit overflow on small screens / with the keyboard.
              // Normal phones automatically shrink to the form's content.
              maxHeight: (size.maxHeight - 116).clamp(100.0, size.maxHeight),
            ),
            child: Material(
              key: const Key('address-sheet-surface'),
              elevation: AppElevation.raised,
              color: colors.surface,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadii.sheet),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                key: const Key('address-editor-sheet'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    key: const Key('address-sheet-toggle'),
                    behavior: HitTestBehavior.opaque,
                    onTap: _toggle,
                    onVerticalDragStart: (_) => _dragDistance = 0,
                    onVerticalDragUpdate: (details) =>
                        _dragDistance += details.primaryDelta ?? 0,
                    onVerticalDragEnd: _dragEnded,
                    child: Semantics(
                      button: true,
                      label: _collapsed
                          ? t.addressesManage
                          : MaterialLocalizations.of(
                              context,
                            ).closeButtonTooltip,
                      child: SizedBox(
                        width: double.infinity,
                        height: AppDimensions.minTapTarget,
                        child: Center(
                          child: DecoratedBox(
                            key: const Key('address-sheet-handle'),
                            decoration: BoxDecoration(
                              color: colors.outlineVariant,
                              borderRadius: BorderRadius.circular(AppRadii.sm),
                            ),
                            child: const SizedBox(width: 40, height: 4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!_collapsed)
                    Flexible(
                      fit: FlexFit.loose,
                      child: SingleChildScrollView(
                        key: const Key('address-editor-scroll'),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppSpacing.xl,
                          0,
                          AppSpacing.xl,
                          AppSpacing.lg,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AddressEditorForm(
                              state: state,
                              nameController: widget.nameController,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            TamButton.primary(
                              key: const Key('address-save'),
                              label: state.retryPending
                                  ? t.addressesRetry
                                  : t.addressesSave,
                              loadingLabel: t.addressesSaving,
                              isLoading:
                                  state.phase == AddressEditorPhase.saving,
                              onPressed: canSave ? editor.save : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
