import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/addresses/data/addresses_codec.dart';
import 'package:tam_customer/features/addresses/data/mock/addresses_fixture.dart';
import 'package:tam_customer/features/addresses/data/mock/mock_addresses_repository.dart';
import 'package:tam_customer/features/addresses/data/ride_address_place_search.dart';
import 'package:tam_customer/features/addresses/data/unavailable_addresses_repository.dart';
import 'package:tam_customer/features/addresses/domain/addresses_repository.dart';
import 'package:tam_customer/features/addresses/domain/saved_address.dart';
import 'package:tam_customer/features/ride_request/data/mock/mock_ride_request_repository.dart';
import 'package:tam_customer/features/ride_request/data/repositories/unavailable_ride_request_repository.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';

AddressInput input([String name = 'مكان جديد']) => AddressInput(
  name: name,
  icon: AddressIcon.other,
  location: seedAddresses().first.input.location,
);

Matcher failure(AddressFailureCode code) =>
    throwsA(isA<AddressFailure>().having((e) => e.code, 'code', code));

void main() {
  test(
    'name uses Unicode code points and enforces trimmed domain boundaries',
    () {
      expect(input('  المنزل  ').name, 'المنزل');
      expect(() => input(' '), throwsArgumentError);
      expect(() => input(List.filled(51, 'ا').join()), throwsArgumentError);
      expect(input(List.filled(50, '🚗').join()).name.runes.length, 50);
    },
  );

  test(
    'fixture list is immutable and mutations publish one canonical snapshot',
    () async {
      final repository = MockAddressesRepository();
      final changes = <List<SavedAddress>>[];
      final subscription = repository.changes.listen(changes.add);
      expect((await repository.list()).map((a) => a.id), [
        'address-home-001',
        'address-work-001',
      ]);
      final created = await repository.create(input(), operationId: 'new-1');
      expect(changes.single.first, created);
      expect(() => changes.single.clear(), throwsUnsupportedError);
      await subscription.cancel();
      await repository.dispose();
    },
  );

  test(
    'lost create response retries the same ID and rejects a different body',
    () async {
      final repository = MockAddressesRepository()
        ..loseNextCreateResponse = true;
      addTearDown(repository.dispose);
      await expectLater(
        repository.create(input(), operationId: 'same'),
        failure(AddressFailureCode.network),
      );
      expect(await repository.list(), hasLength(3));
      final retried = await repository.create(input(), operationId: 'same');
      expect(retried.id, 'mock-address-1');
      await expectLater(
        repository.create(input('اسم مختلف'), operationId: 'same'),
        failure(AddressFailureCode.idempotencyConflict),
      );
      expect(await repository.list(), hasLength(3));
    },
  );

  test('update preserves creation identity and delete is idempotent', () async {
    final repository = MockAddressesRepository(
      clock: () => DateTime.utc(2026, 11, 8),
    );
    addTearDown(repository.dispose);
    final original = await repository.get('address-home-001');
    final updated = await repository.update(original.id, input('منزل جديد'));
    expect(updated.createdAt, original.createdAt);
    expect(updated.id, original.id);
    expect(updated.updatedAt, DateTime.utc(2026, 11, 8));
    expect(await repository.update(original.id, updated.input), updated);
    await repository.delete(original.id);
    await repository.delete(original.id);
    await expectLater(
      repository.get(original.id),
      failure(AddressFailureCode.notFound),
    );
    await expectLater(
      repository.update(original.id, input()),
      failure(AddressFailureCode.notFound),
    );
  });

  test(
    'retry after update returns the current resource; after deletion never recreates it',
    () async {
      final repository = MockAddressesRepository();
      addTearDown(repository.dispose);
      final created = await repository.create(input(), operationId: 'key');
      final updated = await repository.update(created.id, input('تعديل لاحق'));
      expect(await repository.create(input(), operationId: 'key'), updated);
      await repository.delete(created.id);
      await expectLater(
        repository.create(input(), operationId: 'key'),
        failure(AddressFailureCode.notFound),
      );
      expect(await repository.list(), hasLength(2));
    },
  );

  test('bounded address book still resolves retry when full', () async {
    final repository = MockAddressesRepository(seed: []);
    addTearDown(repository.dispose);
    for (var i = 0; i < AddressesRepository.maxAddresses; i++) {
      await repository.create(input('مكان $i'), operationId: 'op-$i');
    }
    await expectLater(
      repository.create(input(), operationId: 'extra'),
      failure(AddressFailureCode.limitReached),
    );
    expect(
      (await repository.create(input('مكان 49'), operationId: 'op-49')).id,
      'mock-address-50',
    );
    await expectLater(
      repository.create(input(), operationId: ' '),
      failure(AddressFailureCode.validation),
    );
  });

  test(
    'reset removes personal changes and operation keys, restores only fixtures',
    () async {
      final repository = MockAddressesRepository();
      addTearDown(repository.dispose);
      final created = await repository.create(input(), operationId: 'key');
      await repository.update('address-home-001', input('حساب سابق'));
      repository.resetSession();
      expect(await repository.list(), seedAddresses());
      await expectLater(
        repository.get(created.id),
        failure(AddressFailureCode.notFound),
      );
      final next = await repository.create(
        input('جلسة أخرى'),
        operationId: 'key',
      );
      expect(next.id, isNot(created.id));
    },
  );

  test('failure keeps data and API implementation never falls back', () async {
    final repository = MockAddressesRepository();
    addTearDown(repository.dispose);
    repository.failOnce(AddressOperation.delete);
    await expectLater(
      repository.delete('address-home-001'),
      failure(AddressFailureCode.network),
    );
    expect(await repository.list(), hasLength(2));
    const api = UnavailableAddressesRepository();
    await expectLater(api.list(), failure(AddressFailureCode.unavailable));
    await expectLater(
      api.get('address-home-001'),
      failure(AddressFailureCode.unavailable),
    );
    await expectLater(
      api.create(input(), operationId: 'key'),
      failure(AddressFailureCode.unavailable),
    );
    await expectLater(
      api.update('id', input()),
      failure(AddressFailureCode.unavailable),
    );
    await expectLater(
      api.delete('id'),
      failure(AddressFailureCode.unavailable),
    );
  });

  test(
    'codec rejects invalid calendar, icon, coordinates, duplicates and missing fields',
    () {
      for (final entry in {
        'name': ' ',
        'icon': 'unknown',
        'created_at': '2026-02-30T00:00:00Z',
        'updated_at': '2026-11-07T25:00:00Z',
        'location': {'label': 'A', 'latitude': 91, 'longitude': 36},
      }.entries) {
        final json = Map<String, dynamic>.from(addressesFixture.first)
          ..[entry.key] = entry.value;
        expect(() => AddressesCodec.item(json), throwsFormatException);
      }
      final missing = Map<String, dynamic>.from(addressesFixture.first)
        ..remove('updated_at');
      expect(() => AddressesCodec.item(missing), throwsFormatException);
      expect(
        () => AddressesCodec.list({
          'data': [addressesFixture.first, addressesFixture.first],
        }),
        throwsFormatException,
      );
    },
  );

  test(
    'place adapter reuses existing search and maps language/failures',
    () async {
      final trips = MockTripStore();
      addTearDown(trips.dispose);
      final search = RideAddressPlaceSearch(
        MockRideRequestRepository(trips: trips),
        languageCode: 'en',
      );
      final locations = await search.search('Mezzeh');
      expect(locations.single.label, 'Mezzeh, Al-Jalaa Street');
      expect(
        locations.single.point,
        seedAddresses().first.input.location.point,
      );
      const api = RideAddressPlaceSearch(
        UnavailableRideRequestRepository(),
        languageCode: 'ar',
      );
      await expectLater(
        api.search(''),
        failure(AddressFailureCode.unavailable),
      );
    },
  );
}
