import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_journey.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';

/// Active journeys deserve priority, without a full-height burgundy block.
class ActiveTripCard extends StatelessWidget {
  const ActiveTripCard({super.key, required this.trip, required this.onFollow});

  final Trip trip;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l = AppLocalizations.of(context);

    return Material(
      color: colors.surfaceContainerLowest,
      elevation: AppElevation.raised,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: colors.primary.withValues(alpha: .25)),
      ),
      child: InkWell(
        key: Key('trips-active-${trip.id}'),
        onTap: onFollow,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ActivePulse(color: colors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          l.tripsActiveJourney,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      child: Text(
                        tripStatusLabel(l, trip.status),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Divider(color: colors.outlineVariant, height: 1),
              const SizedBox(height: AppSpacing.md),
              TripJourney(
                pickup: trip.booking.pickup,
                destination: trip.booking.destination,
              ),
              const SizedBox(height: AppSpacing.lg),
              Material(
                color: colors.primary,
                borderRadius: BorderRadius.circular(AppRadii.md),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: AppDimensions.minTapTarget,
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l.tripsFollowJourney,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(
                          Icons.arrow_back_rounded,
                          size: 21,
                          color: colors.onPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A one-shot entrance signal, not an endless pulse.
class _ActivePulse extends StatelessWidget {
  const _ActivePulse({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Icon(Icons.circle, color: color, size: 11);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .4, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Container(
        width: 11,
        height: 11,
        decoration: BoxDecoration(
          color: color.withValues(alpha: value),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: .18 * value),
              blurRadius: 7 * value,
              spreadRadius: 2 * value,
            ),
          ],
        ),
      ),
    );
  }
}
