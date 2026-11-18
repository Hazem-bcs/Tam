import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/preferences/app_preferences.dart';
import 'package:tam_customer/app/preferences/app_preferences_cubit.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/settings/presentation/widgets/settings_action_tile.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

class SettingsAppearancePreferences extends StatelessWidget {
  const SettingsAppearancePreferences({super.key, required this.controller});

  final AppPreferencesCubit controller;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AppPreferencesCubit, AppPreferencesState>(
        bloc: controller,
        builder: (context, state) {
          final t = AppLocalizations.of(context);
          final appearances = {
            AppAppearance.system: t.settingsAppearanceSystem,
            AppAppearance.light: t.settingsAppearanceLight,
            AppAppearance.dark: t.settingsAppearanceDark,
          };
          final sizes = {
            AppFontSize.small: t.settingsFontSmall,
            AppFontSize.standard: t.settingsFontStandard,
            AppFontSize.large: t.settingsFontLarge,
            AppFontSize.extraLarge: t.settingsFontExtraLarge,
          };
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SettingsActionTile(
                key: const Key('settings-appearance'),
                icon: Icons.brightness_6_outlined,
                title: t.settingsAppearance,
                subtitle: appearances[state.preferences.appearance],
                onTap: state.busy
                    ? null
                    : () => _select(
                        context,
                        title: t.settingsAppearance,
                        options: appearances,
                        selected: state.preferences.appearance,
                        onSelected: controller.setAppearance,
                      ),
              ),
              SettingsActionTile(
                key: const Key('settings-font-size'),
                icon: Icons.text_fields_rounded,
                title: t.settingsFontSize,
                subtitle: sizes[state.preferences.fontSize],
                onTap: state.busy
                    ? null
                    : () => _select(
                        context,
                        title: t.settingsFontSize,
                        hint: t.settingsFontSizeHint,
                        options: sizes,
                        selected: state.preferences.fontSize,
                        onSelected: controller.setFontSize,
                      ),
              ),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        state.error == AppPreferencesError.restore
                            ? t.settingsPreferenceRestoreError
                            : t.settingsPreferenceSaveError,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      if (state.error == AppPreferencesError.restore)
                        TextButton(
                          onPressed: state.busy ? null : controller.restore,
                          child: Text(t.settingsRetry),
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      );

  Future<void> _select<T>(
    BuildContext context, {
    required String title,
    String? hint,
    required Map<T, String> options,
    required T selected,
    required Future<bool> Function(T) onSelected,
  }) async {
    final value = await showModalBottomSheet<T>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (context) => SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (hint != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(hint, style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: AppSpacing.md),
            for (final option in options.entries)
              Semantics(
                selected: option.key == selected,
                child: ListTile(
                  key: ValueKey('settings-option-${option.key}'),
                  title: Text(option.value),
                  minVerticalPadding: AppSpacing.md,
                  trailing: Icon(
                    option.key == selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                  ),
                  onTap: () => Navigator.pop(context, option.key),
                ),
              ),
          ],
        ),
      ),
    );
    if (value != null) await onSelected(value);
  }
}
