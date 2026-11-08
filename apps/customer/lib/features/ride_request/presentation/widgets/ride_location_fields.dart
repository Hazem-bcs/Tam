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
    final l10n = AppLocalizations.of(context);
    return TamCard(
      padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
      child: Column(
        children: [
          _PlaceField(
            icon: Icons.radio_button_checked,
            title: l10n.rideRequestPickup,
            value: pickup?.label ?? l10n.rideRequestPickupHint,
            selected: pickup != null,
            onTap: enabled ? onPickup : null,
          ),
          const Divider(height: 1),
          _PlaceField(
            icon: Icons.location_on_outlined,
            title: l10n.rideRequestDestination,
            value: destination?.label ?? l10n.rideRequestDestinationHint,
            selected: destination != null,
            onTap: enabled ? onDestination : null,
          ),
        ],
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
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: '$title: $value',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppDimensions.minTapTarget,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.labelMedium),
                      Text(
                        value,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: selected
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.edit_outlined),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
