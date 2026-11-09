import 'package:equatable/equatable.dart';
import 'package:tam_customer/shared/domain/trip.dart';

final class CompletionPolicy {
  const CompletionPolicy({this.maxCommentCodePoints = 500});
  final int maxCommentCodePoints;
  String validate(int stars, String comment) {
    final value = comment.trim();
    if (stars < 1 || stars > 5 || value.runes.length > maxCommentCodePoints) {
      throw const CompletionFailure('VALIDATION_ERROR');
    }
    return value;
  }
}

final class TripRating extends Equatable {
  const TripRating({
    required this.id,
    required this.tripId,
    required this.stars,
    required this.comment,
    required this.idempotencyKey,
    required this.submittedAt,
  });
  final String id, tripId, comment, idempotencyKey;
  final int stars;
  final DateTime submittedAt;
  @override
  List<Object?> get props => [
    id,
    tripId,
    stars,
    comment,
    idempotencyKey,
    submittedAt,
  ];
}

final class TripCompletion extends Equatable {
  const TripCompletion({
    required this.trip,
    required this.revision,
    this.rating,
  });
  final Trip trip;
  final TripRating? rating;
  final int revision;
  bool get canRate => trip.status == TripStatus.completed && rating == null;
  @override
  List<Object?> get props => [trip, revision, rating];
}

final class CompletionFailure implements Exception {
  const CompletionFailure(this.code, {this.uncertain = false});
  final String code;
  final bool uncertain;
}

final class CompletionChange {
  const CompletionChange({this.sessionReset = false});
  final bool sessionReset;
}

abstract interface class CompletionRepository {
  Future<TripCompletion> fetch(String tripId);
  Future<TripCompletion> submitRating(
    String tripId, {
    required int stars,
    required String comment,
    required String idempotencyKey,
  });
  Stream<CompletionChange> get changes;
}
