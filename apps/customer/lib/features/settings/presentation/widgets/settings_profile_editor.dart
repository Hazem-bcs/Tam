import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:tam_customer/features/settings/presentation/bloc/settings_state.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_text_field.dart';

class SettingsProfileEditor extends StatefulWidget {
  const SettingsProfileEditor({super.key});

  @override
  State<SettingsProfileEditor> createState() => _SettingsProfileEditorState();
}

class _SettingsProfileEditorState extends State<SettingsProfileEditor> {
  late final TextEditingController _name;
  Uint8List? _photo;
  bool _picking = false;
  bool _photoError = false;
  bool _allowClose = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(
      text: context.read<SettingsCubit>().state.draftName,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    final cubit = context.read<SettingsCubit>();
    if (_picking || cubit.state.isBusy) return;
    final t = AppLocalizations.of(context);
    if (cubit.state.hasUnsavedChanges || _photo != null) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(t.settingsUnsavedTitle),
          content: Text(t.settingsUnsavedMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t.settingsKeepEditing),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(t.settingsDiscard),
            ),
          ],
        ),
      );
      if (discard != true || !mounted) return;
    }
    cubit.discardChanges();
    await _finish();
  }

  Future<void> _finish() async {
    setState(() => _allowClose = true);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickPhoto() async {
    setState(() {
      _picking = true;
      _photoError = false;
    });
    try {
      final photo = await context.read<SettingsCubit>().pickPhoto();
      if (mounted && photo != null) setState(() => _photo = photo);
    } catch (_) {
      if (mounted) setState(() => _photoError = true);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final saved = await context.read<SettingsCubit>().saveName(
      avatarBytes: _photo,
    );
    if (saved && mounted) await _finish();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final busy = state.isBusy || _picking;
        final bytes = _photo ?? state.profile?.avatarBytes;
        return PopScope(
          canPop: _allowClose,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _close();
          },
          child: SingleChildScrollView(
            padding: EdgeInsetsDirectional.fromSTEB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.settingsProfileEditorTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: t.settingsCancel,
                      onPressed: busy ? null : _close,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Semantics(
                    button: true,
                    label: t.settingsChoosePhoto,
                    child: InkWell(
                      key: const Key('settings-profile-photo'),
                      onTap: busy ? null : _pickPhoto,
                      borderRadius: BorderRadius.circular(60),
                      child: Stack(
                        children: [
                          Container(
                            width: 104,
                            height: 104,
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: bytes == null
                                  ? Padding(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.lg,
                                      ),
                                      child: Image.asset(
                                        'assets/notifications/account.webp',
                                        excludeFromSemantics: true,
                                      ),
                                    )
                                  : Image.memory(
                                      bytes,
                                      fit: BoxFit.cover,
                                      excludeFromSemantics: true,
                                    ),
                            ),
                          ),
                          Positioned.directional(
                            textDirection: Directionality.of(context),
                            bottom: 0,
                            end: 0,
                            child: CircleAvatar(
                              radius: 17,
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                              child: const Icon(
                                Icons.add_a_photo_outlined,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: busy ? null : _pickPhoto,
                  child: Text(t.settingsChoosePhoto),
                ),
                if (_photoError)
                  Text(
                    t.settingsPhotoError,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: AppSpacing.md),
                TamTextField(
                  key: const Key('settings-name-field'),
                  labelText: t.settingsName,
                  controller: _name,
                  enabled: !busy,
                  textInputAction: TextInputAction.done,
                  onChanged: context.read<SettingsCubit>().nameChanged,
                  onFieldSubmitted: (_) {
                    if (!busy) _save();
                  },
                  errorText: state.validationError
                      ? t.settingsNameValidation
                      : null,
                  helperText: t.settingsNameHint,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  t.settingsProfileLocalNotice,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (state.errorTarget == SettingsErrorTarget.name &&
                    state.error != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    t.settingsSaveError,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                TamButton.primary(
                  key: const Key('settings-profile-save'),
                  label: t.settingsProfileSave,
                  loadingLabel: t.settingsSaving,
                  isLoading:
                      state.activity == SettingsActivity.savingName || _picking,
                  onPressed: busy || (!state.nameDirty && _photo == null)
                      ? null
                      : _save,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: busy ? null : _close,
                  child: Text(t.settingsCancel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
