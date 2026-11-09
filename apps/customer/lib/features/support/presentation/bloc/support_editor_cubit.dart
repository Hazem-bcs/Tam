import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/support_repository.dart';
import 'support_editor_state.dart';
export 'support_editor_state.dart';

final class SupportEditorCubit extends Cubit<SupportEditorState> {
  SupportEditorCubit(
    this._repository, {
    required this.policy,
    required this.now,
    this.tripId,
  }) : super(const SupportEditorState()) {
    _subscription = _repository.changes.listen((change) {
      if (change.sessionReset) {
        _generation++;
        _pending = null;
        emit(const SupportEditorState(loading: false, ended: true));
      }
    });
  }
  final SupportRepository _repository;
  final SupportPolicy policy;
  final DateTime Function() now;
  final String? tripId;
  late final StreamSubscription<SupportChange> _subscription;
  int _generation = 0;
  ({String id, String body, String category})? _pending;

  Future<void> load() async {
    if (state.ended || state.sending || state.locked) return;
    final generation = ++_generation;
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      final result = await _repository.options(tripId: tripId);
      if (!_current(generation)) return;
      if (result.tripId != tripId ||
          result.categories.isEmpty ||
          result.categories.any((c) => c.tripRequired && tripId == null)) {
        throw const SupportFailure('INVALID_RESPONSE');
      }
      emit(
        state.copyWith(
          options: result,
          categoryId: state.categoryId ?? result.categories.first.id,
          loading: false,
        ),
      );
    } catch (error) {
      if (_current(generation)) {
        emit(state.copyWith(loading: false, failure: _failure(error)));
      }
    }
  }

  void bodyChanged(String value) {
    if (_editable) {
      _pending = null;
      emit(state.copyWith(body: value, clearFailure: true));
    }
  }

  void categoryChanged(String value) {
    if (_editable) {
      _pending = null;
      emit(state.copyWith(categoryId: value, clearFailure: true));
    }
  }

  bool get _editable =>
      !state.loading &&
      !state.sending &&
      !state.locked &&
      !state.ended &&
      state.accepted == null;
  bool get canSubmit {
    if (!_editable || state.options == null || state.categoryId == null) {
      return false;
    }
    try {
      policy.validateBody(state.body);
      policy.validateCategory(state.options!, state.categoryId!);
      return true;
    } on SupportFailure {
      return false;
    }
  }

  Future<void> submit() async {
    if (state.sending ||
        state.ended ||
        state.accepted != null ||
        state.options == null) {
      return;
    }
    if (!state.locked && !canSubmit) {
      emit(state.copyWith(failure: const SupportFailure('VALIDATION_ERROR')));
      return;
    }
    _pending ??= (
      id: _requestId(),
      body: policy.validateBody(state.body),
      category: state.categoryId!,
    );
    final pending = _pending!;
    final generation = ++_generation;
    emit(state.copyWith(sending: true, clearFailure: true));
    try {
      final result = await _repository.create(
        clientRequestId: pending.id,
        categoryId: pending.category,
        body: pending.body,
        tripId: tripId,
      );
      if (!_current(generation)) return;
      if (result.clientRequestId != pending.id ||
          result.categoryId != pending.category ||
          result.body != pending.body ||
          result.tripId != tripId ||
          result.id.trim().isEmpty ||
          result.revision < 1 ||
          result.updatedAt.isBefore(result.createdAt)) {
        throw const SupportFailure('INVALID_RESPONSE', uncertain: true);
      }
      emit(
        state.copyWith(
          sending: false,
          locked: false,
          accepted: result,
          clearFailure: true,
        ),
      );
    } catch (error) {
      if (!_current(generation)) return;
      final failure = _failure(error);
      // Unknown failures cannot prove that the server rejected the operation.
      final uncertain =
          state.locked || failure.uncertain || error is! SupportFailure;
      emit(
        state.copyWith(
          sending: false,
          locked: uncertain,
          failure: SupportFailure(failure.code, uncertain: uncertain),
        ),
      );
    }
  }

  String _requestId() {
    final random = Random.secure();
    return List.generate(
      24,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  SupportFailure _failure(Object error) => error is SupportFailure
      ? error
      : const SupportFailure('SERVICE_UNAVAILABLE', uncertain: true);
  bool _current(int generation) =>
      !isClosed && generation == _generation && !state.ended;
  @override
  Future<void> close() async {
    _generation++;
    _pending = null;
    await _subscription.cancel();
    return super.close();
  }
}
