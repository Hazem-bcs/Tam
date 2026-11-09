import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';
import 'package:tam_customer/shared/widgets/tam_text_field.dart';
import '../bloc/support_editor_cubit.dart';
import '../widgets/support_feedback.dart';
import '../widgets/support_page_frame.dart';

class SupportEditorPage extends StatefulWidget {
  const SupportEditorPage({
    super.key,
    required this.onBack,
    required this.onCreated,
  });
  final VoidCallback onBack;
  final ValueChanged<String> onCreated;
  @override
  State<SupportEditorPage> createState() => _SupportEditorPageState();
}

class _SupportEditorPageState extends State<SupportEditorPage> {
  final _body = TextEditingController();
  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocConsumer<SupportEditorCubit, SupportEditorState>(
      listener: (context, state) {
        if (state.ended) _body.clear();
        final accepted = state.accepted;
        if (accepted != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(t.supportCreated)));
          widget.onCreated(accepted.id);
        }
      },
      builder: (context, state) {
        final cubit = context.read<SupportEditorCubit>();
        final enabled =
            !state.loading &&
            !state.sending &&
            !state.locked &&
            !state.ended &&
            state.accepted == null;
        return SupportPageFrame(
          title: t.supportNewTicket,
          onBack: widget.onBack,
          children: [
            if (state.ended) Text(t.supportSessionEnded),
            if (state.loading)
              TamLoadingIndicator(semanticLabel: t.supportLoading),
            if (state.failure != null)
              SupportFeedback(
                failure: state.failure!,
                onRetry: state.ended
                    ? null
                    : state.options == null
                    ? () => cubit.load()
                    : () => cubit.submit(),
              ),
            if (state.options != null && !state.ended) ...[
              if (state.options!.tripId != null) ...[
                Text(t.supportTripReference(state.options!.tripId!)),
                const SizedBox(height: AppSpacing.md),
              ],
              DropdownButtonFormField<String>(
                key: const Key('support-category'),
                initialValue: state.categoryId,
                isExpanded: true,
                decoration: InputDecoration(labelText: t.supportCategory),
                items: state.options!.categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(
                          t.localeName.startsWith('ar')
                              ? category.nameAr
                              : category.nameEn,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: enabled
                    ? (value) {
                        if (value != null) cubit.categoryChanged(value);
                      }
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              TamTextField(
                key: const Key('support-body'),
                labelText: t.supportBody,
                helperText: t.supportBodyHint,
                controller: _body,
                enabled: enabled,
                maxLines: 6,
                keyboardType: TextInputType.multiline,
                onChanged: cubit.bodyChanged,
              ),
              const SizedBox(height: AppSpacing.lg),
              TamButton.primary(
                key: const Key('support-submit'),
                label: state.locked ? t.supportRetry : t.supportSubmit,
                loadingLabel: t.supportSending,
                isLoading: state.sending,
                onPressed: state.locked || cubit.canSubmit
                    ? () => cubit.submit()
                    : null,
              ),
            ],
          ],
        );
      },
    );
  }
}
