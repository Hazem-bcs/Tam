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
  });

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
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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
          const SizedBox(height: AppSpacing.lg),
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
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l.completionQuickFeedbackHint,
                          style: text.labelMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
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
            const SizedBox(height: AppSpacing.lg),
            TamTextField(
              key: const ValueKey('completion-comment'),
              controller: _comment,
              labelText: l.completionComment,
              enabled: editable,
              maxLines: 3,
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
            const SizedBox(height: AppSpacing.lg),
            TamButton.primary(
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
          ],
        ],
      ),
    );
  }
}
