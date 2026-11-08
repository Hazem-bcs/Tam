import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/settings/presentation/bloc/settings_state.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';
import 'package:tam_customer/shared/widgets/tam_text_field.dart';

/// Account profile edits never update the signed-in Auth identity.
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
    final name = state.profile!.displayName;

    return TamCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact =
                  constraints.maxWidth < 340 &&
                  MediaQuery.textScalerOf(context).scale(1) > 1.5;
              final avatar = CircleAvatar(
                radius: 30,
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.onPrimaryContainer,
                child: const Icon(Icons.person_outline, size: 32),
              );
              final details = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    t.settingsProfileSubtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  if (state.nameDirty)
                    Text(
                      t.settingsUnsaved,
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: colors.primary),
                    ),
                ],
              );
              final edit = IconButton(
                tooltip: t.settingsEditName,
                onPressed: state.isBusy ? null : onToggleEdit,
                icon: Icon(isEditing ? Icons.expand_less : Icons.edit_outlined),
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [avatar, const Spacer(), edit]),
                    const SizedBox(height: AppSpacing.md),
                    details,
                  ],
                );
              }
              return Row(
                children: [
                  avatar,
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: details),
                  edit,
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(t.settingsPhone, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: SelectableText(
                phoneE164 ?? t.settingsPhoneUnavailable,
                textDirection: TextDirection.ltr,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          Text(
            t.settingsPhoneReadOnly,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          if (isEditing) ...[
            const SizedBox(height: AppSpacing.lg),
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
              isLoading: state.activity == SettingsActivity.savingName,
              onPressed: state.nameDirty && !state.isBusy ? onSave : null,
            ),
            if (state.errorTarget == SettingsErrorTarget.name &&
                state.error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                t.settingsSaveError,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.error),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
