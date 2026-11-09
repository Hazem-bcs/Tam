import 'dart:async';
import 'package:tam_customer/features/auth/domain/phone_number.dart';
import 'package:tam_customer/shared/data/mock/mock_trip_store.dart';
import 'package:tam_customer/shared/domain/trip.dart';
import '../../domain/account_management_repository.dart';

/// Session-local simulation. OTP fixtures never authenticate a backend user.
final class MockAccountManagementRepository
    implements AccountManagementRepository {
  MockAccountManagementRepository(
    this._trips, {
    required this.phone,
    this.policy = const AccountPolicy(),
    DateTime Function()? now,
    this.scenario = 'success',
  }) : _now = now ?? DateTime.now {
    if (!{
      'success',
      'offline',
      'lost_response',
      'phone_in_use',
    }.contains(scenario)) {
      throw ArgumentError.value(scenario);
    }
  }
  final MockTripStore _trips;
  final String? Function() phone;
  final AccountPolicy policy;
  final DateTime Function() _now;
  final String scenario;
  final _challenges = <String, AccountChallenge>{};
  final _fingerprints = <String, (AccountAction, String?)>{};
  final _codes = <String, String>{};
  final _resends = <String, AccountChallenge>{};
  final _receipts = <String, AccountReceipt>{};
  final _acceptedCodes = <String, String>{};
  final _events = StreamController<AccountChange>.broadcast(sync: true);
  bool _ended = false, _disposed = false;
  bool loseNextStart = false, loseNextConfirm = false;
  int _session = 0, _failures = 0;
  DateTime? _lockedUntil;
  DateTime get _time => _now().toUtc();
  void _available() {
    if (_disposed || scenario == 'offline') {
      throw const AccountFailure('SERVICE_UNAVAILABLE');
    }
  }

  void _eligible() {
    _available();
    if (_lockedUntil != null && _time.isBefore(_lockedUntil!)) {
      throw const AccountFailure('RATE_LIMITED');
    }
    if (_lockedUntil != null && !_time.isBefore(_lockedUntil!)) {
      _lockedUntil = null;
      _failures = 0;
    }
    if (_ended || phone() == null) {
      throw const AccountFailure('ACCOUNT_REQUIRED');
    }
    if (_trips.trips.any((t) => t.status.isActive)) {
      throw const AccountFailure('ACTIVE_TRIP_EXISTS');
    }
  }

  void _id(String id) {
    if (!RegExp(r'^[A-Za-z0-9_-]{16,128}$').hasMatch(id)) {
      throw const AccountFailure('VALIDATION_ERROR');
    }
  }

  @override
  Future<AccountEligibility> eligibility() async {
    _available();
    return AccountEligibility(
      phoneE164: _ended ? null : phone(),
      activeTripIds: _trips.trips
          .where((t) => t.status.isActive)
          .map((t) => t.id),
    );
  }

  @override
  Future<AccountChallenge> start({
    required AccountAction action,
    required String operationId,
    String? newPhoneE164,
  }) async {
    _eligible();
    _id(operationId);
    final fingerprint = (action, newPhoneE164);
    if (_fingerprints.containsKey(operationId)) {
      if (_fingerprints[operationId] != fingerprint) {
        throw const AccountFailure('IDEMPOTENCY_CONFLICT');
      }
      return _challenges[operationId]!;
    }
    final target = action == AccountAction.deleteAccount
        ? phone()!
        : normalizeSyrianPhone(newPhoneE164 ?? '');
    if (target == null ||
        (action == AccountAction.deleteAccount && newPhoneE164 != null)) {
      throw const AccountFailure('VALIDATION_ERROR');
    }
    if (action == AccountAction.changePhone) {
      if (target == phone()) throw const AccountFailure('PHONE_UNCHANGED');
      if (scenario == 'phone_in_use') {
        throw const AccountFailure('PHONE_IN_USE');
      }
    }
    final challenge = AccountChallenge(
      id: 'mock-account-$_session-$operationId',
      operationId: operationId,
      action: action,
      phoneE164: target,
      expiresAt: _time.add(policy.codeLifetime),
      resendAt: _time.add(policy.resendDelay),
      attemptsRemaining: policy.maxAttempts,
      revision: 1,
    );
    _fingerprints[operationId] = fingerprint;
    _challenges[operationId] = challenge;
    _codes[challenge.id] = '123456';
    if (loseNextStart) {
      loseNextStart = false;
      throw const AccountFailure('NETWORK_ERROR', uncertain: true);
    }
    return challenge;
  }

  AccountChallenge _challenge(String id) =>
      _challenges.values.where((c) => c.id == id).firstOrNull ??
      (throw const AccountFailure('CHALLENGE_NOT_FOUND'));
  void _live(AccountChallenge challenge) {
    if (!_time.isBefore(challenge.expiresAt)) {
      throw const AccountFailure('OTP_EXPIRED');
    }
    if (challenge.attemptsRemaining <= 0) {
      throw const AccountFailure('OTP_ATTEMPTS_EXCEEDED');
    }
  }

  @override
  Future<AccountChallenge> resend({
    required String challengeId,
    required String requestId,
  }) async {
    _eligible();
    _id(requestId);
    final previous = _resends[requestId];
    if (previous != null) {
      if (previous.id != challengeId) {
        throw const AccountFailure('IDEMPOTENCY_CONFLICT');
      }
      return _challenge(challengeId);
    }
    final old = _challenge(challengeId);
    _live(old);
    if (_receipts.containsKey(old.operationId)) {
      throw const AccountFailure('OPERATION_COMPLETED');
    }
    if (_time.isBefore(old.resendAt)) {
      throw const AccountFailure('OTP_COOLDOWN');
    }
    final next = AccountChallenge(
      id: old.id,
      operationId: old.operationId,
      action: old.action,
      phoneE164: old.phoneE164,
      expiresAt: _time.add(policy.codeLifetime),
      resendAt: _time.add(policy.resendDelay),
      attemptsRemaining: policy.maxAttempts,
      revision: old.revision + 1,
    );
    _challenges[old.operationId] = next;
    _resends[requestId] = next;
    _codes[old.id] = next.revision.isEven ? '654321' : '123456';
    return next;
  }

  @override
  Future<AccountReceipt> confirm({
    required String challengeId,
    required String operationId,
    required String code,
  }) async {
    _available();
    final previous = _receipts[operationId];
    if (previous != null) {
      if (previous.challengeId != challengeId ||
          _acceptedCodes[operationId] != code) {
        throw const AccountFailure('IDEMPOTENCY_CONFLICT');
      }
      return previous;
    }
    _eligible();
    final challenge = _challenge(challengeId);
    _live(challenge);
    if (challenge.operationId != operationId) {
      throw const AccountFailure('IDEMPOTENCY_CONFLICT');
    }
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      throw const AccountFailure('VALIDATION_ERROR');
    }
    if (_codes[challengeId] != code) {
      _failures++;
      if (_failures >= policy.maxAttempts) {
        _lockedUntil = _time.add(policy.lockoutDuration);
      }
      _challenges[operationId] = AccountChallenge(
        id: challenge.id,
        operationId: operationId,
        action: challenge.action,
        phoneE164: challenge.phoneE164,
        expiresAt: challenge.expiresAt,
        resendAt: challenge.resendAt,
        attemptsRemaining: challenge.attemptsRemaining - 1,
        revision: challenge.revision + 1,
      );
      throw const AccountFailure('OTP_INVALID');
    }
    if (challenge.action == AccountAction.changePhone &&
        scenario == 'phone_in_use') {
      throw const AccountFailure('PHONE_IN_USE');
    }
    final receipt = AccountReceipt(
      operationId: operationId,
      challengeId: challengeId,
      action: challenge.action,
      completedAt: _time,
    );
    _receipts[operationId] = receipt;
    _acceptedCodes[operationId] = code;
    _ended = true;
    if (loseNextConfirm || scenario == 'lost_response') {
      loseNextConfirm = false;
      throw const AccountFailure('NETWORK_ERROR', uncertain: true);
    }
    return receipt;
  }

  @override
  Future<AccountReceipt?> operation(String operationId) async {
    _available();
    return _receipts[operationId];
  }

  @override
  Stream<AccountChange> get changes => _events.stream;
  void resetSession() {
    _challenges.clear();
    _fingerprints.clear();
    _codes.clear();
    _resends.clear();
    _receipts.clear();
    _acceptedCodes.clear();
    _ended = false;
    _failures = 0;
    _lockedUntil = null;
    _session++;
    loseNextStart = loseNextConfirm = false;
    if (!_disposed) _events.add(const AccountChange(sessionReset: true));
  }

  Future<void> dispose() async {
    _disposed = true;
    await _events.close();
  }
}
