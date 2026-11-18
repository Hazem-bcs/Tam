import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Language selection uses the app preference controller owned by the root.
class SettingsLanguageSheet extends StatelessWidget {
  const SettingsLanguageSheet({
    super.key,
    required this.languageCode,
    required this.onSelected,
  });

  final String languageCode;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.settingsLanguage,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              for (final code in const ['ar', 'en']) ...[
                ListTile(
                  key: Key('settings-locale-$code'),
                  minVerticalPadding: AppSpacing.md,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: languageCode == code
                          ? colors.primary
                          : colors.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                  tileColor: languageCode == code
                      ? colors.primaryContainer
                      : colors.surfaceContainerLowest,
                  title: Text(
                    code == 'ar' ? t.settingsArabic : t.settingsEnglish,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: Icon(
                    languageCode == code
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: languageCode == code
                        ? colors.primary
                        : colors.onSurfaceVariant,
                  ),
                  onTap: () => onSelected(code),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
