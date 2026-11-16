import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// One choice controls one confirmation action, with explicit selected semantics.
class RideMapPointRole extends StatelessWidget {
  const RideMapPointRole({
    super.key,
    required this.pickup,
    required this.onChanged,
  });
  final bool pickup;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.sheet),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Row(
          children: [
            for (final value in [false, true])
              Expanded(
                child: Semantics(
                  selected: pickup == value,
                  child: Material(
                    color: pickup == value
                        ? c.surfaceContainerLowest
                        : c.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.sheet),
                      side: pickup == value
                          ? BorderSide(color: c.primary)
                          : BorderSide.none,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      key: Key(
                        value
                            ? 'ride-map-role-pickup'
                            : 'ride-map-role-destination',
                      ),
                      onTap: () => onChanged(value),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: AppDimensions.minTapTarget,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                value
                                    ? Icons.trip_origin_rounded
                                    : Icons.location_on_outlined,
                                size: 20,
                                color: pickup == value
                                    ? c.primary
                                    : c.onSurfaceVariant,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Flexible(
                                child: Text(
                                  value
                                      ? t.rideRequestPhasePickup
                                      : t.rideRequestDestination,
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: pickup == value
                                            ? c.primary
                                            : c.onSurfaceVariant,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
