import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';
import '../../domain/support_repository.dart';
import '../bloc/legal_cubit.dart';
import '../widgets/support_feedback.dart';
import '../widgets/support_page_frame.dart';

class LegalPage extends StatelessWidget {
  const LegalPage({super.key, required this.onBack});
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final cubit = context.read<LegalCubit>();
    return BlocBuilder<LegalCubit, LegalState>(
      builder: (context, state) {
        final document = state.document;
        return SupportPageFrame(
          title: cubit.kind == LegalDocumentKind.terms
              ? t.supportTerms
              : t.supportPrivacy,
          onBack: onBack,
          children: [
            if (state.loading)
              TamLoadingIndicator(semanticLabel: t.supportLoading),
            if (state.failure != null)
              SupportFeedback(failure: state.failure!, onRetry: cubit.load),
            if (!state.loading && state.failure == null && document == null)
              Text(t.supportLegalUnpublished),
            if (document != null) ...[
              Text(
                t.supportLegalVersion(
                  document.version,
                  DateFormat.yMd(
                    t.localeName,
                  ).format(document.publishedAt.toLocal()),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              SelectableText(document.plainText),
            ],
          ],
        );
      },
    );
  }
}
