import '../../domain/completion_repository.dart';

final class CompletionIntent {
  const CompletionIntent(this.stars, this.comment, this.idempotencyKey);
  final int stars;
  final String comment, idempotencyKey;
  bool matches(TripRating rating) =>
      rating.stars == stars &&
      rating.comment == comment &&
      rating.idempotencyKey == idempotencyKey;
}

final class CompletionState {
  const CompletionState({
    this.completion,
    this.loading = false,
    this.submitting = false,
    this.uncertain = false,
    this.sessionEnded = false,
    this.failure,
    this.intent,
  });
  final TripCompletion? completion;
  final CompletionIntent? intent;
  final bool loading, submitting, uncertain, sessionEnded;
  final String? failure;
  bool get canEdit =>
      !sessionEnded &&
      !submitting &&
      intent == null &&
      completion?.canRate == true;
}
