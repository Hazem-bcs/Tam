import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/addresses/data/mock/addresses_fixture.dart';
import 'package:tam_customer/features/addresses/data/mock/mock_addresses_repository.dart';
import 'package:tam_customer/features/addresses/domain/addresses_repository.dart';
import 'package:tam_customer/features/addresses/domain/saved_address.dart';
import 'package:tam_customer/features/addresses/presentation/bloc/address_editor_cubit.dart';
import 'package:tam_customer/features/addresses/presentation/bloc/address_editor_state.dart';
import 'package:tam_customer/features/addresses/presentation/bloc/addresses_cubit.dart';
import 'package:tam_customer/features/addresses/presentation/bloc/addresses_state.dart';
import 'package:tam_customer/shared/domain/trip.dart';

final class _Search implements AddressPlaceSearch {
  final pending = <String, Completer<List<TripLocation>>>{};
  bool controlled = false;
  @override
  Future<List<TripLocation>> search(String query) {
    if (controlled) return (pending[query] = Completer()).future;
    return Future.value([seedAddresses().first.input.location]);
  }
}

void main() {
  test(
    'list load, refresh error, delete failure and live updates stay consistent',
    () async {
      final repository = MockAddressesRepository();
      final cubit = AddressesCubit(repository);
      await cubit.load();
      expect(cubit.state.items, seedAddresses());
      repository.failOnce(AddressOperation.list);
      await cubit.load(refresh: true);
      expect(cubit.state.items, hasLength(2));
      expect(cubit.state.failure, AddressFailureCode.network);
      repository.failOnce(AddressOperation.delete);
      await cubit.delete('address-home-001');
      expect(cubit.state.items, hasLength(2));
      expect(cubit.state.deletingId, isNull);
      await cubit.delete('address-home-001');
      expect(cubit.state.items.single.id, 'address-work-001');
      repository.resetSession();
      expect(cubit.state.items, seedAddresses());
      await cubit.close();
      expect(repository.hasListeners, false);
      await repository.dispose();
    },
  );

  test(
    'empty refresh failures are visible rather than an empty success',
    () async {
      final repository = MockAddressesRepository(seed: []);
      final cubit = AddressesCubit(repository);
      await cubit.load();
      repository.failOnce(AddressOperation.list);
      await cubit.load(refresh: true);
      expect(cubit.state.status, AddressesStatus.error);
      await cubit.load();
      expect(cubit.state.status, AddressesStatus.ready);
      await cubit.close();
      await repository.dispose();
    },
  );

  test(
    'editor validates required location/name without creating an address',
    () async {
      final repository = MockAddressesRepository();
      final cubit = AddressEditorCubit(repository, _Search());
      await cubit.load();
      await cubit.save();
      expect(cubit.state.validationAttempted, true);
      expect(await repository.list(), hasLength(2));
      cubit.nameChanged('  موقع جديد  ');
      cubit.locationSelected(seedAddresses().first.input.location);
      await cubit.save();
      expect(cubit.state.phase, AddressEditorPhase.saved);
      expect(cubit.state.original!.input.name, 'موقع جديد');
      await cubit.close();
      await repository.dispose();
    },
  );

  test(
    'editor retains input and operation ID after lost response until retry',
    () async {
      final repository = MockAddressesRepository()
        ..loseNextCreateResponse = true;
      var keyCalls = 0;
      final cubit = AddressEditorCubit(
        repository,
        _Search(),
        operationKeyFactory: () => 'key-${++keyCalls}',
      );
      await cubit.load();
      cubit.nameChanged('طلب واحد');
      cubit.locationSelected(seedAddresses().first.input.location);
      await cubit.save();
      expect(cubit.state.retryPending, true);
      cubit.nameChanged('تغيير أثناء التعليق');
      cubit.iconChanged(AddressIcon.gym);
      expect(cubit.state.name, 'طلب واحد');
      expect(cubit.state.icon, AddressIcon.home);
      await cubit.save();
      expect(cubit.state.phase, AddressEditorPhase.saved);
      expect(await repository.list(), hasLength(3));
      expect(keyCalls, 1);
      await cubit.close();
      await repository.dispose();
    },
  );

  test(
    'editor updates existing identity and reports an address deleted meanwhile',
    () async {
      final repository = MockAddressesRepository();
      final cubit = AddressEditorCubit(
        repository,
        _Search(),
        id: 'address-home-001',
      );
      await cubit.load();
      expect(cubit.state.dirty, false);
      cubit.nameChanged('المنزل الجديد');
      await repository.delete('address-home-001');
      await cubit.save();
      expect(cubit.state.phase, AddressEditorPhase.notFound);
      expect(await repository.list(), hasLength(1));
      await cubit.close();
      await repository.dispose();
    },
  );

  test(
    'search ignores stale results and late responses after closure',
    () async {
      final repository = MockAddressesRepository();
      final search = _Search();
      final cubit = AddressEditorCubit(repository, search);
      await cubit.load();
      await Future<void>.delayed(Duration.zero);
      search.controlled = true;
      final old = cubit.search('old');
      final latest = cubit.search('latest');
      search.pending['latest']!.complete([seedAddresses().last.input.location]);
      await latest;
      search.pending['old']!.complete([seedAddresses().first.input.location]);
      await old;
      expect(
        cubit.state.suggestions.single,
        seedAddresses().last.input.location,
      );
      final closing = cubit.search('closing');
      await cubit.close();
      search.pending['closing']!.complete([]);
      await closing;
      await repository.dispose();
    },
  );
}
