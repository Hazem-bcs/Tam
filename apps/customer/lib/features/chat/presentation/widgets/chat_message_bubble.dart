import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import '../../domain/chat_repository.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.body,
    required this.sentAt,
    required this.customer,
    required this.status,
    this.onRetry,
    this.statusIcon = Icons.done,
  });
  final String body, status;
  final DateTime sentAt;
  final bool customer;
  final VoidCallback? onRetry;
  final IconData statusIcon;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = customer ? colors.onPrimary : colors.onSurface;
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(sentAt.toLocal()));
    return Align(
      alignment: customer ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: .88,
        child: Align(
          alignment: customer ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: customer ? colors.primary : colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  body,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: foreground),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      time,
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: foreground),
                    ),
                    if (customer) Icon(statusIcon, size: 16, color: foreground),
                    if (customer)
                      Text(
                        status,
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(color: foreground),
                      ),
                    if (onRetry != null)
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: foreground,
                        ),
                        onPressed: onRetry,
                        child: Text(AppLocalizations.of(context).chatRetry),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String chatReceiptLabel(
  AppLocalizations t,
  ChatMessage message,
  ChatMetadata? metadata,
) => message.sequence <= (metadata?.readThrough ?? 0)
    ? t.chatRead
    : message.sequence <= (metadata?.deliveredThrough ?? 0)
    ? t.chatDelivered
    : t.chatSent;
