import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';
import '../bloc/support_detail_cubit.dart';
import '../widgets/support_feedback.dart';
import '../widgets/support_page_frame.dart';
import '../widgets/support_ticket_card.dart';

class SupportTicketDetailsPage extends StatelessWidget {
  const SupportTicketDetailsPage({super.key, required this.onBack});
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocBuilder<SupportDetailCubit, SupportDetailState>(
      builder: (context, state) => SupportPageFrame(
        title: t.supportTicketDetails,
        onBack: onBack,
        children: [
          Text(
            t.supportSimulationNotice,
            style: Theme.of(context).textTheme.bodySmall,
          ),

          if (state.loading)
            TamLoadingIndicator(semanticLabel: t.supportLoading),
          if (state.ended) Text(t.supportSessionEnded),
          if (state.failure != null)
            SupportFeedback(
              failure: state.failure!,
              onRetry: () => context.read<SupportDetailCubit>().load(),
            ),
          if (state.ticket != null)
            SupportTicketCard(ticket: state.ticket!, detail: true),
        ],
      ),
    );
  }
}
