import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/driver_avatar.dart';
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
    this.showDemoAvatar = false,
  });
  final String body, status;
  final DateTime sentAt;
  final bool customer;
  final bool showDemoAvatar;
  final VoidCallback? onRetry;
  final IconData statusIcon;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = customer ? colors.onPrimary : colors.onSurface;
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(sentAt.toLocal()));
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: customer
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!customer) ...[
            DriverAvatar(size: 36, showDemoAvatar: showDemoAvatar),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: customer ? colors.primary : colors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: .09),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    body,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: customer
                          ? colors.onPrimary
                          : colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        time,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: foreground,
                        ),
                      ),
                      if (customer)
                        Icon(statusIcon, size: 16, color: foreground),
                      if (customer)
                        Text(
                          status,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: foreground,
                          ),
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
          if (customer) ...[
            const SizedBox(width: AppSpacing.sm),
            CircleAvatar(
              radius: 18,
              backgroundColor: colors.primaryContainer,
              foregroundColor: colors.primary,
              child: const Icon(Icons.person_rounded, size: 22),
            ),
          ],
        ],
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
