import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/features/auth/domain/phone_number.dart';
import '../../domain/account_management_repository.dart';
import 'account_management_state.dart';
export 'account_management_state.dart';

final class AccountManagementCubit extends Cubit<AccountManagementState> {
  AccountManagementCubit(
    this.repository, {
    required this.action,
    DateTime Function()? now,
  }) : now = now ?? DateTime.now,
       super(const AccountManagementState()) {
    _subscription = repository.changes.listen((event) {
      if (event.sessionReset) {
        _epoch++;
        _code = null;
        emit(const AccountManagementState(ended: true));
      }
    });
  }
  final AccountManagementRepository repository;
  final AccountAction action;
  final DateTime Function() now;
  late final StreamSubscription<AccountChange> _subscription;
  int _epoch = 0;
  String? _operationId, _phone, _code, _resendId;
  String _key() => List.generate(
    24,
    (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  bool get _idle =>
      !isClosed && !state.ended && !state.busy && state.receipt == null;
  bool _current(int epoch) => !isClosed && !state.ended && epoch == _epoch;
  Future<void> load() async {
    if (!_idle || state.locked) return;
    final epoch = ++_epoch;
    emit(state.copyWith(busy: true));
    try {
      final value = await repository.eligibility();
      if (_current(epoch)) {
        emit(state.copyWith(eligibility: value, busy: false));
      }
    } catch (e) {
      if (_current(epoch)) {
        emit(state.copyWith(busy: false, failure: _failure(e).code));
      }
    }
  }

  Future<void> start(String input) async {
    if (!_idle || state.challenge != null) return;
    if (!state.locked) {
      if (state.eligibility?.canManage != true) {
        emit(
          state.copyWith(
            failure: state.eligibility?.phoneE164 == null
                ? 'ACCOUNT_REQUIRED'
                : 'ACTIVE_TRIP_EXISTS',
          ),
        );
        return;
      }
      final target = action == AccountAction.deleteAccount
          ? null
          : normalizeSyrianPhone(input);
      if (action == AccountAction.changePhone && target == null) {
        emit(state.copyWith(failure: 'PHONE_INVALID'));
        return;
      }
      if (_operationId == null || _phone != target) {
        _operationId = _key();
        _phone = target;
      }
    }
    final epoch = ++_epoch;
    emit(state.copyWith(busy: true));
    try {
      final value = await repository.start(
        action: action,
        operationId: _operationId!,
        newPhoneE164: _phone,
      );
      if (!_current(epoch)) return;
      _validate(value);
      emit(state.copyWith(challenge: value, busy: false, locked: false));
    } catch (e) {
      if (_current(epoch)) {
        final f = _failure(e);
        emit(
          state.copyWith(
            busy: false,
            locked: state.locked || f.uncertain,
            failure: f.code,
          ),
        );
      }
    }
  }

  void _validate(AccountChallenge value) {
    if (value.operationId != _operationId ||
        value.action != action ||
        value.id.isEmpty ||
        value.phoneE164 != (_phone ?? state.eligibility?.phoneE164) ||
        value.revision < 1 ||
        value.attemptsRemaining < 0 ||
        !value.expiresAt.isAfter(value.resendAt)) {
      throw const AccountFailure('INVALID_RESPONSE', uncertain: true);
    }
    final old = state.challenge;
    if (old != null &&
        (old.id != value.id ||
            value.revision < old.revision ||
            (value.revision == old.revision && value != old))) {
      throw const AccountFailure('INVALID_RESPONSE', uncertain: true);
    }
  }

  Future<void> resend() async {
    final challenge = state.challenge;
    if (!_idle || state.locked || challenge == null) return;
    if (now().toUtc().isBefore(challenge.resendAt)) {
      emit(state.copyWith(failure: 'OTP_COOLDOWN'));
      return;
    }
    _resendId ??= _key();
    final epoch = ++_epoch;
    emit(state.copyWith(busy: true));
    try {
      final value = await repository.resend(
        challengeId: challenge.id,
        requestId: _resendId!,
      );
      if (!_current(epoch)) return;
      _validate(value);
      _resendId = null;
      emit(state.copyWith(challenge: value, busy: false));
    } catch (e) {
      if (_current(epoch)) {
        emit(state.copyWith(busy: false, failure: _failure(e).code));
      }
    }
  }

  Future<void> confirm(String input) async {
    final challenge = state.challenge;
    if (!_idle || challenge == null) return;
    if (!state.locked) {
      final code = normalizeDigits(input).trim();
      if (!RegExp(r'^\d{6}$').hasMatch(code)) {
        emit(state.copyWith(failure: 'VALIDATION_ERROR'));
        return;
      }
      _code = code;
    }
    final epoch = ++_epoch;
    emit(state.copyWith(busy: true));
    try {
      if (state.locked) {
        final saved = await repository.operation(_operationId!);
        if (!_current(epoch)) return;
        if (saved != null) {
          _accept(saved);
          return;
        }
      }
      final result = await repository.confirm(
        challengeId: challenge.id,
        operationId: _operationId!,
        code: _code!,
      );
      if (!_current(epoch)) return;
      _accept(result);
    } catch (e) {
      if (_current(epoch)) {
        final f = _failure(e);
        emit(
          state.copyWith(
            busy: false,
            locked: state.locked || f.uncertain,
            failure: f.code,
          ),
        );
      }
    }
  }

  void restart() {
    if (!_idle || state.locked) return;
    _epoch++;
    _operationId = _phone = _code = _resendId = null;
    emit(AccountManagementState(eligibility: state.eligibility));
  }

  void _accept(AccountReceipt value) {
    if (value.operationId != _operationId ||
        value.challengeId != state.challenge?.id ||
        value.action != action) {
      throw const AccountFailure('INVALID_RESPONSE', uncertain: true);
    }
    _code = null;
    emit(state.copyWith(receipt: value, busy: false, locked: false));
  }

  AccountFailure _failure(Object e) => e is AccountFailure
      ? e
      : const AccountFailure('NETWORK_ERROR', uncertain: true);
  @override
  Future<void> close() async {
    _epoch++;
    _code = null;
    await _subscription.cancel();
    return super.close();
  }
}
