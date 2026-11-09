import 'dart:async';
import 'package:tam_customer/features/completion/domain/completion_repository.dart';
import 'package:tam_customer/shared/data/mock/seed_trips.dart';
import 'package:tam_customer/shared/domain/trip.dart';

final completionNow = DateTime.utc(2026, 11, 9, 12);
Trip completionTrip({
  String id = 'mock-history-001',
  TripStatus status = TripStatus.completed,
}) {
  final trip = seedMockTrips().first;
  return Trip(
    id: id,
    booking: trip.booking,
    createdAt: trip.createdAt,
    status: status,
  );
}

TripRating completionRating({
  String key = 'key-1',
  int stars = 4,
  String comment = 'رحلة مريحة',
  String tripId = 'mock-history-001',
}) => TripRating(
  id: '$tripId-rating',
  tripId: tripId,
  stars: stars,
  comment: comment,
  idempotencyKey: key,
  submittedAt: completionNow,
);
TripCompletion completionSnapshot({
  int revision = 1,
  TripRating? rating,
  Trip? trip,
}) => TripCompletion(
  trip: trip ?? completionTrip(),
  revision: revision,
  rating: rating,
);

final class ControlledCompletionRepository implements CompletionRepository {
  final events = StreamController<CompletionChange>.broadcast(sync: true);
  Future<TripCompletion> Function()? onFetch;
  Future<TripCompletion> Function(CompletionCall)? onSubmit;
  final calls = <CompletionCall>[];
  @override
  Future<TripCompletion> fetch(String tripId) =>
      onFetch?.call() ?? Future.value(completionSnapshot());
  @override
  Future<TripCompletion> submitRating(
    String tripId, {
    required int stars,
    required String comment,
    required String idempotencyKey,
  }) {
    final call = CompletionCall(tripId, stars, comment, idempotencyKey);
    calls.add(call);
    return onSubmit?.call(call) ??
        Future.value(
          completionSnapshot(
            revision: 2,
            rating: completionRating(
              key: idempotencyKey,
              stars: stars,
              comment: comment,
            ),
          ),
        );
  }

  @override
  Stream<CompletionChange> get changes => events.stream;
}

final class CompletionCall {
  const CompletionCall(this.tripId, this.stars, this.comment, this.key);
  final String tripId, comment, key;
  final int stars;
}

Future<void> completionFlush() => Future<void>.delayed(Duration.zero);
