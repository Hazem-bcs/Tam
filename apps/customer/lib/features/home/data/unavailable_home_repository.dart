import 'package:tam_customer/features/home/domain/entities/home_content.dart';
import 'package:tam_customer/features/home/domain/repositories/home_repository.dart';

/// Explicit API-mode failure, never silent mock fallback.
final class UnavailableHomeRepository implements HomeRepository {
  const UnavailableHomeRepository();
  @override
  Future<HomeContent> load() async =>
      throw const HomeFailure(HomeFailureCode.serviceUnavailable);
}
