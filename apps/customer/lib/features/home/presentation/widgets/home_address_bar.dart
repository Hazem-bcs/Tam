import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// The saved home address is displayed without claiming it is a live GPS fix.
class HomeAddressBar extends StatelessWidget {
  const HomeAddressBar({
    super.key,
    this.label,
    this.loading = false,
    required this.onManage,
  });
  final String? label;
  final bool loading;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: InkWell(
        key: const Key('home-default-address'),
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: onManage,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppDimensions.minTapTarget,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    loading
                        ? l.addressesLoading
                        : label ?? l.homeSelectDefaultAddress,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
