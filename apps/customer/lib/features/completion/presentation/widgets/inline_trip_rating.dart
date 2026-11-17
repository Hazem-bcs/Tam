import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/core/config/app_config.dart';
import 'package:tam_customer/features/completion/domain/completion_repository.dart';
import 'package:tam_customer/features/completion/presentation/bloc/completion_cubit.dart';
import 'package:tam_customer/features/completion/presentation/widgets/completion_rating_form.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';

/// Reuses the rating state machine without a second trip summary or route.
class InlineTripRating extends StatelessWidget {
  const InlineTripRating({
    super.key,
    required this.repository,
    required this.tripId,
  });
  final CompletionRepository repository;
  final String tripId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    key: ValueKey((repository, tripId)),
    create: (_) => CompletionCubit(
      repository,
      tripId: tripId,
      policy: AppConfig.completionPolicy,
    ),
    child: BlocBuilder<CompletionCubit, CompletionState>(
      builder: (context, state) {
        final t = AppLocalizations.of(context);
        final cubit = context.read<CompletionCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.completionSimulationNotice,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            if (state.loading && state.completion == null)
              TamLoadingIndicator(semanticLabel: t.completionLoading),
            if (state.sessionEnded)
              Text(t.completionSessionEnded)
            else ...[
              if (state.completion != null)
                CompletionRatingForm(
                  state: state,
                  policy: cubit.policy,
                  onSubmit: cubit.submit,
                ),
              if (state.failure != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  state.uncertain
                      ? t.completionUncertain
                      : _failure(t, state.failure!),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                TamButton.secondary(
                  key: const Key('inline-rating-retry'),
                  label: t.completionRetry,
                  onPressed: state.submitting ? null : cubit.retry,
                ),
              ],
            ],
          ],
        );
      },
    ),
  );

  String _failure(AppLocalizations t, String code) => switch (code) {
    'VALIDATION_ERROR' => t.completionValidation,
    'TRIP_NOT_FOUND' => t.completionNotFound,
    'TRIP_NOT_COMPLETED' => t.completionNotCompleted,
    'RATING_ALREADY_SUBMITTED' => t.completionAlreadyRated,
    'IDEMPOTENCY_CONFLICT' || 'INVALID_RESPONSE' => t.completionInvalidResponse,
    'SERVICE_UNAVAILABLE' => t.completionUnavailable,
    _ => t.completionOffline,
  };
}
