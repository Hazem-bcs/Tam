import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';

import '../bloc/support_editor_cubit.dart';
import '../widgets/support_editor_category_picker.dart';
import '../widgets/support_editor_sections.dart';
import '../widgets/support_feedback.dart';

/// Support requests keep their existing validation and submission contract.
/// This screen owns only the visual presentation of that contract.
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
        final options = state.options;
        final editable =
            !state.loading &&
            !state.sending &&
            !state.locked &&
            !state.ended &&
            state.accepted == null;

        return Scaffold(
          backgroundColor: colors.surface,
          appBar: AppBar(
            backgroundColor: colors.surface,
            surfaceTintColor: colors.surface,
            scrolledUnderElevation: 0,
            centerTitle: true,
            title: Text(
              t.supportNewTicket,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.83),
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: BackButton(
              color: colors.primary,
              onPressed: widget.onBack,
            ),
          ),
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppSpacing.xl,
                          AppSpacing.sm,
                          AppSpacing.xl,
                          AppSpacing.xl,
                        ),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        children: [
                          SupportEditorHero(
                            title: t.supportEditorHeadline,
                            subtitle: t.supportEditorSubtitle,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          SupportEditorNotice(text: t.supportSimulationNotice),
                          const SizedBox(height: AppSpacing.xl),
                          if (state.ended)
                            Text(
                              t.supportSessionEnded,
                              style: theme.textTheme.bodyMedium,
                            ),
                          if (state.loading)
                            TamLoadingIndicator(
                              semanticLabel: t.supportLoading,
                            ),
                          if (state.failure != null) ...[
                            SupportFeedback(
                              failure: state.failure!,
                              onRetry: state.ended
                                  ? null
                                  : options == null
                                  ? () => cubit.load()
                                  : () => cubit.submit(),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                          if (options != null && !state.ended) ...[
                            if (options.tripId != null) ...[
                              SupportEditorTripReference(
                                text: t.supportEditorTripContext,
                              ),
                              const SizedBox(height: AppSpacing.xl),
                            ],
                            SupportEditorFieldHeading(
                              label: t.supportEditorCategory,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            SupportEditorCategoryPicker(
                              title: t.supportEditorCategory,
                              categories: options.categories,
                              selectedId: state.categoryId,
                              enabled: editable,
                              languageCode: t.localeName,
                              onSelected: cubit.categoryChanged,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            SupportEditorFieldHeading(label: t.supportBody),
                            const SizedBox(height: AppSpacing.sm),
                            SupportEditorDetailsField(
                              controller: _body,
                              hint: t.supportEditorPlaceholder,
                              enabled: editable,
                              length: state.body.trim().runes.length,
                              maxLength: cubit.policy.maxBodyCodePoints,
                              onChanged: cubit.bodyChanged,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              t.supportBodyHint,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (options != null && !state.ended && !state.locked)
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppSpacing.xl,
                          AppSpacing.sm,
                          AppSpacing.xl,
                          AppSpacing.lg,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 592),
                          child: TamButton.primary(
                            key: const Key('support-submit'),
                            label: t.supportSubmit,
                            loadingLabel: t.supportSending,
                            isLoading: state.sending,
                            onPressed: cubit.canSubmit ? cubit.submit : null,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
