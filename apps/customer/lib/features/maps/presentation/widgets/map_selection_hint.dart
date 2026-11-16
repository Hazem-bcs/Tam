import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

/// A small edge hint leaves the selected building and surrounding streets clear.
class MapSelectionHint extends StatelessWidget {
  const MapSelectionHint({super.key, required this.bottomInset});
  final double bottomInset;
  @override
  Widget build(BuildContext context) => PositionedDirectional(
    bottom: bottomInset + AppSpacing.lg,
    start: AppSpacing.md,
    end: AppDimensions.minTapTarget + AppSpacing.xl,
    child: IgnorePointer(
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Material(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Text(
              AppLocalizations.of(context).mapsMoveToSelect,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ),
      ),
    ),
  );
}
