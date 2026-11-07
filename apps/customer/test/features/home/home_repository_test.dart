import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/features/home/data/home_content_mapper.dart';
import 'package:tam_customer/features/home/data/mock/home_fixtures.dart';
import 'package:tam_customer/features/home/data/mock/mock_home_repository.dart';
import 'package:tam_customer/features/home/data/unavailable_home_repository.dart';
import 'package:tam_customer/features/home/domain/entities/home_content.dart';
import 'package:tam_customer/features/home/domain/repositories/home_repository.dart';
import 'package:tam_customer/features/home/presentation/bloc/home_cubit.dart';

void main() {
  test(
    'versioned API success example equals the mock fixture and decodes',
    () async {
      final example =
          jsonDecode(
                File(
                  '../../docs/api/home/examples/home-success.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      expect(example, equals(homeSuccessFixture));
      final content = HomeContentMapper.fromEnvelope(example);
      expect(content.revision, 'home-demo-1');
      expect(content.services.map((s) => s.id), [
        HomeServiceId.ride,
        HomeServiceId.food,
        HomeServiceId.shopping,
      ]);
      expect(content.services.first.available, isTrue);
      expect(content.promotions.last.enabled, isFalse);
      expect(
        content.promotions.first.title.forLanguage('en'),
        'Getting there is easier with Tam',
      );
    },
  );

  test(
    'empty contract example equals fixture and does not signal an error',
    () {
      final example =
          jsonDecode(
                File(
                  '../../docs/api/home/examples/home-empty.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      expect(example, equals(homeEmptyFixture));
      expect(HomeContentMapper.fromEnvelope(example).isEmpty, isTrue);
    },
  );

  test(
    'decoder rejects a malicious route and unavailable service activation',
    () {
      final bad =
          jsonDecode(jsonEncode(homeSuccessFixture)) as Map<String, dynamic>;
      final data = bad['data'] as Map<String, dynamic>;
      final services = data['services'] as List<dynamic>;
      (services[0] as Map<String, dynamic>)['action'] = '/external-url';
      expect(() => HomeContentMapper.fromEnvelope(bad), throwsFormatException);
      (services[0] as Map<String, dynamic>)['action'] = 'ride_request';
      (services[1] as Map<String, dynamic>)['available'] = true;
      (services[1] as Map<String, dynamic>)['action'] = 'ride_request';
      expect(() => HomeContentMapper.fromEnvelope(bad), throwsFormatException);
    },
  );

  test('mock success, empty and offline are deterministic', () async {
    final success = await const MockHomeRepository(
      latency: Duration.zero,
    ).load();
    final empty = await const MockHomeRepository(
      scenario: HomeMockScenario.empty,
      latency: Duration.zero,
    ).load();
    expect(success.promotions.length, 2);
    expect(empty.isEmpty, isTrue);
    expect(
      const MockHomeRepository(
        scenario: HomeMockScenario.offline,
        latency: Duration.zero,
      ).load(),
      throwsA(
        isA<HomeFailure>().having(
          (failure) => failure.code,
          'code',
          HomeFailureCode.offline,
        ),
      ),
    );
  });

  test('API mode never returns mock success', () {
    expect(
      const UnavailableHomeRepository().load(),
      throwsA(
        isA<HomeFailure>().having(
          (failure) => failure.code,
          'code',
          HomeFailureCode.serviceUnavailable,
        ),
      ),
    );
  });

  test('cubit supports loading, empty, error and manual retry', () async {
    final repo = _RetryRepository();
    final cubit = HomeCubit(repo);
    final states = <HomeLoadStatus>[];
    final subscription = cubit.stream.listen((s) => states.add(s.status));
    await cubit.load();
    expect(cubit.state.failure, HomeFailureCode.offline);
    await cubit.load();
    expect(cubit.state.status, HomeLoadStatus.ready);
    expect(repo.calls, 2);
    await Future<void>.delayed(Duration.zero);
    expect(states, [
      HomeLoadStatus.loading,
      HomeLoadStatus.failure,
      HomeLoadStatus.loading,
      HomeLoadStatus.ready,
    ]);
    await subscription.cancel();
    await cubit.close();
  });
}

final class _RetryRepository implements HomeRepository {
  int calls = 0;
  @override
  Future<HomeContent> load() async {
    calls++;
    if (calls == 1) throw const HomeFailure(HomeFailureCode.offline);
    return HomeContentMapper.fromEnvelope(homeSuccessFixture);
  }
}
