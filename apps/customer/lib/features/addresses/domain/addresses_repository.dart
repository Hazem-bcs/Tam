import 'package:tam_customer/shared/domain/trip.dart';
import 'saved_address.dart';

enum AddressFailureCode {
  unavailable,
  network,
  notFound,
  validation,
  limitReached,
  idempotencyConflict,
  invalidResponse,
}

final class AddressFailure implements Exception {
  const AddressFailure(this.code);
  final AddressFailureCode code;
}

/// A bounded address book, shared across management and booking selectors.
abstract interface class AddressesRepository {
  static const maxAddresses = 50;
  Future<List<SavedAddress>> list();
  Future<SavedAddress> get(String id);
  Future<SavedAddress> create(
    AddressInput input, {
    required String operationId,
  });
  Future<SavedAddress> update(String id, AddressInput input);
  Future<void> delete(String id);
  Stream<List<SavedAddress>> get changes;
}

/// Reuses the existing places service; saved addresses do not own a new search.
abstract interface class AddressPlaceSearch {
  Future<List<TripLocation>> search(String query);
}
