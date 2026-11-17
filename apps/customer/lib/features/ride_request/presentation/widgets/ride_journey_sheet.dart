import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';

/// A pinned confirmation action on phones; short/keyboard layouts scroll the
/// action with the form so enlarged controls aren't covered by a fixed footer.
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
    this.edgeToEdgeContent = false,
    this.compact = false,
    this.header,
  });
  final String title, subtitle, actionLabel;
  final String? notice, loadingLabel;
  final Widget content;
  final Widget? header;
  final VoidCallback? onContinue;
  final bool loading, showAction, edgeToEdgeContent, compact;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), colors = theme.colorScheme;
    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadii.sheet),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: compact ? AppSpacing.xs : AppSpacing.md,
        ),
        child: LayoutBuilder(
          builder: (context, bounds) {
            final pinAction = bounds.maxHeight >= 320;
            final action = Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: TamButton.primary(
                key: const Key('ride-flow-continue'),
                label: actionLabel,
                isLoading: loading,
                loadingLabel: loadingLabel,
                onPressed: onContinue,
              ),
            );
            return Column(
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child:
                            header ??
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Semantics(
                                  header: true,
                                  child: Text(
                                    title,
                                    style: theme.textTheme.titleLarge,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  subtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                      ),
                      SizedBox(height: compact ? AppSpacing.sm : AppSpacing.lg),
                      if (edgeToEdgeContent)
                        content
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          child: content,
                        ),
                      if (notice != null) ...[
                        SizedBox(
                          height: compact ? AppSpacing.xs : AppSpacing.md,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          child: Text(
                            notice!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: compact ? AppSpacing.xs : AppSpacing.lg),
                      if (showAction && !pinAction) action,
                    ],
                  ),
                ),
                if (showAction && pinAction) ...[
                  const SizedBox(height: AppSpacing.sm),
                  action,
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
