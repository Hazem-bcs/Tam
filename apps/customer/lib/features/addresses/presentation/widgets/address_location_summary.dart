import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Compact, tappable selected-address label beneath the editor's heading.
/// The actual cartography lives in AddressMapPreview / TamMapCanvas.
class AddressLocationSummary extends StatelessWidget {
  const AddressLocationSummary({
    super.key,
    required this.locationLabel,
    required this.onTap,
  });

  final String? locationLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = AppLocalizations.of(context);
    final hasLocation = locationLabel?.trim().isNotEmpty ?? false;

    return Material(
      type: MaterialType.transparency,
      child: Semantics(
        button: true,
        enabled: onTap != null,
        child: InkWell(
          key: const Key('address-choose-location'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppDimensions.minTapTarget,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasLocation ? locationLabel! : t.addressesChooseLocation,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: hasLocation
                          ? colors.onSurfaceVariant
                          : colors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.edit_location_alt_outlined,
                  color: colors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
