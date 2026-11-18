import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/maps/presentation/maps_scope.dart';
import 'package:tam_customer/features/maps/presentation/widgets/map_camera_focus.dart';
import 'package:tam_customer/features/maps/presentation/widgets/tam_map_canvas.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/geo_point.dart';
import 'package:tam_customer/shared/domain/trip.dart';

/// An interactive TAM map, not an image or a link to a second picker page.
/// The parent owns the coordinate selection and permission flow.
class AddressMapPreview extends StatelessWidget {
  const AddressMapPreview({
    super.key,
    required this.location,
    required this.onSelected,
    required this.onBack,
    required this.onLocate,
    this.focus,
    this.locating = false,
  });

  final TripLocation? location;
  final ValueChanged<GeoPoint>? onSelected;
  final VoidCallback? onBack;
  final VoidCallback? onLocate;
  final MapCameraFocus? focus;
  final bool locating;

  @override
  Widget build(BuildContext context) {
    final dependencies = MapsScope.maybeOf(context);
    final colors = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (dependencies == null)
          ColoredBox(
            color: colors.surfaceContainer,
            child: Center(
              child: Text(l.mapsNotConfigured, textAlign: TextAlign.center),
            ),
          )
        else
          TamMapCanvas(
            key: const Key('address-real-map'),
            configuration: dependencies.configuration,
            tileProviderFactory: dependencies.tileProviderFactory,
            onAttribution: dependencies.attribution.open,
            selection: location?.point,
            focus: focus,
            onSelected: onSelected,
          ),
        PositionedDirectional(
          top: AppSpacing.md,
          start: AppSpacing.lg,
          child: _MapAction(
            key: const Key('address-map-back'),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: onBack,
            icon: const BackButtonIcon(),
          ),
        ),
        PositionedDirectional(
          top: AppSpacing.md + AppDimensions.minTapTarget + AppSpacing.lg,
          start: AppSpacing.lg,
          child: _MapAction(
            key: const Key('address-map-locate'),
            tooltip: l.mapsUseMyLocation,
            onPressed: onLocate,
            icon: locating
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_rounded),
          ),
        ),
      ],
    );
  }
}

class _MapAction extends StatelessWidget {
  const _MapAction({
    super.key,
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
