import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import '../bloc/chat_state.dart';

class ChatStatusBanner extends StatelessWidget {
  const ChatStatusBanner({
    super.key,
    required this.state,
    required this.onRetry,
    this.simulated = false,
  });
  final ChatState state;
  final VoidCallback onRetry;
  final bool simulated;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Column(
          children: [
            if (simulated)
              Text(
                t.chatSimulation,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            if (state.failure != null)
              Text(
                _failure(t, state.failure!),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            if (state.failure == 'NETWORK_ERROR' ||
                state.failure == 'INVALID_RESPONSE')
              TextButton(
                key: const Key('chat-retry-connection'),
                onPressed: onRetry,
                child: Text(t.chatRefresh),
              ),
            if (state.metadata?.canSend == false) Text(t.chatReadOnly),
          ],
        ),
      ),
    );
  }
}

String _failure(AppLocalizations t, String code) => switch (code) {
  'VALIDATION_ERROR' => t.chatValidation,
  'DRIVER_CHANGED' ||
  'CHAT_UNAVAILABLE' ||
  'TRIP_NOT_FOUND' => t.chatUnavailable,
  'CHAT_CLOSED' => t.chatReadOnly,
  'SESSION_ENDED' => t.chatSessionEnded,
  _ => t.chatConnectionError,
};
