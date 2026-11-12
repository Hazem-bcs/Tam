import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/maps/presentation/maps_scope.dart';
import 'package:tam_customer/features/maps/presentation/widgets/route_map_view.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_state.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Displays the real map when private tiles are configured. Otherwise it shows
/// an explicitly non-geographic summary without inventing a route or ETA.
class RideRouteMotionPreview extends StatelessWidget {
  const RideRouteMotionPreview({super.key, required this.state});

  final RideDraftState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final hasRoute = state.hasRoute;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reducedMotion ? Duration.zero : AppMotion.long;
    final hasTiles =
        MapsScope.maybeOf(context)?.configuration.hasTiles ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSize(
          key: const Key('ride-motion-map'),
          duration: duration,
          curve: AppMotion.easeOut,
          alignment: Alignment.topCenter,
          child: RepaintBoundary(
            child: hasTiles
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    child: RouteMapView(
                      height: hasRoute ? 248 : 184,
                      origin: state.pickup?.point,
                      destination: state.destination?.point,
                    ),
                  )
                : _UnconfiguredRoutePreview(state: state, duration: duration),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedSwitcher(
          duration: duration,
          switchInCurve: AppMotion.easeOut,
          switchOutCurve: AppMotion.easeIn,
          child: Row(
            key: ValueKey(hasRoute),
            children: [
              Icon(
                hasRoute ? Icons.route_outlined : Icons.touch_app_outlined,
                size: AppDimensions.iconSize,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  hasRoute ? l.rideRequestQuoteTitle : l.rideRequestRouteHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A summary card, not a map. This also keeps disabled map zoom controls off
/// the booking surface until the project's private tiles are configured.
class _UnconfiguredRoutePreview extends StatelessWidget {
  const _UnconfiguredRoutePreview({
    required this.state,
    required this.duration,
  });

  final RideDraftState state;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final colors = theme.colorScheme;
    final hasRoute = state.hasRoute;

    return AnimatedContainer(
      key: const Key('ride-map-fallback'),
      duration: duration,
      curve: AppMotion.easeOut,
      constraints: const BoxConstraints(minHeight: 154),
      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        color: colors.primaryContainer.withValues(alpha: 0.55),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(
                  Icons.route_outlined,
                  color: colors.primary,
                  size: AppDimensions.iconSize,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l.rideRequestQuoteTitle,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              if (hasRoute)
                Icon(Icons.check_circle_outline, color: colors.primary),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _PlaceLabel(
                  title: l.rideRequestPickup,
                  value: state.pickup?.label ?? '—',
                  selected: state.pickup != null,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                child: AnimatedScale(
                  duration: duration,
                  scale: hasRoute ? 1 : 0.85,
                  curve: AppMotion.easeOut,
                  child: Icon(
                    Icons.more_horiz_rounded,
                    color: hasRoute ? colors.primary : colors.outline,
                  ),
                ),
              ),
              Expanded(
                child: _PlaceLabel(
                  title: l.rideRequestDestination,
                  value: state.destination?.label ?? '—',
                  selected: state.destination != null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l.mapsNotConfigured,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceLabel extends StatelessWidget {
  const _PlaceLabel({
    required this.title,
    required this.value,
    required this.selected,
  });

  final String title;
  final String value;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: selected ? colors.onSurface : colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
