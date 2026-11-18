import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Touch gestures own zoom. Only the explicit return-to-location action floats.
class VectorMapControls extends StatelessWidget {
  const VectorMapControls({
    super.key,
    required this.bottomInset,
    this.onLocate,
    this.locating = false,
    this.followingDriver,
  });
  final double bottomInset;
  final VoidCallback? onLocate;
  final bool locating;
  final bool? followingDriver;

  @override
  Widget build(BuildContext context) {
    if (onLocate == null) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;
    return PositionedDirectional(
      end: AppSpacing.md,
      bottom: bottomInset + AppSpacing.md,
      child: Material(
        color: colors.surfaceContainerLowest,
        elevation: AppElevation.raised,
        shape: const CircleBorder(),
        child: IconButton(
          key: Key(
            followingDriver == null
                ? 'ride-use-device-location'
                : 'map-follow-driver',
          ),
          tooltip: followingDriver != null
              ? AppLocalizations.of(context).mapsFollowDriver
              : locating
              ? AppLocalizations.of(context).mapsLocating
              : AppLocalizations.of(context).mapsUseMyLocation,
          onPressed: locating ? null : onLocate,
          icon: locating
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  followingDriver == null
                      ? Icons.my_location_outlined
                      : followingDriver!
                      ? Icons.gps_fixed_rounded
                      : Icons.gps_not_fixed_rounded,
                  size: 22,
                  color: colors.onSurfaceVariant,
                ),
        ),
      ),
    );
  }
}
