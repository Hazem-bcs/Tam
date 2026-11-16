import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// The page's single primary conversion surface.
/// Both origin and destination open the existing ride request flow.
class HomeBookingCard extends StatelessWidget {
  const HomeBookingCard({super.key, required this.onRideRequest});
  final VoidCallback onRideRequest;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLowest,
      elevation: AppElevation.raised,
      shadowColor: colors.shadow.withValues(alpha: .09),
      borderRadius: BorderRadius.circular(AppRadii.sheet),
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.sheet),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LocationLine(
              label: t.homePickupLabel,
              value: t.homePickupPrompt,
              icon: Icons.trip_origin_rounded,
              isDestination: false,
              onPressed: onRideRequest,
            ),
            const SizedBox(height: 7),
            _LocationLine(
              label: t.homeDestinationLabel,
              value: t.homeDestinationPrompt,
              icon: Icons.location_on_rounded,
              isDestination: true,
              onPressed: onRideRequest,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              key: const Key('home-ride-entry'),
              onPressed: onRideRequest,
              style: FilledButton.styleFrom(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                minimumSize: const Size(0, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_taxi_rounded,
                    size: 22,
                    color: colors.onPrimary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      t.homeBookRide,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Icon(Icons.arrow_forward_rounded, color: colors.onPrimary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationLine extends StatelessWidget {
  const _LocationLine({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDestination,
    required this.onPressed,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isDestination;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 67),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 9, 12, 9),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDestination
                        ? colors.primaryContainer
                        : colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: colors.primary, size: 21),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: text.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        value,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_left_rounded,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
