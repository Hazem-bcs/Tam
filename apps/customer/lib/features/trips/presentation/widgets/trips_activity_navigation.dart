import 'package:flutter/material.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// A compact floating dock with an unmistakable active destination.
class TripsActivityNavigation extends StatelessWidget {
  const TripsActivityNavigation({super.key, required this.navigation});
  final CustomerNavigation navigation;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.lg,
            6,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 610),
              child: Material(
                color: colors.surfaceContainerLowest,
                elevation: 3,
                borderRadius: BorderRadius.circular(23),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Expanded(
                        child: _DockDestination(
                          label: l.navHome,
                          icon: Icons.home_outlined,
                          onTap: navigation.openHome,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _DockDestination(
                          label: l.tripsActivityTitle,
                          icon: Icons.alt_route_rounded,
                          active: true,
                        ),
                      ),
                      Expanded(
                        child: _DockDestination(
                          label: l.tripsAccountLabel,
                          icon: Icons.person_outline_rounded,
                          onTap: navigation.openSettings,
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
    );
  }
}

class _DockDestination extends StatelessWidget {
  const _DockDestination({
    required this.label,
    required this.icon,
    this.onTap,
    this.active = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = active ? scheme.onPrimary : scheme.onSurfaceVariant;
    return Semantics(
      selected: active,
      button: true,
      child: Material(
        color: active ? scheme.primary : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: active ? null : onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            constraints: const BoxConstraints(minHeight: 54),
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 3,
              vertical: AppSpacing.xs,
            ),
            child: active
                ? Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.sm,
                    runSpacing: 0,
                    children: [
                      Icon(icon, color: foreground, size: 22),
                      Text(
                        label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: foreground, size: 22),
                      const SizedBox(height: 1),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: foreground,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
