import 'package:tam_customer/features/home/data/home_content_mapper.dart';
import 'package:tam_customer/features/home/data/mock/home_fixtures.dart';
import 'package:tam_customer/features/home/domain/entities/home_content.dart';
import 'package:tam_customer/features/home/domain/repositories/home_repository.dart';

enum HomeMockScenario { success, empty, offline }

final class MockHomeRepository implements HomeRepository {
  const MockHomeRepository({
    this.scenario = HomeMockScenario.success,
    this.latency = const Duration(milliseconds: 150),
  });
  final HomeMockScenario scenario;
  final Duration latency;

  @override
  Future<HomeContent> load() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    if (scenario == HomeMockScenario.offline) {
      throw const HomeFailure(HomeFailureCode.offline);
    }
    try {
      return HomeContentMapper.fromEnvelope(
        scenario == HomeMockScenario.empty
            ? homeEmptyFixture
            : homeSuccessFixture,
      );
    } on FormatException {
      throw const HomeFailure(HomeFailureCode.invalidResponse);
    }
  }
}
