import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/addresses/data/mock/addresses_fixture.dart';
import 'package:tam_customer/features/addresses/data/mock/mock_addresses_repository.dart';
import 'package:tam_customer/features/addresses/domain/addresses_repository.dart';
import 'package:tam_customer/features/addresses/domain/saved_address.dart';
import 'package:tam_customer/features/addresses/presentation/bloc/address_editor_cubit.dart';
import 'package:tam_customer/features/addresses/presentation/bloc/addresses_cubit.dart';
import 'addresses_test_support.dart';

final class _ControlledRepository implements AddressesRepository {
  final source = MockAddressesRepository();
  final reads = <Completer<List<SavedAddress>>>[];
  final gets = <Completer<SavedAddress>>[];
  @override
  Stream<List<SavedAddress>> get changes => source.changes;
  @override
  Future<List<SavedAddress>> list() => (reads..add(Completer())).last.future;
  @override
  Future<SavedAddress> get(String id) => (gets..add(Completer())).last.future;
  @override
  Future<SavedAddress> create(
    AddressInput input, {
    required String operationId,
  }) => source.create(input, operationId: operationId);
  @override
  Future<SavedAddress> update(String id, AddressInput input) =>
      source.update(id, input);
  @override
  Future<void> delete(String id) => source.delete(id);
}

void main() {
  test('a repository change supersedes an older list request', () async {
    final repository = _ControlledRepository();
    final cubit = AddressesCubit(repository);
    final loading = cubit.load();
    final input = seedAddresses().first.input;
    final created = await repository.create(input, operationId: 'key');
    repository.reads.single.complete(seedAddresses());
    await loading;
    expect(cubit.state.items.any((item) => item.id == created.id), true);
    await cubit.close();
    await repository.source.dispose();
  });

  test(
    'editor ignores a stale load, preserves dirty changes, and survives closing',
    () async {
      final repository = _ControlledRepository();
      final cubit = AddressEditorCubit(
        repository,
        AddressTestPlaces(),
        id: 'id',
      );
      final old = cubit.load();
      final latest = cubit.load();
      repository.gets.last.complete(seedAddresses().last);
      await latest;
      cubit.nameChanged('Draft name');
      await cubit.load();
      expect(repository.gets, hasLength(2));
      repository.gets.first.complete(seedAddresses().first);
      await old;
      expect(cubit.state.name, 'Draft name');
      await cubit.close();
      await repository.source.dispose();
    },
  );

  test(
    'concurrent save taps create one operation and immutable input',
    () async {
      final repository = MockAddressesRepository();
      final cubit = AddressEditorCubit(repository, AddressTestPlaces());
      await cubit.load();
      cubit.nameChanged('One address');
      cubit.locationSelected(seedAddresses().first.input.location);
      final first = cubit.save();
      cubit.nameChanged('Must not replace the request');
      final second = cubit.save();
      await Future.wait([first, second]);
      expect(await repository.list(), hasLength(3));
      expect(cubit.state.original!.input.name, 'One address');
      await cubit.close();
      await repository.dispose();
    },
  );
}
