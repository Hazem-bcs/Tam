import 'package:flutter/material.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

class TripsActivityNavigation extends StatelessWidget {
  const TripsActivityNavigation({super.key, required this.navigation});
  final CustomerNavigation navigation;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 660),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.lg,
                AppSpacing.xs,
                AppSpacing.lg,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ActivityDestination(
                      label: l.navHome,
                      icon: Icons.home_outlined,
                      onTap: navigation.openHome,
                    ),
                  ),
                  Expanded(
                    child: _ActivityDestination(
                      label: l.tripsActivityTitle,
                      icon: Icons.history_toggle_off,
                      selected: true,
                    ),
                  ),
                  Expanded(
                    child: _ActivityDestination(
                      label: l.tripsAccountLabel,
                      icon: Icons.person_outline,
                      onTap: navigation.openSettings,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityDestination extends StatelessWidget {
  const _ActivityDestination({
    required this.label,
    required this.icon,
    this.selected = false,
    this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: selected ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: AppSpacing.xs,
            horizontal: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: selected ? theme.colorScheme.primaryContainer : null,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 25, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
