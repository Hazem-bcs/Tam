import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';
import 'package:tam_customer/shared/widgets/tam_text_field.dart';
import '../bloc/support_editor_cubit.dart';
import '../widgets/support_editor_sections.dart';
import '../widgets/support_feedback.dart';

/// A single, focused editor surface; domain validation and submission stay in Cubit.
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
        final editable =
            !state.loading &&
            !state.sending &&
            !state.locked &&
            !state.ended &&
            state.accepted == null;
        final options = state.options;

        return Scaffold(
          backgroundColor: colors.surface,
          appBar: AppBar(
            backgroundColor: colors.surface,
            surfaceTintColor: colors.surface,
            scrolledUnderElevation: 0,
            centerTitle: true,
            title: Text(t.supportNewTicket),
            leading: BackButton(onPressed: widget.onBack),
          ),
          body: SafeArea(
            bottom: true,
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
                          const SizedBox(height: AppSpacing.xl),
                          SupportEditorNotice(text: t.supportSimulationNotice),
                          const SizedBox(height: AppSpacing.xl),
                          if (state.ended) ...[
                            Text(
                              t.supportSessionEnded,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
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
                              icon: Icons.chat_bubble_outline_rounded,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            DropdownButtonFormField<String>(
                              key: const Key('support-category'),
                              initialValue: state.categoryId,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: colors.surfaceContainerLowest,
                              ),
                              items: options.categories
                                  .map(
                                    (category) => DropdownMenuItem<String>(
                                      value: category.id,
                                      child: Text(
                                        t.localeName.startsWith('ar')
                                            ? category.nameAr
                                            : category.nameEn,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: editable
                                  ? (value) {
                                      if (value != null) {
                                        cubit.categoryChanged(value);
                                      }
                                    }
                                  : null,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            SupportEditorFieldHeading(
                              label: t.supportBody,
                              icon: Icons.edit_outlined,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TamTextField(
                              key: const Key('support-body'),
                              labelText: t.supportBody,
                              hintText: t.supportEditorPlaceholder,
                              controller: _body,
                              enabled: editable,
                              maxLines: 6,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              onChanged: cubit.bodyChanged,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: AppSpacing.lg,
                              runSpacing: AppSpacing.xs,
                              children: [
                                Text(
                                  t.supportBodyHint,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(
                                    '${state.body.trim().runes.length} / ${cubit.policy.maxBodyCodePoints}',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    if (options != null && !state.ended && !state.locked)
                      Container(
                        decoration: BoxDecoration(
                          color: colors.surface,
                          border: Border(
                            top: BorderSide(color: colors.outlineVariant),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            AppSpacing.xl,
                            AppSpacing.md,
                            AppSpacing.xl,
                            AppSpacing.md,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 592),
                            child: TamButton.primary(
                              key: const Key('support-submit'),
                              label: t.supportSubmit,
                              icon: Icons.send_rounded,
                              loadingLabel: t.supportSending,
                              isLoading: state.sending,
                              onPressed: cubit.canSubmit ? cubit.submit : null,
                            ),
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
