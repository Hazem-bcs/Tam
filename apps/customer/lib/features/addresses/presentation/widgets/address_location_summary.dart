import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Minimal selection feedback. Exact GPS coordinates remain in the domain,
/// never printed in the form or mistaken for a human-readable street address.
class AddressLocationSummary extends StatelessWidget {
  const AddressLocationSummary({super.key, required this.hasLocation});

  final bool hasLocation;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      key: const Key('address-choose-location'),
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
        child: Row(
          children: [
            Icon(
              hasLocation ? Icons.check_circle_outline : Icons.place_outlined,
              color: hasLocation ? colors.primary : colors.onSurfaceVariant,
              size: 17,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                hasLocation ? t.mapsSelectedPoint : t.addressesChooseLocation,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
