import 'dart:async';
import 'package:tam_customer/features/account_management/domain/account_management_repository.dart';

final accountNow = DateTime.utc(2026, 11, 9, 12);
const operationId = 'account-operation-0001';

final class AccountProbe implements AccountManagementRepository {
  final events = StreamController<AccountChange>.broadcast(sync: true);
  Future<AccountEligibility> Function()? onEligibility;
  Future<AccountChallenge> Function(String, AccountAction, String?)? onStart;
  Future<AccountReceipt> Function(String, String, String)? onConfirm;
  Future<AccountReceipt?> Function(String)? onOperation;
  @override
  Future<AccountEligibility> eligibility() =>
      onEligibility?.call() ??
      Future.value(AccountEligibility(phoneE164: '+963912345678'));
  @override
  Future<AccountChallenge> start({
    required AccountAction action,
    required String operationId,
    String? newPhoneE164,
  }) =>
      onStart?.call(operationId, action, newPhoneE164) ??
      Future.value(
        AccountChallenge(
          id: 'challenge-1',
          operationId: operationId,
          action: action,
          phoneE164: newPhoneE164 ?? '+963912345678',
          expiresAt: accountNow.add(const Duration(minutes: 5)),
          resendAt: accountNow.add(const Duration(seconds: 30)),
          attemptsRemaining: 5,
          revision: 1,
        ),
      );
  @override
  Future<AccountChallenge> resend({
    required String challengeId,
    required String requestId,
  }) async => throw const AccountFailure('OTP_COOLDOWN');
  @override
  Future<AccountReceipt> confirm({
    required String challengeId,
    required String operationId,
    required String code,
  }) => onConfirm!.call(challengeId, operationId, code);
  @override
  Future<AccountReceipt?> operation(String operationId) =>
      onOperation?.call(operationId) ?? Future.value(null);
  @override
  Stream<AccountChange> get changes => events.stream;
}
