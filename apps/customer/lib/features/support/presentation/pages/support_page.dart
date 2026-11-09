import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';
import '../bloc/support_list_cubit.dart';
import '../widgets/support_feedback.dart';
import '../widgets/support_page_frame.dart';
import '../widgets/support_ticket_card.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({
    super.key,
    required this.onBack,
    required this.onCreate,
    required this.onTicket,
    required this.onChooseTrip,
  });
  final VoidCallback onBack, onCreate, onChooseTrip;
  final ValueChanged<String> onTicket;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocBuilder<SupportListCubit, SupportListState>(
      builder: (context, state) {
        final cubit = context.read<SupportListCubit>();
        return SupportPageFrame(
          title: t.supportTitle,
          onBack: onBack,
          children: [
            Text(t.supportIntro),
            const SizedBox(height: AppSpacing.lg),
            TamButton.primary(
              key: const Key('support-new-ticket'),
              label: t.supportNewTicket,
              onPressed: state.ended ? null : onCreate,
            ),
            const SizedBox(height: AppSpacing.sm),
            TamButton.secondary(
              label: t.supportChooseTrip,
              onPressed: state.ended ? null : onChooseTrip,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              t.supportMyTickets,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            if (state.ended) Text(t.supportSessionEnded),
            if (state.failure != null)
              SupportFeedback(
                failure: state.failure!,
                onRetry: () => cubit.load(),
              ),
            if (state.loading)
              TamLoadingIndicator(semanticLabel: t.supportLoading),
            if (!state.loading &&
                !state.ended &&
                state.tickets.isEmpty &&
                state.failure == null)
              Text(t.supportEmpty),
            ...state.tickets.map(
              (ticket) => SupportTicketCard(
                ticket: ticket,
                onTap: () => onTicket(ticket.id),
              ),
            ),
            if (state.cursor != null)
              TamButton.secondary(
                label: t.supportLoadMore,
                isLoading: state.loadingMore,
                loadingLabel: t.supportLoading,
                onPressed: () => cubit.load(more: true),
              ),
          ],
        );
      },
    );
  }
}
