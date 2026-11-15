import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/trips/presentation/widgets/trip_journey.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/presentation/trip_display.dart';

/// Strong visual priority for a real, not fabricated, active trip.
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
      color: colors.primary,
      borderRadius: BorderRadius.circular(25),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('trips-active-${trip.id}'),
        onTap: onFollow,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ActivePulse(color: colors.onPrimary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        l.tripsActiveJourney,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    tripStatusLabel(l, trip.status),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onPrimary.withValues(alpha: .77),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              TripJourney(
                pickup: trip.booking.pickup,
                destination: trip.booking.destination,
                onDark: true,
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                height: 1,
                color: colors.onPrimary.withValues(alpha: .22),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.tripsFollowJourney,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.onPrimary,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(9),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: colors.primary,
                        size: 19,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single gentle entrance pulse; never an infinite attention demand.
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
              color: color.withValues(alpha: .22 * value),
              blurRadius: 8 * value,
              spreadRadius: 3 * value,
            ),
          ],
        ),
      ),
    );
  }
}
