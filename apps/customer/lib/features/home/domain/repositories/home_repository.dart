import 'package:tam_customer/features/home/domain/entities/home_content.dart';

enum HomeFailureCode { serviceUnavailable, offline, invalidResponse }

final class HomeFailure implements Exception {
  const HomeFailure(this.code);
  final HomeFailureCode code;
}

abstract interface class HomeRepository {
  Future<HomeContent> load();
}
