import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/support_repository.dart';

final class SupportDetailState {
  const SupportDetailState({
    this.ticket,
    this.loading = true,
    this.failure,
    this.ended = false,
  });
  final SupportTicket? ticket;
  final bool loading, ended;
  final SupportFailure? failure;
}

final class SupportDetailCubit extends Cubit<SupportDetailState> {
  SupportDetailCubit(this._repository, this.id)
    : super(const SupportDetailState()) {
    _subscription = _repository.changes.listen((change) {
      if (change.sessionReset) {
        _generation++;
        emit(const SupportDetailState(loading: false, ended: true));
      }
    });
  }
  final SupportRepository _repository;
  final String id;
  late final StreamSubscription<SupportChange> _subscription;
  var _generation = 0;
  Future<void> load() async {
    if (state.ended) return;
    final generation = ++_generation;
    emit(SupportDetailState(ticket: state.ticket));
    try {
      final value = await _repository.ticket(id);
      if (!_current(generation)) return;
      if (value.id != id) throw const SupportFailure('INVALID_RESPONSE');
      final old = state.ticket;
      emit(
        SupportDetailState(
          ticket: old != null && old.revision > value.revision ? old : value,
          loading: false,
        ),
      );
    } catch (error) {
      if (_current(generation)) {
        emit(
          SupportDetailState(
            ticket: state.ticket,
            loading: false,
            failure: error is SupportFailure
                ? error
                : const SupportFailure('SERVICE_UNAVAILABLE'),
          ),
        );
      }
    }
  }

  bool _current(int generation) =>
      !isClosed && generation == _generation && !state.ended;
  @override
  Future<void> close() async {
    _generation++;
    await _subscription.cancel();
    return super.close();
  }
}
