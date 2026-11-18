import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    required this.now,
    required this.controller,
    required this.onLoadOlder,
    required this.onRetry,
  });
  final Key? latestMessageKey;
  final ChatState state;
  final DateTime Function() now;
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
          final previous = chronological == 0
              ? null
              : chronological == state.messages.length
              ? state.messages.lastOrNull?.sentAt
              : state
                    .pending[chronological - state.messages.length - 1]
                    .createdAt;
          return _withDate(
            context,
            p.createdAt,
            now(),
            previous,
            ChatMessageBubble(
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
            ),
          );
        }
        final message = state.messages[chronological];
        final previous = chronological == 0
            ? null
            : state.messages[chronological - 1].sentAt;
        return _withDate(
          context,
          message.sentAt,
          now(),
          previous,
          ChatMessageBubble(
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
          ),
        );
      },
    );
  }
}

Widget _withDate(
  BuildContext context,
  DateTime date,
  DateTime now,
  DateTime? previous,
  Widget bubble,
) {
  final local = date.toLocal();
  if (previous != null && DateUtils.isSameDay(local, previous.toLocal())) {
    return bubble;
  }
  final colors = Theme.of(context).colorScheme;
  final label = DateUtils.isSameDay(local, now.toLocal())
      ? AppLocalizations.of(context).chatToday
      : DateFormat.yMMMd(
          Localizations.localeOf(context).languageCode,
        ).format(local);
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Row(
          children: [
            Expanded(child: Divider(color: colors.outlineVariant)),
            const SizedBox(width: AppSpacing.md),
            Flexible(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadii.sheet),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Divider(color: colors.outlineVariant)),
          ],
        ),
      ),
      bubble,
    ],
  );
}
