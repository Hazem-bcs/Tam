import '../domain/completion_repository.dart';

final class UnavailableCompletionRepository implements CompletionRepository {
  const UnavailableCompletionRepository();
  @override
  Stream<CompletionChange> get changes => const Stream.empty();
  @override
  Future<TripCompletion> fetch(String tripId) async =>
      throw const CompletionFailure('SERVICE_UNAVAILABLE');
  @override
  Future<TripCompletion> submitRating(
    String tripId, {
    required int stars,
    required String comment,
    required String idempotencyKey,
  }) async => throw const CompletionFailure('SERVICE_UNAVAILABLE');
}
