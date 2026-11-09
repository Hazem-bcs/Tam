import 'package:tam_customer/shared/data/trip_wire_codec.dart';
import 'package:tam_customer/shared/data/utc_timestamp.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import '../domain/completion_repository.dart';

/// Proposed v1 envelope. A future HTTP adapter must validate at this boundary.
abstract final class CompletionCodec {
  static Map<String, dynamic> _object(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Expected object');
    }
    return value;
  }

  static String _text(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Invalid $field');
    }
    return value;
  }

  static TripCompletion decode(
    Map<String, dynamic> envelope, {
    CompletionPolicy policy = const CompletionPolicy(),
  }) {
    if (envelope.containsKey('error')) {
      throw const FormatException('Expected success envelope');
    }
    final data = _object(envelope['data']);
    final revision = data['revision'];
    if (data['version'] != 1 ||
        revision is! int ||
        revision < 1 ||
        !data.containsKey('rating')) {
      throw const FormatException('Invalid completion version/revision/rating');
    }
    final trip = TripWireCodec.fromJson(_object(data['trip']));
    if (trip.status != TripStatus.completed) {
      throw const FormatException('Completion requires completed trip');
    }
    TripRating? rating;
    if (data['rating'] != null) {
      final value = _object(data['rating']);
      final stars = value['stars'], comment = value['comment'];
      if (stars is! int ||
          comment is! String ||
          stars < 1 ||
          stars > 5 ||
          comment != comment.trim() ||
          comment.runes.length > policy.maxCommentCodePoints) {
        throw const FormatException('Invalid rating payload');
      }
      final tripId = _text(value, 'trip_id');
      final submittedAt = UtcTimestamp.parse(value['submitted_at']);
      if (tripId != trip.id ||
          submittedAt.isBefore(trip.live?.statusChangedAt ?? trip.createdAt)) {
        throw const FormatException('Invalid rating identity/time');
      }
      rating = TripRating(
        id: _text(value, 'id'),
        tripId: tripId,
        stars: stars,
        comment: comment,
        idempotencyKey: _text(value, 'idempotency_key'),
        submittedAt: submittedAt,
      );
    }
    return TripCompletion(trip: trip, revision: revision, rating: rating);
  }

  static Map<String, dynamic> encode(TripCompletion completion) => {
    'data': {
      'version': 1,
      'revision': completion.revision,
      'trip': TripWireCodec.toJson(completion.trip),
      'rating': completion.rating == null
          ? null
          : {
              'id': completion.rating!.id,
              'trip_id': completion.rating!.tripId,
              'stars': completion.rating!.stars,
              'comment': completion.rating!.comment,
              'idempotency_key': completion.rating!.idempotencyKey,
              'submitted_at': completion.rating!.submittedAt
                  .toUtc()
                  .toIso8601String(),
            },
    },
  };

  static CompletionFailure failure(Map<String, dynamic> envelope) {
    if (envelope.containsKey('data')) {
      throw const FormatException('Expected error envelope');
    }
    final error = _object(envelope['error']);
    final message = _object(error['message']);
    _text(message, 'ar');
    _text(message, 'en');
    return CompletionFailure(_text(error, 'code'));
  }
}
