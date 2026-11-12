import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';

class RideLocationFields extends StatelessWidget {
  const RideLocationFields({
    super.key,
    required this.pickup,
    required this.destination,
    required this.enabled,
    required this.onPickup,
    required this.onDestination,
  });

  final TripLocation? pickup;
  final TripLocation? destination;
  final bool enabled;
  final VoidCallback onPickup;
  final VoidCallback onDestination;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return TamCard(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
        child: Column(
          children: [
            _PlaceField(
              icon: Icons.radio_button_checked,
              title: l.rideRequestPickup,
              value: pickup?.label ?? l.rideRequestPickupHint,
              selected: pickup != null,
              onTap: enabled ? onPickup : null,
            ),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.lg,
              ),
              child: Divider(height: 1, color: colors.outlineVariant),
            ),
            _PlaceField(
              icon: Icons.location_on_rounded,
              title: l.rideRequestDestination,
              value: destination?.label ?? l.rideRequestDestinationHint,
              selected: destination != null,
              onTap: enabled ? onDestination : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceField extends StatelessWidget {
  const _PlaceField({
    required this.icon,
    required this.title,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.short;
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: '$title: $value',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: AnimatedContainer(
          duration: duration,
          curve: AppMotion.easeOut,
          constraints: const BoxConstraints(minHeight: 86),
          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: selected
                ? colors.primaryContainer.withValues(alpha: 0.25)
                : colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(icon, color: colors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      value,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: selected ? FontWeight.w700 : null,
                        color: selected
                            ? colors.onSurface
                            : colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.edit_outlined,
                color: colors.onSurfaceVariant,
                size: AppDimensions.iconSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
