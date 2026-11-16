import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// Three customer decisions; driver matching is a status after submission.
class RideJourneyHeader extends StatelessWidget {
  const RideJourneyHeader({
    super.key,
    required this.step,
    required this.label,
    required this.onBack,
    this.backLabel,
    this.backIcon = Icons.arrow_back_ios_new_rounded,
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
    final phase = step <= 2
        ? 0
        : step == 3
        ? 1
        : 2;
    final labels = [
      t.rideRequestPhasePlace,
      t.rideRequestPhaseVehicle,
      t.rideRequestPhaseConfirm,
    ];
    final progress = step > 4 ? label : t.rideRequestFlowStep(phase + 1, 3);
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
            icon: Icon(backIcon, color: c.primary, size: 20),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.topEnd,
            child: Material(
              color: c.surfaceContainerLowest,
              elevation: AppElevation.raised,
              borderRadius: BorderRadius.circular(AppRadii.sheet),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340, minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  child: Semantics(
                    label: '$progress، $label',
                    excludeSemantics: true,
                    child: step > 4
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.radar_rounded,
                                color: c.primary,
                                size: 18,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Flexible(
                                child: Text(
                                  label,
                                  style: theme.textTheme.labelMedium,
                                ),
                              ),
                            ],
                          )
                        : LayoutBuilder(
                            builder: (context, bounds) {
                              final scaler = MediaQuery.textScalerOf(context);
                              double width(String text) {
                                final painter = TextPainter(
                                  text: TextSpan(
                                    text: text,
                                    style: theme.textTheme.labelSmall,
                                  ),
                                  textDirection: Directionality.of(context),
                                  textScaler: scaler,
                                )..layout();
                                final result = painter.width;
                                painter.dispose();
                                return result;
                              }

                              final requiredWidth =
                                  labels.fold<double>(
                                    0,
                                    (total, text) => total + width(text) + 26,
                                  ) +
                                  24;
                              final compact = requiredWidth > bounds.maxWidth;
                              return Row(
                                children: [
                                  for (var i = 0; i < 3; i++) ...[
                                    if (i > 0)
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.xs,
                                          ),
                                          child: Container(
                                            height: 1,
                                            color: c.outlineVariant,
                                          ),
                                        ),
                                      ),
                                    _PhaseBadge(
                                      index: i,
                                      active: phase,
                                      label: labels[i],
                                      showLabel: !compact || i == phase,
                                    ),
                                  ],
                                ],
                              );
                            },
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

class _PhaseBadge extends StatelessWidget {
  const _PhaseBadge({
    required this.index,
    required this.active,
    required this.label,
    required this.showLabel,
  });
  final int index, active;
  final String label;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), c = theme.colorScheme;
    final current = index == active, complete = index < active;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : AppMotion.short,
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: current ? c.primary : c.surfaceContainerLowest,
            border: current
                ? null
                : Border.all(color: complete ? c.primary : c.outlineVariant),
          ),
          alignment: Alignment.center,
          child: complete
              ? Icon(Icons.check_rounded, size: 14, color: c.primary)
              : Text(
                  '${index + 1}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: current ? c.onPrimary : c.onSurfaceVariant,
                  ),
                ),
        ),
        if (showLabel) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: current ? c.primary : c.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
