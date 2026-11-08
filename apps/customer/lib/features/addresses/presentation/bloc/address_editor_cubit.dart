import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/shared/domain/trip.dart';

import '../../domain/addresses_repository.dart';
import '../../domain/saved_address.dart';
import 'address_editor_state.dart';

final class AddressEditorCubit extends Cubit<AddressEditorState> {
  AddressEditorCubit(
    this._repository,
    this._places, {
    this.id,
    String Function()? operationKeyFactory,
  }) : _operationKeyFactory = operationKeyFactory ?? _randomKey,
       super(const AddressEditorState());
  final AddressesRepository _repository;
  final AddressPlaceSearch _places;
  final String? id;
  final String Function() _operationKeyFactory;
  String? _operationId;
  AddressInput? _pendingInput;
  int _loadRevision = 0, _searchRevision = 0;

  static String _randomKey() {
    final random = Random.secure();
    return List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  AddressFailureCode _failure(Object error) =>
      error is AddressFailure ? error.code : AddressFailureCode.invalidResponse;

  Future<void> load() async {
    if (isClosed || state.phase == AddressEditorPhase.saving || state.dirty) {
      return;
    }
    final revision = ++_loadRevision;
    emit(state.copyWith(phase: AddressEditorPhase.loading, failure: null));
    try {
      final original = id == null ? null : await _repository.get(id!);
      if (isClosed || revision != _loadRevision) return;
      emit(
        state.copyWith(
          phase: AddressEditorPhase.ready,
          original: original,
          name: original?.input.name,
          icon: original?.input.icon,
          location: original?.input.location,
        ),
      );
    } catch (error) {
      if (isClosed || revision != _loadRevision) return;
      final failure = _failure(error);
      emit(
        state.copyWith(
          phase: failure == AddressFailureCode.notFound
              ? AddressEditorPhase.notFound
              : AddressEditorPhase.error,
          failure: failure,
        ),
      );
    }
  }

  void nameChanged(String value) {
    if (!isClosed && !state.locked) {
      emit(state.copyWith(name: value, failure: null));
    }
  }

  void iconChanged(AddressIcon value) {
    if (!isClosed && !state.locked) {
      emit(state.copyWith(icon: value, failure: null));
    }
  }

  void locationSelected(TripLocation value) {
    if (!isClosed && !state.locked) {
      emit(state.copyWith(location: value, failure: null));
    }
  }

  Future<void> search(String query) async {
    if (isClosed || state.locked) return;
    final revision = ++_searchRevision;
    emit(state.copyWith(searching: true, searchFailure: null));
    try {
      final suggestions = await _places.search(query);
      if (isClosed || revision != _searchRevision) return;
      emit(
        state.copyWith(
          suggestions: List.unmodifiable(suggestions),
          searching: false,
        ),
      );
    } catch (error) {
      if (isClosed || revision != _searchRevision) return;
      emit(
        state.copyWith(
          suggestions: const [],
          searching: false,
          searchFailure: _failure(error),
        ),
      );
    }
  }

  Future<void> save() async {
    if (isClosed || state.busy || state.phase == AddressEditorPhase.saved) {
      return;
    }
    if (!state.valid) {
      emit(state.copyWith(validationAttempted: true));
      return;
    }
    final input =
        _pendingInput ??
        AddressInput(
          name: state.name,
          icon: state.icon,
          location: state.location!,
        );
    _pendingInput = input;
    _operationId ??= _operationKeyFactory();
    ++_loadRevision;
    ++_searchRevision;
    emit(
      state.copyWith(
        phase: AddressEditorPhase.saving,
        failure: null,
        searching: false,
      ),
    );
    try {
      final saved = id == null
          ? await _repository.create(input, operationId: _operationId!)
          : await _repository.update(id!, input);
      if (isClosed) return;
      emit(
        state.copyWith(
          phase: AddressEditorPhase.saved,
          original: saved,
          retryPending: false,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      final failure = _failure(error);
      final uncertain =
          failure == AddressFailureCode.network ||
          failure == AddressFailureCode.invalidResponse;
      if (!uncertain) {
        _pendingInput = null;
        _operationId = null;
      }
      emit(
        state.copyWith(
          phase: failure == AddressFailureCode.notFound
              ? AddressEditorPhase.notFound
              : AddressEditorPhase.ready,
          failure: failure,
          retryPending: uncertain,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    ++_loadRevision;
    ++_searchRevision;
    return super.close();
  }
}
