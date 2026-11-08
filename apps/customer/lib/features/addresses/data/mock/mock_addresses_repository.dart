import 'dart:async';

import '../../domain/addresses_repository.dart';
import '../../domain/saved_address.dart';
import 'addresses_fixture.dart';

enum AddressOperation { list, get, create, update, delete }

final class MockAddressesRepository implements AddressesRepository {
  MockAddressesRepository({
    List<SavedAddress>? seed,
    DateTime Function()? clock,
  }) : _seed = List.unmodifiable(seed ?? seedAddresses()),
       _clock = clock ?? DateTime.now {
    if (_seed.length > AddressesRepository.maxAddresses ||
        _seed.map((item) => item.id).toSet().length != _seed.length) {
      throw ArgumentError('Invalid address seed');
    }
    _items = {for (final item in _seed) item.id: item};
  }

  final List<SavedAddress> _seed;
  final DateTime Function() _clock;
  late final Map<String, SavedAddress> _items;
  final _changes = StreamController<List<SavedAddress>>.broadcast(sync: true);
  final Map<String, SavedAddress> _creations = {};
  final Set<AddressOperation> _failures = {};
  var _sequence = 0;
  var _disposed = false;
  bool loseNextCreateResponse = false;

  bool get hasListeners => _changes.hasListener;
  void failOnce(AddressOperation operation) => _failures.add(operation);
  @override
  Stream<List<SavedAddress>> get changes => _changes.stream;

  void _check(AddressOperation operation) {
    if (_disposed) throw StateError('Address repository disposed');
    if (_failures.remove(operation)) {
      throw const AddressFailure(AddressFailureCode.network);
    }
  }

  List<SavedAddress> get _snapshot {
    final result = _items.values.toList()
      ..sort((a, b) {
        final date = b.createdAt.compareTo(a.createdAt);
        return date == 0 ? a.id.compareTo(b.id) : date;
      });
    return List.unmodifiable(result);
  }

  void resetSession() {
    if (_disposed) return;
    _items
      ..clear()
      ..addAll({for (final item in _seed) item.id: item});
    _creations.clear();
    _failures.clear();
    loseNextCreateResponse = false;
    _changes.add(_snapshot);
  }

  @override
  Future<List<SavedAddress>> list() async {
    _check(AddressOperation.list);
    return _snapshot;
  }

  @override
  Future<SavedAddress> get(String id) async {
    _check(AddressOperation.get);
    return _find(id);
  }

  SavedAddress _find(String id) =>
      _items[id] ?? (throw const AddressFailure(AddressFailureCode.notFound));

  @override
  Future<SavedAddress> create(
    AddressInput input, {
    required String operationId,
  }) async {
    _check(AddressOperation.create);
    if (operationId.trim().isEmpty || operationId.length > 128) {
      throw const AddressFailure(AddressFailureCode.validation);
    }
    final previous = _creations[operationId];
    if (previous != null) {
      if (previous.input != input) {
        throw const AddressFailure(AddressFailureCode.idempotencyConflict);
      }
      return _find(previous.id);
    }
    if (_items.length >= AddressesRepository.maxAddresses) {
      throw const AddressFailure(AddressFailureCode.limitReached);
    }
    String id;
    do {
      id = 'mock-address-${++_sequence}';
    } while (_items.containsKey(id));
    final now = _clock().toUtc();
    final item = SavedAddress(
      id: id,
      input: input,
      createdAt: now,
      updatedAt: now,
    );
    _items[id] = item;
    _creations[operationId] = item;
    _changes.add(_snapshot);
    if (loseNextCreateResponse) {
      loseNextCreateResponse = false;
      throw const AddressFailure(AddressFailureCode.network);
    }
    return item;
  }

  @override
  Future<SavedAddress> update(String id, AddressInput input) async {
    _check(AddressOperation.update);
    final previous = _find(id);
    if (previous.input == input) return previous;
    final now = _clock().toUtc();
    final item = SavedAddress(
      id: id,
      input: input,
      createdAt: previous.createdAt,
      updatedAt: now.isBefore(previous.updatedAt) ? previous.updatedAt : now,
    );
    _items[id] = item;
    _changes.add(_snapshot);
    return item;
  }

  @override
  Future<void> delete(String id) async {
    _check(AddressOperation.delete);
    if (_items.remove(id) != null) _changes.add(_snapshot);
  }

  Future<void> dispose() async {
    _disposed = true;
    await _changes.close();
  }
}
