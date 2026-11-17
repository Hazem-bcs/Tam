import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';
import '../bloc/completion_cubit.dart';
import '../widgets/completion_rating_form.dart';
import '../widgets/completion_summary.dart';

/// Ride completion is a calm, single-purpose receipt and rating experience.
class CompletionPage extends StatelessWidget {
  const CompletionPage({
    super.key,
    required this.onBack,
    required this.onSupport,
    required this.onHome,
  });

  final VoidCallback onBack, onSupport, onHome;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.completionTitle),
        leading: BackButton(onPressed: onBack),
      ),
      body: SafeArea(
        child: BlocBuilder<CompletionCubit, CompletionState>(
          builder: (context, state) {
            final cubit = context.read<CompletionCubit>();
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: AppSpacing.pagePadding,
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!state.sessionEnded)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: AppSpacing.xs,
                            end: AppSpacing.xs,
                            bottom: AppSpacing.lg,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 18,
                                color: colors.onSurfaceVariant,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  l.completionSimulationNotice,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (state.loading)
                        TamLoadingIndicator(semanticLabel: l.completionLoading),
                      if (state.sessionEnded)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xl,
                          ),
                          child: Text(l.completionSessionEnded),
                        ),
                      if (!state.sessionEnded && state.completion != null) ...[
                        CompletionSummary(completion: state.completion!),
                        const SizedBox(height: AppSpacing.lg),
                        CompletionRatingForm(
                          state: state,
                          policy: cubit.policy,
                          onSubmit: cubit.submit,
                        ),
                      ],
                      if (state.failure != null && !state.sessionEnded) ...[
                        const SizedBox(height: AppSpacing.md),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            state.uncertain
                                ? l.completionUncertain
                                : _failure(l, state.failure!),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: colors.error),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TamButton.secondary(
                          key: const ValueKey('completion-retry'),
                          label: l.completionRetry,
                          onPressed: state.submitting ? null : cubit.retry,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.xs,
                        children: [
                          if (!state.sessionEnded)
                            TextButton.icon(
                              onPressed: onSupport,
                              icon: const Icon(Icons.support_agent_outlined),
                              label: Text(l.completionSupport),
                            ),
                          TextButton.icon(
                            onPressed: onHome,
                            icon: const Icon(Icons.home_outlined),
                            label: Text(l.completionHome),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _failure(AppLocalizations l, String code) => switch (code) {
    'VALIDATION_ERROR' => l.completionValidation,
    'TRIP_NOT_FOUND' => l.completionNotFound,
    'TRIP_NOT_COMPLETED' => l.completionNotCompleted,
    'SERVICE_UNAVAILABLE' => l.completionUnavailable,
    'RATING_ALREADY_SUBMITTED' => l.completionAlreadyRated,
    'IDEMPOTENCY_CONFLICT' || 'INVALID_RESPONSE' => l.completionInvalidResponse,
    _ => l.completionOffline,
  };
}
