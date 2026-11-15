import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';

/// One continuous sheet. Only its contents and height change between steps.
class RideJourneySheet extends StatelessWidget {
  const RideJourneySheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.actionLabel,
    this.onContinue,
    this.loading = false,
    this.loadingLabel,
    this.notice,
    this.showAction = true,
  });
  final String title, subtitle, actionLabel;
  final String? notice, loadingLabel;
  final Widget content;
  final VoidCallback? onContinue;
  final bool loading;
  final bool showAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: ListView(
                shrinkWrap: true,
                key: ValueKey(title),
                padding: EdgeInsets.zero,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  Semantics(
                    header: true,
                    child: Text(title, style: theme.textTheme.titleLarge),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  content,
                  if (notice != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      notice!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
            if (showAction) ...[
              const SizedBox(height: AppSpacing.sm),
              TamButton.primary(
                key: const Key('ride-flow-continue'),
                label: actionLabel,
                isLoading: loading,
                loadingLabel: loadingLabel,
                onPressed: onContinue,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
