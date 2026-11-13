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
  });
  final String title, subtitle, actionLabel;
  final String? notice, loadingLabel;
  final Widget content;
  final VoidCallback? onContinue;
  final bool loading;

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                key: ValueKey(title),
                padding: EdgeInsets.zero,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  Semantics(
                    header: true,
                    child: Text(title, style: theme.textTheme.headlineMedium),
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
            const SizedBox(height: AppSpacing.sm),
            TamButton.primary(
              key: const Key('ride-flow-continue'),
              label: actionLabel,
              isLoading: loading,
              loadingLabel: loadingLabel,
              onPressed: onContinue,
            ),
          ],
        ),
      ),
    );
  }
}
