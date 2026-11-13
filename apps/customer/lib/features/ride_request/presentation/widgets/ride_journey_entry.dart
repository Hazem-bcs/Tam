import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';

/// The introduction grows with its content rather than reserving half a screen.
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadii.sheet),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                t.rideRequestFlowStartTitle,
                style: theme.textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              t.rideRequestFlowStartSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            if (status != null) ...[
              const SizedBox(height: AppSpacing.md),
              status!,
            ],
            const SizedBox(height: AppSpacing.lg),
            Material(
              color: colors.surfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                side: BorderSide(color: colors.outlineVariant),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _LocationRow(
                    caption: t.rideRequestPickup,
                    label: pickup?.label ?? t.rideRequestPickupHint,
                    icon: Icons.trip_origin_rounded,
                    onTap: onPickup,
                  ),
                  const Divider(
                    height: 1,
                    indent: AppSpacing.xl,
                    endIndent: AppSpacing.xl,
                  ),
                  _LocationRow(
                    caption: t.rideRequestDestination,
                    label: destination?.label ?? t.rideRequestDestinationHint,
                    icon: Icons.location_on_rounded,
                    onTap: onDestination,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TamButton.primary(
              key: const Key('ride-flow-continue'),
              label: destination == null
                  ? t.rideRequestFlowStartAction
                  : t.rideRequestFlowContinue,
              icon: Icons.arrow_forward_rounded,
              onPressed: onContinue,
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({
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
    return ListTile(
      minTileHeight: 60,
      minVerticalPadding: AppSpacing.xs,
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 0,
      ),
      leading: Icon(icon, size: 20, color: colors.primary),
      title: Text(
        caption,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(color: colors.onSurface),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
