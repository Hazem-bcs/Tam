import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_text_field.dart';
import '../../domain/completion_repository.dart';
import '../bloc/completion_state.dart';
import 'completion_feedback_options.dart';
import 'completion_rating_stars.dart';
import 'completion_surface.dart';

class CompletionRatingForm extends StatefulWidget {
  const CompletionRatingForm({
    super.key,
    required this.state,
    required this.policy,
    required this.onSubmit,
    this.onSupport,
  });

  final VoidCallback? onSupport;
  final CompletionState state;
  final CompletionPolicy policy;
  final void Function(int, String) onSubmit;

  @override
  State<CompletionRatingForm> createState() => _CompletionRatingFormState();
}

class _CompletionRatingFormState extends State<CompletionRatingForm> {
  final _comment = TextEditingController();
  final Set<int> _tags = {};
  int _stars = 0;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  List<String> _suggestions(AppLocalizations l, int stars) => stars >= 4
      ? [
          l.completionTagDriverRespect,
          l.completionTagCleanCar,
          l.completionTagComfort,
        ]
      : [
          l.completionTagArrivalDelay,
          l.completionTagCarIssue,
          l.completionTagServiceIssue,
        ];

  String _reviewComment(BuildContext context, List<String> suggestions) {
    final chosen = _tags.toList()..sort();
    final parts = <String>[
      if (_comment.text.trim().isNotEmpty) _comment.text.trim(),
      for (final index in chosen) suggestions[index],
    ];
    return parts.join(
      Localizations.localeOf(context).languageCode == 'ar' ? '، ' : ', ',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = widget.state;
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final rating = state.completion?.rating;
    final selected = rating?.stars ?? state.intent?.stars ?? _stars;
    final editable = state.canEdit;
    final suggestions = _suggestions(l, selected);
    final composed = _reviewComment(context, suggestions);
    final withinLimit =
        composed.runes.length <= widget.policy.maxCommentCodePoints;

    return CompletionSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            liveRegion: rating != null,
            child: Text(
              rating == null ? l.completionRateTrip : l.completionSaved,
              textAlign: TextAlign.center,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          if (rating == null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              l.completionRateHint,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          CompletionRatingStars(
            value: selected,
            onChanged: editable
                ? (value) => setState(() {
                    _stars = value;
                    _tags.clear();
                  })
                : null,
          ),
          if (rating != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              l.completionStars(rating.stars),
              textAlign: TextAlign.center,
              style: text.bodyMedium,
            ),
            if (rating.comment.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(rating.comment, textAlign: TextAlign.center),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              l.completionImmutable,
              textAlign: TextAlign.center,
              style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            if (widget.onSupport != null) ...[
              const SizedBox(height: AppSpacing.md),
              _SupportAction(onPressed: widget.onSupport),
            ],
          ] else ...[
            AnimatedSize(
              duration: MediaQuery.of(context).disableAnimations
                  ? Duration.zero
                  : AppMotion.medium,
              curve: AppMotion.easeOut,
              alignment: Alignment.topCenter,
              child: selected == 0
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                selected >= 4
                                    ? l.completionQuickFeedbackHint
                                    : l.completionQuickFeedbackCritical,
                                style: text.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              l.completionFeedbackOptional,
                              style: text.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        CompletionFeedbackOptions(
                          labels: suggestions,
                          positive: selected >= 4,
                          selected: _tags,
                          enabled: editable,
                          onToggle: (index) => setState(() {
                            if (_tags.contains(index)) {
                              _tags.remove(index);
                            } else {
                              _tags.add(index);
                            }
                          }),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
            TamTextField(
              key: const ValueKey('completion-comment'),
              controller: _comment,
              labelText: l.completionComment,
              enabled: editable,
              maxLines: 2,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              onChanged: (_) => setState(() {}),
              errorText: withinLimit ? null : l.completionValidation,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l.completionCommentLimit(widget.policy.maxCommentCodePoints),
              style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.md),
            _RatingActions(
              onSupport: widget.onSupport,
              submitting: state.submitting,
              submit: TamButton.primary(
                key: const ValueKey('completion-submit'),
                label: l.completionSubmit,
                icon: Icons.send_outlined,
                loadingLabel: l.completionSubmitting,
                isLoading: state.submitting,
                onPressed: editable && selected > 0 && withinLimit
                    ? () {
                        FocusScope.of(context).unfocus();
                        widget.onSubmit(
                          selected,
                          _reviewComment(context, suggestions),
                        );
                      }
                    : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RatingActions extends StatelessWidget {
  const _RatingActions({
    required this.submit,
    required this.onSupport,
    required this.submitting,
  });
  final Widget submit;
  final VoidCallback? onSupport;
  final bool submitting;
  @override
  Widget build(BuildContext context) {
    if (onSupport == null) return submit;
    final support = _SupportAction(onPressed: submitting ? null : onSupport);
    return LayoutBuilder(
      builder: (context, bounds) {
        if (bounds.maxWidth >= 300 &&
            MediaQuery.textScalerOf(context).scale(1) < 1.4) {
          return Row(
            children: [
              Expanded(flex: 2, child: submit),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: support),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            submit,
            const SizedBox(height: AppSpacing.sm),
            support,
          ],
        );
      },
    );
  }
}

class _SupportAction extends StatelessWidget {
  const _SupportAction({required this.onPressed});
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    key: const Key('trips-support'),
    onPressed: onPressed,
    icon: Image.asset(
      'assets/notifications/support.webp',
      width: 24,
      height: 24,
      excludeFromSemantics: true,
    ),
    label: Text(AppLocalizations.of(context).completionSupportShort),
  );
}
