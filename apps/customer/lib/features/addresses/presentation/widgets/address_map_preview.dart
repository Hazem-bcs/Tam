import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/maps/presentation/maps_scope.dart';
import 'package:tam_customer/features/maps/presentation/widgets/tam_map_canvas.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';

import 'address_visual_icon.dart';

/// Reuses the application's real map surface. Selection and reverse-geocoding
/// remain owned by the existing Maps picker instead of this visual preview.
class AddressMapPreview extends StatelessWidget {
  const AddressMapPreview({
    super.key,
    required this.location,
    required this.onChooseLocation,
    required this.onBack,
  });

  final TripLocation? location;
  final VoidCallback? onChooseLocation;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final dependencies = MapsScope.maybeOf(context);
    final colors = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final showInitialPin = dependencies != null &&
        (dependencies.configuration.hasTiles ||
            dependencies.configuration.hasVectorStyle) &&
        location == null;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (dependencies == null)
          ColoredBox(
            color: colors.surfaceContainer,
            child: Center(
              child: Text(
                l.mapsNotConfigured,
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          TamMapCanvas(
            key: const Key('address-real-map'),
            configuration: dependencies.configuration,
            tileProviderFactory: dependencies.tileProviderFactory,
            onAttribution: dependencies.attribution.open,
            origin: location?.point,
            compactPreview: true,
          ),
        if (showInitialPin)
          const Center(
            child: IgnorePointer(
              child: AddressPinArtwork(size: 64),
            ),
          ),
        Positioned.fill(
          child: Semantics(
            button: true,
            label: l.mapsPickLocation,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                key: const Key('address-map-tap'),
                onTap: onChooseLocation,
              ),
            ),
          ),
        ),
        PositionedDirectional(
          top: AppSpacing.md,
          end: AppSpacing.lg,
          child: _MapAction(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: onBack,
            icon: const BackButtonIcon(),
          ),
        ),
        PositionedDirectional(
          bottom: 54,
          end: AppSpacing.lg,
          child: _MapAction(
            tooltip: l.mapsPickLocation,
            onPressed: onChooseLocation,
            icon: const Icon(Icons.my_location_rounded),
          ),
        ),
      ],
    );
  }
}

class _MapAction extends StatelessWidget {
  const _MapAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final Widget icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLowest,
      elevation: AppElevation.raised,
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: IconTheme(
          data: IconThemeData(color: colors.primary, size: 22),
          child: icon,
        ),
        constraints: const BoxConstraints(
          minWidth: AppDimensions.minTapTarget,
          minHeight: AppDimensions.minTapTarget,
        ),
      ),
    );
  }
}
