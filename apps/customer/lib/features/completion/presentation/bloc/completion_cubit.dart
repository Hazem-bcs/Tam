import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import '../../domain/completion_repository.dart';
import 'completion_state.dart';
export 'completion_state.dart';

final class CompletionCubit extends Cubit<CompletionState> {
  CompletionCubit(
    this.repository, {
    required this.tripId,
    this.policy = const CompletionPolicy(),
    DateTime Function()? now,
    String Function()? createIdempotencyKey,
  }) : _createKey = createIdempotencyKey ?? _randomKey,
       super(const CompletionState(loading: true)) {
    _subscription = repository.changes.listen((change) {
      if (change.sessionReset) {
        _epoch++;
        emit(
          const CompletionState(sessionEnded: true, failure: 'SESSION_ENDED'),
        );
      } else if (!state.sessionEnded) {
        refresh();
      }
    });
    refresh();
  }
  final CompletionRepository repository;
  final String tripId;
  final CompletionPolicy policy;
  final String Function() _createKey;
  late final StreamSubscription<CompletionChange> _subscription;
  int _epoch = 0, _read = 0;
  bool _identityLost = false;
  static String _randomKey() {
    final random = Random.secure();
    return List.generate(
      24,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  bool _valid(int epoch) => !isClosed && !state.sessionEnded && epoch == _epoch;
  void _update({
    TripCompletion? completion,
    CompletionIntent? intent,
    bool clearIntent = false,
    bool? loading,
    bool? submitting,
    bool? uncertain,
    String? failure,
  }) => emit(
    CompletionState(
      completion: completion ?? state.completion,
      intent: clearIntent ? null : intent ?? state.intent,
      loading: loading ?? state.loading,
      submitting: submitting ?? state.submitting,
      uncertain: uncertain ?? state.uncertain,
      failure: failure,
    ),
  );

  TripCompletion _accept(TripCompletion incoming) {
    final old = state.completion;
    final rating = incoming.rating;
    if (_identityLost ||
        incoming.trip.id != tripId ||
        incoming.revision < 1 ||
        incoming.trip.status != TripStatus.completed ||
        (rating != null && rating.tripId != tripId) ||
        (old != null &&
            (old.trip.booking != incoming.trip.booking ||
                old.trip.createdAt != incoming.trip.createdAt))) {
      _identityLost = true;
      throw const CompletionFailure('INVALID_RESPONSE');
    }
    if (rating != null &&
        (rating.id.trim().isEmpty ||
            rating.idempotencyKey.trim().isEmpty ||
            rating.stars < 1 ||
            rating.stars > 5 ||
            rating.comment != rating.comment.trim() ||
            rating.comment.runes.length > policy.maxCommentCodePoints ||
            rating.submittedAt.isBefore(
              incoming.trip.live?.statusChangedAt ?? incoming.trip.createdAt,
            ))) {
      throw const CompletionFailure('INVALID_RESPONSE');
    }
    final intent = state.intent;
    if (rating != null &&
        intent != null &&
        rating.idempotencyKey == intent.idempotencyKey &&
        !intent.matches(rating)) {
      throw const CompletionFailure('INVALID_RESPONSE');
    }
    if (old != null && incoming.revision < old.revision) return old;
    if (old != null && incoming.revision == old.revision && incoming != old) {
      throw const CompletionFailure('INVALID_RESPONSE');
    }
    if (old?.rating != null && old!.rating != rating) {
      throw const CompletionFailure('INVALID_RESPONSE');
    }
    return incoming;
  }

  Future<void> refresh() async {
    if (isClosed || state.sessionEnded || _identityLost) return;
    final epoch = _epoch, read = ++_read;
    final revision = state.completion?.revision;
    _update(loading: state.completion == null, failure: state.failure);
    try {
      final incoming = await repository.fetch(tripId);
      if (!_valid(epoch) || read != _read) return;
      final completion = _accept(incoming);
      final resolved = completion.rating != null;
      _update(
        completion: completion,
        loading: false,
        clearIntent: resolved,
        uncertain: resolved ? false : state.uncertain,
      );
    } on CompletionFailure catch (failure) {
      if (_valid(epoch) &&
          read == _read &&
          revision == state.completion?.revision) {
        _update(loading: false, failure: failure.code);
      }
    } catch (_) {
      if (_valid(epoch) &&
          read == _read &&
          revision == state.completion?.revision) {
        _update(loading: false, failure: 'INVALID_RESPONSE');
      }
    }
  }

  Future<void> submit(int stars, String comment) async {
    if (!state.canEdit || _identityLost) return;
    try {
      final value = policy.validate(stars, comment);
      final intent = CompletionIntent(stars, value, _createKey());
      _update(intent: intent);
      await _submit(intent);
    } on CompletionFailure catch (failure) {
      if (!isClosed && !state.sessionEnded) _update(failure: failure.code);
    }
  }

  Future<void> retry() async {
    if (isClosed || state.sessionEnded || state.submitting || _identityLost) {
      return;
    }
    final intent = state.intent;
    await refresh();
    if (isClosed ||
        state.sessionEnded ||
        state.completion?.rating != null ||
        _identityLost ||
        intent == null) {
      return;
    }
    await _submit(intent);
  }

  Future<void> _submit(CompletionIntent intent) async {
    if (state.submitting || state.completion?.rating != null) return;
    final epoch = _epoch;
    _update(submitting: true, uncertain: false);
    try {
      final incoming = await repository.submitRating(
        tripId,
        stars: intent.stars,
        comment: intent.comment,
        idempotencyKey: intent.idempotencyKey,
      );
      if (!_valid(epoch)) return;
      if (incoming.rating == null ||
          !intent.matches(incoming.rating!) ||
          incoming.rating!.tripId != tripId) {
        throw const CompletionFailure('INVALID_RESPONSE', uncertain: true);
      }
      final completion = _accept(incoming);
      _update(
        completion: completion,
        clearIntent: true,
        submitting: false,
        uncertain: false,
      );
    } on CompletionFailure catch (failure) {
      if (!_valid(epoch)) return;
      // A read can already have reconciled a successful write with a lost ack.
      if (state.completion?.rating != null) {
        _update(submitting: false, uncertain: false, clearIntent: true);
        return;
      }
      _update(
        submitting: false,
        uncertain: failure.uncertain,
        failure: failure.code,
      );
      if ({
        'RATING_ALREADY_SUBMITTED',
        'TRIP_NOT_COMPLETED',
      }.contains(failure.code)) {
        await refresh();
      }
    } catch (_) {
      if (_valid(epoch)) {
        if (state.completion?.rating != null) {
          _update(submitting: false, uncertain: false, clearIntent: true);
        } else {
          _update(submitting: false, uncertain: true, failure: 'NETWORK_ERROR');
        }
      }
    }
  }

  @override
  Future<void> close() async {
    _epoch++;
    await _subscription.cancel();
    return super.close();
  }
}
