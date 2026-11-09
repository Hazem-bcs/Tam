import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';
import '../../domain/support_repository.dart';
import 'support_feedback.dart';

class SupportTicketCard extends StatelessWidget {
  const SupportTicketCard({
    super.key,
    required this.ticket,
    this.onTap,
    this.detail = false,
  });
  final SupportTicket ticket;
  final VoidCallback? onTap;
  final bool detail;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final date = DateFormat.yMd(
      t.localeName,
    ).add_jm().format(ticket.createdAt.toLocal());
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TamCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.supportTicketReference(ticket.id),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              supportStatus(t, ticket.status),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            Text(date, style: theme.textTheme.bodySmall),
            if (ticket.tripId != null)
              Text(t.supportTripReference(ticket.tripId!)),
            const SizedBox(height: AppSpacing.md),
            Text(
              ticket.body,
              maxLines: detail ? null : 3,
              overflow: detail ? null : TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
