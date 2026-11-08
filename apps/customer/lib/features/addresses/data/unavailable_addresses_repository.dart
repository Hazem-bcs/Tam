import '../domain/addresses_repository.dart';
import '../domain/saved_address.dart';

final class UnavailableAddressesRepository implements AddressesRepository {
  const UnavailableAddressesRepository();
  Never _fail() => throw const AddressFailure(AddressFailureCode.unavailable);
  @override
  Stream<List<SavedAddress>> get changes => const Stream.empty();
  @override
  Future<List<SavedAddress>> list() async => _fail();
  @override
  Future<SavedAddress> get(String id) async => _fail();
  @override
  Future<SavedAddress> create(
    AddressInput input, {
    required String operationId,
  }) async => _fail();
  @override
  Future<SavedAddress> update(String id, AddressInput input) async => _fail();
  @override
  Future<void> delete(String id) async => _fail();
}
