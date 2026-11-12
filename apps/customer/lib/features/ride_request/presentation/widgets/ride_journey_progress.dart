import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_state.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// A visual indication of progress, derived only from the existing ride draft.
///
/// It never advances the booking or assumes a successful server response.
class RideJourneyProgress extends StatelessWidget {
  const RideJourneyProgress({super.key, required this.state});

  final RideDraftState state;

  int get activeIndex {
    if (state.pickup == null) return 0;
    if (state.destination == null) return 1;
    // A quote is fetched automatically. It does not mean the user reviewed
    // or explicitly accepted the vehicle; keep the UI on the choice step.
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final labels = [
      l.rideRequestPickup,
      l.rideRequestDestination,
      l.rideRequestChooseClass,
    ];
    final active = activeIndex;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      container: true,
      label: labels[active],
      child: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.route_outlined,
                  size: AppDimensions.iconSize,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: reduceMotion ? Duration.zero : AppMotion.medium,
                    switchInCurve: AppMotion.easeOut,
                    switchOutCurve: AppMotion.easeIn,
                    child: Text(
                      labels[active],
                      key: ValueKey(active),
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                ),
                Text(
                  '${active + 1}/${labels.length}',
                  textDirection: TextDirection.ltr,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              key: const Key('ride-stage-progress'),
              children: [
                for (var index = 0; index < labels.length; index++) ...[
                  if (index != 0) const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: AnimatedContainer(
                      key: Key('ride-progress-segment-$index'),
                      duration: reduceMotion ? Duration.zero : AppMotion.medium,
                      curve: AppMotion.easeOut,
                      height: AppSpacing.xs,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        color: index <= active
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
