import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/support_repository.dart';

final class LegalState {
  const LegalState({this.document, this.loading = true, this.failure});
  final LegalDocument? document;
  final bool loading;
  final SupportFailure? failure;
}

final class LegalCubit extends Cubit<LegalState> {
  LegalCubit(this._repository, {required this.kind, required this.languageCode})
    : super(const LegalState());
  final SupportRepository _repository;
  final LegalDocumentKind kind;
  final String languageCode;
  var _generation = 0;
  Future<void> load() async {
    final generation = ++_generation;
    emit(LegalState(document: state.document));
    try {
      final result = await _repository.legal(kind, languageCode: languageCode);
      if (isClosed || generation != _generation) return;
      if (result != null &&
          (result.kind != kind ||
              result.languageCode != languageCode ||
              result.plainText.trim().isEmpty ||
              result.version.trim().isEmpty)) {
        throw const SupportFailure('INVALID_RESPONSE');
      }
      emit(LegalState(document: result, loading: false));
    } catch (error) {
      if (!isClosed && generation == _generation) {
        emit(
          LegalState(
            document: state.document,
            loading: false,
            failure: error is SupportFailure
                ? error
                : const SupportFailure('SERVICE_UNAVAILABLE'),
          ),
        );
      }
    }
  }

  @override
  Future<void> close() {
    _generation++;
    return super.close();
  }
}
