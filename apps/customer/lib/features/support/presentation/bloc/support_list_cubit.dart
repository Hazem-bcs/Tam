import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/support_repository.dart';

final class SupportListState {
  SupportListState({
    Iterable<SupportTicket> tickets = const [],
    this.cursor,
    this.loading = true,
    this.loadingMore = false,
    this.failure,
    this.ended = false,
  }) : tickets = List.unmodifiable(tickets);
  final List<SupportTicket> tickets;
  final String? cursor;
  final bool loading, loadingMore, ended;
  final SupportFailure? failure;
}

final class SupportListCubit extends Cubit<SupportListState> {
  SupportListCubit(this._repository) : super(SupportListState()) {
    _subscription = _repository.changes.listen((change) {
      if (change.sessionReset) {
        _generation++;
        emit(SupportListState(loading: false, ended: true));
      } else {
        unawaited(load());
      }
    });
  }
  final SupportRepository _repository;
  late final StreamSubscription<SupportChange> _subscription;
  var _generation = 0;
  Future<void> load({bool more = false}) async {
    if (state.ended ||
        (more &&
            (state.loading || state.loadingMore || state.cursor == null))) {
      return;
    }
    final generation = ++_generation;
    final old = state;
    emit(
      SupportListState(
        tickets: old.tickets,
        cursor: old.cursor,
        loading: !more,
        loadingMore: more,
      ),
    );
    try {
      final page = await _repository.tickets(cursor: more ? old.cursor : null);
      if (!_current(generation)) return;
      final values = <String, SupportTicket>{
        for (final t in more ? old.tickets : <SupportTicket>[]) t.id: t,
      };
      for (final ticket in page.tickets) {
        final existing =
            values[ticket.id] ??
            old.tickets.where((t) => t.id == ticket.id).firstOrNull;
        values[ticket.id] =
            existing == null || ticket.revision >= existing.revision
            ? ticket
            : existing;
      }
      emit(
        SupportListState(
          tickets: values.values,
          cursor: page.nextCursor,
          loading: false,
        ),
      );
    } catch (error) {
      if (_current(generation)) {
        emit(
          SupportListState(
            tickets: old.tickets,
            cursor: old.cursor,
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
