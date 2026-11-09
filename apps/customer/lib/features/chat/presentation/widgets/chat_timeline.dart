import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';
import '../../domain/chat_repository.dart';
import '../bloc/chat_state.dart';
import 'chat_message_bubble.dart';

class ChatTimeline extends StatelessWidget {
  const ChatTimeline({
    super.key,
    this.latestMessageKey,
    required this.state,
    required this.controller,
    required this.onLoadOlder,
    required this.onRetry,
  });
  final Key? latestMessageKey;
  final ChatState state;
  final ScrollController controller;
  final VoidCallback onLoadOlder;
  final ValueChanged<String> onRetry;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    if (state.loading) {
      return Center(child: TamLoadingIndicator(semanticLabel: t.chatLoading));
    }
    if (state.messages.isEmpty && state.pending.isEmpty) {
      return Center(child: Text(t.chatEmpty));
    }
    final count = state.messages.length + state.pending.length;
    return ListView.builder(
      controller: controller,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: count + (state.nextBeforeSequence == null ? 0 : 1),
      itemBuilder: (_, index) {
        if (index == count) {
          return TextButton(
            key: const Key('chat-load-older'),
            onPressed: state.loadingOlder ? null : onLoadOlder,
            child: Text(state.loadingOlder ? t.chatLoading : t.chatLoadOlder),
          );
        }
        final chronological = count - 1 - index;
        if (chronological >= state.messages.length) {
          final p = state.pending[chronological - state.messages.length];
          return ChatMessageBubble(
            key: ValueKey(p.clientMessageId),
            body: p.body,
            sentAt: p.createdAt,
            customer: true,
            statusIcon: switch (p.status) {
              ChatSendStatus.sending => Icons.schedule,
              ChatSendStatus.failed => Icons.error_outline,
              ChatSendStatus.uncertain => Icons.help_outline,
            },
            status: switch (p.status) {
              ChatSendStatus.sending => t.chatSending,
              ChatSendStatus.failed => t.chatFailed,
              ChatSendStatus.uncertain => t.chatUncertain,
            },
            onRetry: p.status == ChatSendStatus.sending || !state.canSend
                ? null
                : () => onRetry(p.clientMessageId),
          );
        }
        final message = state.messages[chronological];
        return ChatMessageBubble(
          key: message == state.messages.last && latestMessageKey != null
              ? latestMessageKey
              : ValueKey(message.id),
          body: message.body,
          sentAt: message.sentAt,
          customer: message.author == ChatAuthor.customer,
          status: chatReceiptLabel(t, message, state.metadata),
          statusIcon:
              message.sequence <= (state.metadata?.deliveredThrough ?? 0)
              ? Icons.done_all
              : Icons.done,
        );
      },
    );
  }
}
