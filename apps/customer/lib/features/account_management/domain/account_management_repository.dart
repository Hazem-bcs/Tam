import 'package:equatable/equatable.dart';

enum AccountAction { changePhone, deleteAccount }

final class AccountPolicy {
  const AccountPolicy({
    this.codeLifetime = const Duration(minutes: 5),
    this.resendDelay = const Duration(seconds: 30),
    this.maxAttempts = 5,
    this.lockoutDuration = const Duration(minutes: 15),
  });
  final Duration codeLifetime, resendDelay, lockoutDuration;
  final int maxAttempts;
}

final class AccountEligibility {
  AccountEligibility({
    required this.phoneE164,
    Iterable<String> activeTripIds = const [],
  }) : activeTripIds = List.unmodifiable(activeTripIds);
  final String? phoneE164;
  final List<String> activeTripIds;
  bool get canManage => phoneE164 != null && activeTripIds.isEmpty;
}

final class AccountChallenge extends Equatable {
  const AccountChallenge({
    required this.id,
    required this.operationId,
    required this.action,
    required this.phoneE164,
    required this.expiresAt,
    required this.resendAt,
    required this.attemptsRemaining,
    required this.revision,
  });
  final String id, operationId, phoneE164;
  final AccountAction action;
  final DateTime expiresAt, resendAt;
  final int attemptsRemaining, revision;
  @override
  List<Object?> get props => [
    id,
    operationId,
    action,
    phoneE164,
    expiresAt,
    resendAt,
    attemptsRemaining,
    revision,
  ];
}

final class AccountReceipt extends Equatable {
  const AccountReceipt({
    required this.operationId,
    required this.challengeId,
    required this.action,
    required this.completedAt,
  });
  final String operationId, challengeId;
  final AccountAction action;
  final DateTime completedAt;
  @override
  List<Object?> get props => [operationId, challengeId, action, completedAt];
}

final class AccountChange {
  const AccountChange({this.sessionReset = false});
  final bool sessionReset;
}

final class AccountFailure implements Exception {
  const AccountFailure(this.code, {this.uncertain = false});
  final String code;
  final bool uncertain;
}

abstract interface class AccountManagementRepository {
  Future<AccountEligibility> eligibility();
  Future<AccountChallenge> start({
    required AccountAction action,
    required String operationId,
    String? newPhoneE164,
  });
  Future<AccountChallenge> resend({
    required String challengeId,
    required String requestId,
  });
  Future<AccountReceipt> confirm({
    required String challengeId,
    required String operationId,
    required String code,
  });
  Future<AccountReceipt?> operation(String operationId);
  Stream<AccountChange> get changes;
}
