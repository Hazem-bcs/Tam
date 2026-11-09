import '../domain/account_management_repository.dart';

final class UnavailableAccountManagementRepository
    implements AccountManagementRepository {
  const UnavailableAccountManagementRepository();
  Never _fail() => throw const AccountFailure('SERVICE_UNAVAILABLE');
  @override
  Future<AccountEligibility> eligibility() async => _fail();
  @override
  Future<AccountChallenge> start({
    required AccountAction action,
    required String operationId,
    String? newPhoneE164,
  }) async => _fail();
  @override
  Future<AccountChallenge> resend({
    required String challengeId,
    required String requestId,
  }) async => _fail();
  @override
  Future<AccountReceipt> confirm({
    required String challengeId,
    required String operationId,
    required String code,
  }) async => _fail();
  @override
  Future<AccountReceipt?> operation(String operationId) async => _fail();
  @override
  Stream<AccountChange> get changes => const Stream.empty();
}
