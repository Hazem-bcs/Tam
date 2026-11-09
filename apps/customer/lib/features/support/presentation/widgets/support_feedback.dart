import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';
import '../../domain/support_repository.dart';

class SupportFeedback extends StatelessWidget {
  const SupportFeedback({
    super.key,
    required this.failure,
    required this.onRetry,
  });
  final SupportFailure failure;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final message = failure.uncertain
        ? t.supportUncertain
        : switch (failure.code) {
            'VALIDATION_ERROR' => t.supportBodyValidation,
            'INVALID_CATEGORY' => t.supportInvalidCategory,
            'TRIP_NOT_FOUND' ||
            'TICKET_NOT_FOUND' ||
            'FORBIDDEN' => t.supportNotFound,
            'UNAUTHENTICATED' => t.supportSessionEnded,
            'IDEMPOTENCY_CONFLICT' => t.supportConflict,
            'NETWORK_ERROR' => t.supportOffline,
            _ => t.supportUnavailable,
          };
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: TamCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              liveRegion: true,
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.sm),
              TamButton.secondary(
                key: const Key('support-retry'),
                label: t.supportRetry,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String supportStatus(AppLocalizations t, SupportTicketStatus status) =>
    switch (status) {
      SupportTicketStatus.open => t.supportStatusOpen,
      SupportTicketStatus.inProgress => t.supportStatusInProgress,
      SupportTicketStatus.resolved => t.supportStatusResolved,
    };
