import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Information only. The actual map behind the sheet owns location input.
class AddressLocationSummary extends StatelessWidget {
  const AddressLocationSummary({super.key, required this.locationLabel});

  final String? locationLabel;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selected = locationLabel?.trim().isNotEmpty ?? false;

    return Semantics(
      key: const Key('address-choose-location'),
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(Icons.place_outlined, color: colors.primary, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                selected ? locationLabel! : t.addressesChooseLocation,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: selected ? colors.onSurfaceVariant : colors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
