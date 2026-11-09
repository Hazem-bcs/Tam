import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_card.dart';
import 'package:tam_customer/shared/widgets/tam_text_field.dart';
import '../../domain/completion_repository.dart';
import '../bloc/completion_state.dart';

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
  int _stars = 0;
  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), state = widget.state;
    final rating = state.completion?.rating;
    final selected = rating?.stars ?? state.intent?.stars ?? _stars;
    final editable = state.canEdit;
    return TamCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            liveRegion: rating != null,
            child: Text(
              rating == null ? l.completionRateTrip : l.completionSaved,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              for (var value = 1; value <= 5; value++)
                Semantics(
                  label: l.completionStars(value),
                  selected: selected == value,
                  child: IconButton(
                    key: ValueKey('completion-stars-$value'),
                    tooltip: l.completionStars(value),
                    onPressed: editable
                        ? () => setState(() => _stars = value)
                        : null,
                    icon: Icon(
                      value <= selected ? Icons.star : Icons.star_border,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: AppDimensions.minTapTarget,
                      minHeight: AppDimensions.minTapTarget,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (rating != null) ...[
            Text(l.completionStars(rating.stars)),
            if (rating.comment.isNotEmpty) Text(rating.comment),
            Text(
              l.completionImmutable,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ] else ...[
            TamTextField(
              key: const ValueKey('completion-comment'),
              controller: _comment,
              labelText: l.completionComment,
              helperText: l.completionCommentLimit(
                widget.policy.maxCommentCodePoints,
              ),
              enabled: editable,
              maxLines: 4,
              keyboardType: TextInputType.multiline,
              onChanged: (_) => setState(() {}),
              errorText:
                  _comment.text.trim().runes.length >
                      widget.policy.maxCommentCodePoints
                  ? l.completionValidation
                  : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            TamButton.primary(
              key: const ValueKey('completion-submit'),
              label: l.completionSubmit,
              loadingLabel: l.completionSubmitting,
              isLoading: state.submitting,
              onPressed:
                  editable &&
                      selected > 0 &&
                      _comment.text.trim().runes.length <=
                          widget.policy.maxCommentCodePoints
                  ? () {
                      FocusScope.of(context).unfocus();
                      widget.onSubmit(_stars, _comment.text);
                    }
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}
