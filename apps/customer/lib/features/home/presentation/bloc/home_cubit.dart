import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/features/home/domain/entities/home_content.dart';
import 'package:tam_customer/features/home/domain/repositories/home_repository.dart';

enum HomeLoadStatus { initial, loading, ready, empty, failure }

final class HomeState {
  const HomeState({required this.status, this.content, this.failure});
  const HomeState.initial()
    : status = HomeLoadStatus.initial,
      content = null,
      failure = null;
  final HomeLoadStatus status;
  final HomeContent? content;
  final HomeFailureCode? failure;
}

final class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(const HomeState.initial());
  final HomeRepository _repository;
  bool _loading = false;

  Future<void> load() async {
    if (isClosed || _loading) return;
    _loading = true;
    emit(const HomeState(status: HomeLoadStatus.loading));
    try {
      final value = await _repository.load();
      if (!isClosed) {
        emit(
          HomeState(
            status: value.isEmpty ? HomeLoadStatus.empty : HomeLoadStatus.ready,
            content: value,
          ),
        );
      }
    } on HomeFailure catch (error) {
      if (!isClosed) {
        emit(HomeState(status: HomeLoadStatus.failure, failure: error.code));
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          const HomeState(
            status: HomeLoadStatus.failure,
            failure: HomeFailureCode.invalidResponse,
          ),
        );
      }
    } finally {
      _loading = false;
    }
  }
}
