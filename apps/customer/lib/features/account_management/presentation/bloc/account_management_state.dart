import '../../domain/account_management_repository.dart';

final class AccountManagementState {
  const AccountManagementState({
    this.eligibility,
    this.challenge,
    this.receipt,
    this.busy = false,
    this.locked = false,
    this.ended = false,
    this.failure,
  });
  final AccountEligibility? eligibility;
  final AccountChallenge? challenge;
  final AccountReceipt? receipt;
  final bool busy, locked, ended;
  final String? failure;
  AccountManagementState copyWith({
    AccountEligibility? eligibility,
    AccountChallenge? challenge,
    AccountReceipt? receipt,
    bool? busy,
    bool? locked,
    String? failure,
  }) => AccountManagementState(
    eligibility: eligibility ?? this.eligibility,
    challenge: challenge ?? this.challenge,
    receipt: receipt ?? this.receipt,
    busy: busy ?? this.busy,
    locked: locked ?? this.locked,
    ended: ended,
    failure: failure,
  );
}
