import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_state.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Deliberately derived from the actual draft; quoting does not advance the
/// user's progress since a generated quote is not an explicit review action.
class RideJourneyProgress extends StatelessWidget {
  const RideJourneyProgress({super.key, required this.state});

  final RideDraftState state;

  int get activeIndex {
    if (state.pickup == null) return 0;
    if (state.destination == null) return 1;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l = AppLocalizations.of(context);
    final labels = [
      l.rideRequestPickup,
      l.rideRequestDestination,
      l.rideRequestChooseClass,
    ];
    final active = activeIndex;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : AppMotion.medium;

    return Semantics(
      container: true,
      label: labels[active],
      child: Container(
        margin: const EdgeInsetsDirectional.only(bottom: AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.sheet),
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [colors.primary, colors.tertiary],
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    height: 51,
                    width: 51,
                    decoration: BoxDecoration(
                      color: colors.onPrimary.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                    child: Icon(
                      switch (active) {
                        0 => Icons.radio_button_checked_outlined,
                        1 => Icons.location_on_outlined,
                        _ => Icons.directions_car_outlined,
                      },
                      color: colors.onPrimary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: duration,
                      switchInCurve: AppMotion.easeOut,
                      switchOutCurve: AppMotion.easeIn,
                      child: Text(
                        labels[active],
                        key: ValueKey(active),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: colors.onPrimary.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                    child: Text(
                      '${active + 1}/${labels.length}',
                      textDirection: TextDirection.ltr,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                key: const Key('ride-stage-progress'),
                children: [
                  for (var index = 0; index < labels.length; index++) ...[
                    if (index != 0) const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AnimatedContainer(
                        key: Key('ride-progress-segment-$index'),
                        duration: duration,
                        curve: AppMotion.easeOut,
                        height: AppSpacing.sm,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                          color: index <= active
                              ? colors.onPrimary
                              : colors.onPrimary.withValues(alpha: 0.24),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
