import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';
import '../bloc/completion_cubit.dart';
import '../widgets/completion_rating_form.dart';
import '../widgets/completion_summary.dart';

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
                      if (state.loading)
                        TamLoadingIndicator(semanticLabel: l.completionLoading),
                      if (state.sessionEnded) Text(l.completionSessionEnded),
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
                        const SizedBox(height: AppSpacing.lg),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            state.uncertain
                                ? l.completionUncertain
                                : _failure(l, state.failure!),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TamButton.secondary(
                          key: const ValueKey('completion-retry'),
                          label: l.completionRetry,
                          onPressed: state.submitting ? null : cubit.retry,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      if (!state.sessionEnded)
                        TamButton.secondary(
                          label: l.completionSupport,
                          icon: Icons.support_agent,
                          onPressed: onSupport,
                        ),
                      const SizedBox(height: AppSpacing.sm),
                      TamButton.secondary(
                        label: l.completionHome,
                        onPressed: onHome,
                      ),
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
