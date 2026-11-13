import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// A quiet floating identity and five-segment progress, rather than an app bar.
class RideJourneyHeader extends StatelessWidget {
  const RideJourneyHeader({
    super.key,
    required this.step,
    required this.label,
    required this.onBack,
    this.backLabel,
    this.backIcon = Icons.arrow_back_rounded,
  });
  final int step;
  final String label;
  final VoidCallback? onBack;
  final String? backLabel;
  final IconData backIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.colorScheme;
    final t = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: c.surfaceContainerLowest,
          elevation: AppElevation.raised,
          shape: const CircleBorder(),
          child: IconButton(
            key: const Key('ride-flow-back'),
            onPressed: onBack,
            tooltip:
                backLabel ??
                MaterialLocalizations.of(context).backButtonTooltip,
            icon: Icon(backIcon, color: c.primary),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.topEnd,
            child: Tooltip(
              message: t.rideRequestFlowStep(step, 5),
              child: Semantics(
                label: t.rideRequestFlowStep(step, 5),
                child: Material(
                  color: c.surfaceContainerLowest,
                  elevation: AppElevation.raised,
                  borderRadius: BorderRadius.circular(AppRadii.sheet),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 210),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          Text(
                            t.appName,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: c.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AnimatedSwitcher(
                                  duration:
                                      MediaQuery.disableAnimationsOf(context)
                                      ? Duration.zero
                                      : AppMotion.short,
                                  child: Align(
                                    key: ValueKey(label),
                                    alignment: AlignmentDirectional.centerStart,
                                    child: Text(
                                      label,
                                      style: theme.textTheme.labelSmall,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                ExcludeSemantics(
                                  child: Row(
                                    children: List.generate(
                                      5,
                                      (index) => Expanded(
                                        child: Padding(
                                          padding: EdgeInsetsDirectional.only(
                                            end: index == 4 ? 0 : AppSpacing.xs,
                                          ),
                                          child: AnimatedContainer(
                                            duration:
                                                MediaQuery.disableAnimationsOf(
                                                  context,
                                                )
                                                ? Duration.zero
                                                : AppMotion.short,
                                            height: 3,
                                            decoration: BoxDecoration(
                                              color: index < step
                                                  ? c.primary
                                                  : c.outlineVariant,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppRadii.sm,
                                                  ),
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
