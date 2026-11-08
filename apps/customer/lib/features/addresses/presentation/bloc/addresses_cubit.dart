import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/addresses_repository.dart';
import '../../domain/saved_address.dart';
import 'addresses_state.dart';

final class AddressesCubit extends Cubit<AddressesState> {
  AddressesCubit(this._repository) : super(const AddressesState()) {
    _subscription = _repository.changes.listen(
      (items) {
        ++_revision;
        if (!isClosed) {
          emit(
            state.copyWith(
              status: AddressesStatus.ready,
              items: List.unmodifiable(items),
              refreshing: false,
              failure: null,
            ),
          );
        }
      },
      onError: (Object error, StackTrace stack) {
        ++_revision;
        if (!isClosed) {
          emit(
            state.copyWith(
              status: state.items.isEmpty
                  ? AddressesStatus.error
                  : AddressesStatus.ready,
              refreshing: false,
              failure: _failure(error),
            ),
          );
        }
      },
    );
  }

  final AddressesRepository _repository;
  late final StreamSubscription<List<SavedAddress>> _subscription;
  int _revision = 0;

  AddressFailureCode _failure(Object error) =>
      error is AddressFailure ? error.code : AddressFailureCode.invalidResponse;

  Future<void> load({bool refresh = false}) async {
    if (isClosed || state.deletingId != null || state.refreshing) return;
    final revision = ++_revision;
    final retain = refresh && state.status == AddressesStatus.ready;
    emit(
      state.copyWith(
        status: retain ? AddressesStatus.ready : AddressesStatus.loading,
        refreshing: retain,
        failure: null,
      ),
    );
    try {
      final items = await _repository.list();
      if (isClosed || revision != _revision) return;
      emit(
        state.copyWith(
          status: AddressesStatus.ready,
          items: List.unmodifiable(items),
          refreshing: false,
        ),
      );
    } catch (error) {
      if (isClosed || revision != _revision) return;
      emit(
        state.copyWith(
          status: retain && state.items.isNotEmpty
              ? AddressesStatus.ready
              : AddressesStatus.error,
          refreshing: false,
          failure: _failure(error),
        ),
      );
    }
  }

  Future<void> delete(String id) async {
    if (isClosed || state.busy) return;
    ++_revision;
    emit(state.copyWith(deletingId: id, failure: null));
    try {
      await _repository.delete(id);
      if (isClosed) return;
      emit(state.copyWith(deletingId: null));
      await load(refresh: true);
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(deletingId: null, failure: _failure(error)));
      }
    }
  }

  @override
  Future<void> close() async {
    ++_revision;
    await _subscription.cancel();
    await super.close();
  }
}
