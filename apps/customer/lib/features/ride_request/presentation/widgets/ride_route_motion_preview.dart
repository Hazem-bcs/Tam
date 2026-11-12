import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/maps/presentation/widgets/route_map_view.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_state.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Preserves the existing real map widget and its route state; animates only
/// the outer layout so map tiles are not intentionally repainted per frame.
class RideRouteMotionPreview extends StatelessWidget {
  const RideRouteMotionPreview({super.key, required this.state});

  final RideDraftState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final hasRoute = state.hasRoute;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : AppMotion.long;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSize(
          key: const Key('ride-motion-map'),
          duration: duration,
          curve: AppMotion.easeOut,
          alignment: Alignment.topCenter,
          clipBehavior: Clip.hardEdge,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            child: RepaintBoundary(
              child: RouteMapView(
                height: hasRoute ? 248 : 184,
                origin: state.pickup?.point,
                destination: state.destination?.point,
              ),
            ),
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
