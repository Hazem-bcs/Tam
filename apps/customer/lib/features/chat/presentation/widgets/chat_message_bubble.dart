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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final foreground = customer ? colors.onPrimary : colors.onSurface;
    final metadataColor = customer
        ? colors.onPrimary.withValues(alpha: .85)
        : colors.onSurfaceVariant;
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(sentAt.toLocal()));
    final bodyStyle = theme.textTheme.bodyLarge!.copyWith(
      color: foreground,
      height: 1.4,
    );
    final timeStyle = theme.textTheme.labelSmall!.copyWith(
      color: metadataColor,
      fontWeight: FontWeight.w400,
    );
    final needsAttention =
        customer &&
        (statusIcon == Icons.error_outline || statusIcon == Icons.help_outline);
    return LayoutBuilder(
      builder: (context, constraints) {
        final maximum = (constraints.maxWidth * .84).clamp(0.0, 560.0);
        final direction = Directionality.of(context);
        final scaler = MediaQuery.textScalerOf(context);
        double measure(String text, TextStyle style) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: style),
            textDirection: direction,
            textScaler: scaler,
          )..layout();
          final width = painter.width;
          painter.dispose();
          return width;
        }

        final metadata = Wrap(
          spacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(time, style: timeStyle),
            if (customer)
              Semantics(
                container: true,
                label: status,
                child: Icon(statusIcon, size: 14, color: metadataColor),
              ),
          ],
        );
        final inline =
            !body.contains('\n') &&
            !needsAttention &&
            measure(body, bodyStyle) +
                    measure(time, timeStyle) +
                    (customer ? 18 : 0) +
                    AppSpacing.sm <=
                maximum - AppSpacing.xl;
        return Align(
          alignment: customer
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maximum),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: customer
                    ? colors.primary
                    : colors.surfaceContainerLowest,
                borderRadius: BorderRadiusDirectional.only(
                  topStart: Radius.circular(
                    customer ? AppRadii.md : AppRadii.sm / 2,
                  ),
                  topEnd: Radius.circular(
                    customer ? AppRadii.sm / 2 : AppRadii.md,
                  ),
                  bottomStart: const Radius.circular(AppRadii.md),
                  bottomEnd: const Radius.circular(AppRadii.md),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: .05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: inline
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(child: Text(body, style: bodyStyle)),
                        const SizedBox(width: AppSpacing.sm),
                        metadata,
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(body, style: bodyStyle),
                        const SizedBox(height: AppSpacing.xs),
                        metadata,
                        if (needsAttention) Text(status, style: timeStyle),
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
            ),
          ),
        );
      },
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
