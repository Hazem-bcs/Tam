import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({
    super.key,
    required this.onAddresses,
    required this.onActiveTrip,
  });

  final VoidCallback onAddresses;
  final VoidCallback onActiveTrip;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scale = MediaQuery.textScalerOf(context).scale(14);
    final narrow = MediaQuery.sizeOf(context).width < 345 || scale > 22;
    final actions = [
      _ActionCard(
        key: const Key('home-addresses'),
        label: t.addressesTitle,
        icon: Icons.bookmark_border_rounded,
        onTap: onAddresses,
      ),
      _ActionCard(
        key: const Key('home-active-trip'),
        label: t.activeTripFollow,
        icon: Icons.route_rounded,
        onTap: onActiveTrip,
      ),
    ];
    if (narrow) {
      return Column(
        children: [
          actions[0],
          const SizedBox(height: AppSpacing.sm),
          actions[1],
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: actions[0]),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: actions[1]),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final type = Theme.of(context).textTheme;
    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          constraints: const BoxConstraints(minHeight: 70),
          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 39,
                height: 39,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, size: 21, color: colors.primary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: type.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),
              Icon(Icons.chevron_left_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
