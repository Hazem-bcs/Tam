import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/settings/presentation/bloc/settings_state.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// One welcoming identity surface; profile edits never change Auth identity.
class SettingsProfileSection extends StatelessWidget {
  const SettingsProfileSection({
    super.key,
    required this.state,
    required this.phoneE164,
    required this.onToggleEdit,
  });

  final SettingsState state;
  final String? phoneE164;
  final VoidCallback onToggleEdit;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final compactDetails =
        MediaQuery.sizeOf(context).width < 360 ||
        MediaQuery.textScalerOf(context).scale(16) > 24;
    final avatar = Container(
      width: 52,
      height: 52,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest.withValues(alpha: 0.7),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: state.profile?.avatarBytes == null
            ? Image.asset(
                'assets/notifications/account.webp',
                excludeFromSemantics: true,
              )
            : Image.memory(
                state.profile!.avatarBytes!,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
              ),
      ),
    );
    final edit = IconButton(
      tooltip: t.settingsEditName,
      onPressed: state.isBusy ? null : onToggleEdit,
      icon: const Icon(Icons.edit_outlined),
    );
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.profile!.displayName,
          style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          phoneE164 == null ? t.authGuestTitle : t.settingsProfileSubtitle,
          style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: colors.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadii.sheet),
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: colors.primaryContainer),
              borderRadius: BorderRadius.circular(AppRadii.sheet),
            ),
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
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
                if (phoneE164 != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: SelectableText(
                        phoneE164!,
                        textDirection: TextDirection.ltr,
                        style: text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: .3,
                        ),
                      ),
                    ),
                  ),
                ],
                if (state.nameDirty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    t.settingsUnsaved,
                    style: text.labelSmall?.copyWith(color: colors.primary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
