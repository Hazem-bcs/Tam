import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/settings/presentation/bloc/settings_state.dart';
import 'package:tam_customer/features/settings/presentation/widgets/settings_mascot.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_text_field.dart';

/// One welcoming identity surface; profile edits never change Auth identity.
class SettingsProfileSection extends StatelessWidget {
  const SettingsProfileSection({
    super.key,
    required this.state,
    required this.phoneE164,
    required this.nameController,
    required this.isEditing,
    required this.onToggleEdit,
    required this.onNameChanged,
    required this.onSave,
  });

  final SettingsState state;
  final String? phoneE164;
  final TextEditingController nameController;
  final bool isEditing;
  final VoidCallback onToggleEdit;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final compactDetails =
        MediaQuery.sizeOf(context).width < 360 &&
        MediaQuery.textScalerOf(context).scale(16) > 24;
    final avatar = CircleAvatar(
      radius: 24,
      backgroundColor: colors.primaryContainer,
      foregroundColor: colors.onPrimaryContainer,
      child: const Icon(Icons.person_outline_rounded),
    );
    final edit = IconButton(
      tooltip: t.settingsEditName,
      onPressed: state.isBusy ? null : onToggleEdit,
      icon: Icon(isEditing ? Icons.expand_less_rounded : Icons.edit_outlined),
    );
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          phoneE164 == null ? t.authGuestTitle : state.profile!.displayName,
          style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          phoneE164 == null
              ? t.authGuestDescription
              : t.settingsCurrentPhoneHint,
          style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSize(
          alignment: AlignmentDirectional.topCenter,
          duration: reducedMotion ? Duration.zero : AppMotion.medium,
          child: keyboardOpen
              ? const SizedBox(width: double.infinity)
              : Container(
                  key: const Key('settings-welcome-hero'),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                      colors: [
                        colors.primaryContainer.withValues(alpha: 0.86),
                        colors.surfaceContainerLowest,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadii.sheet),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.sheet),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.sm,
                      ),
                      child: LayoutBuilder(
                        builder: (context, bounds) {
                          final largeText =
                              MediaQuery.textScalerOf(context).scale(16) > 24;
                          final compact = bounds.maxWidth < 300 || largeText;
                          final message = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                t.settingsWelcome,
                                style: text.headlineSmall?.copyWith(
                                  color: colors.onPrimaryContainer,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                t.settingsProfileSubtitle,
                                style: text.bodyMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          );
                          if (compact) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                message,
                                const SizedBox(height: AppSpacing.xs),
                                const Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: SettingsMascot(size: 88),
                                ),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(child: message),
                              const SizedBox(width: AppSpacing.sm),
                              const SettingsMascot(size: 110),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
        ),
        if (!keyboardOpen) const SizedBox(height: AppSpacing.md),
        Material(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadii.sheet),
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: colors.outlineVariant),
              borderRadius: BorderRadius.circular(AppRadii.sheet),
            ),
            padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (compactDetails) ...[
                  Row(children: [avatar, const Spacer(), edit]),
                  const SizedBox(height: AppSpacing.md),
                  details,
                ] else
                  Row(
                    children: [
                      avatar,
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: details),
                      edit,
                    ],
                  ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: phoneE164 == null
                      ? Text(
                          t.settingsPhoneUnavailable,
                          style: text.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        )
                      : Directionality(
                          textDirection: TextDirection.ltr,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SelectableText(
                              phoneE164!,
                              textDirection: TextDirection.ltr,
                              style:
                                  (compactDetails
                                          ? text.bodySmall
                                          : text.bodyLarge)
                                      ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                ),
                if (state.nameDirty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    t.settingsUnsaved,
                    style: text.labelSmall?.copyWith(color: colors.primary),
                  ),
                ],
                AnimatedSize(
                  alignment: AlignmentDirectional.topCenter,
                  curve: AppMotion.easeOut,
                  duration: reducedMotion ? Duration.zero : AppMotion.medium,
                  child: isEditing
                      ? Padding(
                          padding: const EdgeInsetsDirectional.only(
                            top: AppSpacing.lg,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TamTextField(
                                key: const Key('settings-name-field'),
                                labelText: t.settingsName,
                                controller: nameController,
                                enabled: !state.isBusy,
                                textInputAction: TextInputAction.done,
                                onChanged: onNameChanged,
                                onFieldSubmitted: (_) => onSave(),
                                errorText: state.validationError
                                    ? t.settingsNameValidation
                                    : null,
                                helperText: t.settingsNameHint,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TamButton.primary(
                                label: t.settingsSaveName,
                                loadingLabel: t.settingsSaving,
                                isLoading:
                                    state.activity ==
                                    SettingsActivity.savingName,
                                onPressed: state.nameDirty && !state.isBusy
                                    ? onSave
                                    : null,
                              ),
                              if (state.errorTarget ==
                                      SettingsErrorTarget.name &&
                                  state.error != null) ...[
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  t.settingsSaveError,
                                  style: text.bodySmall?.copyWith(
                                    color: colors.error,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
