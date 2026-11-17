import 'package:flutter/material.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'trip_status_filter.dart';

/// A calm, typographic masthead. The trips remain the focus of this page.
class ActivityMasthead extends StatelessWidget {
  const ActivityMasthead({super.key, required this.navigation});

  final CustomerNavigation navigation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l = AppLocalizations.of(context);

    return ColoredBox(
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.tripsActivityTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l.tripsActivitySubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _HeaderAction(
                  key: const Key('trips-notifications'),
                  tooltip: l.navNotifications,
                  onTap: navigation.openNotifications,
                  icon: Icons.notifications_none_rounded,
                ),
                const SizedBox(width: AppSpacing.sm),
                const TripStatusFilter(),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const _ActivityServices(),
          ],
        ),
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: colors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(color: colors.outlineVariant),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: SizedBox(
            width: AppDimensions.minTapTarget,
            height: AppDimensions.minTapTarget,
            child: Icon(icon, color: colors.primary, size: 22),
          ),
        ),
      ),
    );
  }
}

class _ActivityServices extends StatelessWidget {
  const _ActivityServices();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      key: const Key('trips-services'),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Row(
          children: [
            Expanded(
              child: _Service(
                label: l.tripsServiceRides,
                asset: 'assets/images/ride_car.webp',
                selected: true,
              ),
            ),
            Expanded(
              child: _Service(
                label: l.tripsServiceShopping,
                asset: 'assets/images/shopping.webp',
                subtitle: l.tripsSoon,
              ),
            ),
            Expanded(
              child: _Service(
                label: l.tripsServiceFood,
                asset: 'assets/images/food.webp',
                subtitle: l.tripsSoon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Coming-soon categories are informational, not fake active buttons.
class _Service extends StatelessWidget {
  const _Service({
    required this.label,
    required this.asset,
    this.subtitle,
    this.selected = false,
  });

  final String label;
  final String asset;
  final String? subtitle;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final foreground = selected ? colors.onPrimary : colors.onSurfaceVariant;

    return Semantics(
      selected: selected,
      enabled: selected,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Image.asset(
                    asset,
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontSize: 12,
                      color: foreground,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
