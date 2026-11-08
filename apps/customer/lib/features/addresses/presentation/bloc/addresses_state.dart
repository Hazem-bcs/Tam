import '../../domain/addresses_repository.dart';
import '../../domain/saved_address.dart';

enum AddressesStatus { loading, ready, error }

const _absent = Object();

final class AddressesState {
  const AddressesState({
    this.status = AddressesStatus.loading,
    this.items = const [],
    this.refreshing = false,
    this.deletingId,
    this.failure,
  });
  final AddressesStatus status;
  final List<SavedAddress> items;
  final bool refreshing;
  final String? deletingId;
  final AddressFailureCode? failure;
  bool get busy =>
      refreshing || deletingId != null || status == AddressesStatus.loading;

  AddressesState copyWith({
    AddressesStatus? status,
    List<SavedAddress>? items,
    bool? refreshing,
    Object? deletingId = _absent,
    Object? failure = _absent,
  }) => AddressesState(
    status: status ?? this.status,
    items: items ?? this.items,
    refreshing: refreshing ?? this.refreshing,
    deletingId: identical(deletingId, _absent)
        ? this.deletingId
        : deletingId as String?,
    failure: identical(failure, _absent)
        ? this.failure
        : failure as AddressFailureCode?,
  );
}
