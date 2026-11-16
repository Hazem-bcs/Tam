import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';

import 'ride_entry_route_connector.dart';

/// Two editable endpoints share one horizontal route, growing with their text.
class RideJourneyEntry extends StatelessWidget {
  const RideJourneyEntry({
    super.key,
    this.pickup,
    this.destination,
    this.status,
    required this.onPickup,
    required this.onDestination,
    required this.onContinue,
  });
  final Widget? status;
  final TripLocation? pickup, destination;
  final VoidCallback onPickup, onDestination;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (status != null) ...[
            status!,
            const SizedBox(height: AppSpacing.md),
          ],
          CustomPaint(
            painter: RideEntryRouteConnector(
              color: colors.primary.withValues(alpha: .45),
              direction: Directionality.of(context),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Endpoint(
                    caption: t.rideRequestPhasePickup,
                    label: pickup?.label ?? t.rideRequestPickupHint,
                    icon: Icons.trip_origin_rounded,
                    onTap: onPickup,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _Endpoint(
                    caption: t.rideRequestDestination,
                    label: destination?.label ?? t.rideRequestDestinationHint,
                    icon: Icons.location_on_rounded,
                    onTap: onDestination,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            key: const Key('ride-flow-continue'),
            onPressed: onContinue,
            child: SizedBox(
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.sm,
                    ),
                    child: Text(
                      pickup != null && destination != null
                          ? t.rideRequestProgressVehicle
                          : t.rideRequestFlowStartAction,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const PositionedDirectional(
                    end: 0,
                    child: ExcludeSemantics(
                      child: Icon(Icons.arrow_forward_rounded, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Endpoint extends StatelessWidget {
  const _Endpoint({
    required this.caption,
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String caption, label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Semantics(
      button: true,
      label: '$caption: $label',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.xs,
            AppSpacing.xs,
            AppSpacing.xs,
            AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: colors.primary),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      caption,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
