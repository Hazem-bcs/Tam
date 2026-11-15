import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

class VectorMapControls extends StatelessWidget {
  const VectorMapControls({
    super.key,
    required this.bottomInset,
    required this.onZoom,
    this.onLocate,
    this.locating = false,
  });
  final double bottomInset;
  final ValueChanged<int>? onZoom;
  final VoidCallback? onLocate;
  final bool locating;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    return PositionedDirectional(
      end: AppSpacing.sm,
      bottom: bottomInset + AppSpacing.sm,
      child: Material(
        color: colors.surfaceContainerLowest,
        elevation: AppElevation.raised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(color: colors.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onLocate != null)
              IconButton(
                key: const Key('ride-use-device-location'),
                tooltip: l.mapsUseMyLocation,
                onPressed: locating ? null : onLocate,
                icon: locating
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location_rounded),
              ),
            IconButton(
              tooltip: l.mapsZoomIn,
              icon: const Icon(Icons.add),
              onPressed: onZoom == null ? null : () => onZoom!(1),
            ),
            IconButton(
              tooltip: l.mapsZoomOut,
              icon: const Icon(Icons.remove),
              onPressed: onZoom == null ? null : () => onZoom!(-1),
            ),
          ],
        ),
      ),
    );
  }
}
