import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/features/auth/domain/auth_models.dart';
import 'package:tam_customer/features/auth/domain/auth_repository.dart';
import 'package:tam_customer/features/auth/domain/phone_number.dart';

enum AuthStatus {
  restoring,
  signedOut,
  awaitingOtp,
  authenticated,
  localAccess,
  guest,
  sessionUnavailable,
}

final class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.restoring,
    this.challenge,
    this.user,
    this.localPhoneE164,
    this.isNewUser = false,
    this.isBusy = false,
    this.isResending = false,
    this.isSigningOut = false,
    this.failure,
    this.retryAt,
  });

  final AuthStatus status;
  final OtpChallenge? challenge;
  final AuthUser? user;
  // Local, unverified phone entry is never a backend user or session.
  final String? localPhoneE164;
  final bool isNewUser;
  final bool isBusy;
  final bool isResending;
  final bool isSigningOut;
  final AuthFailure? failure;
  final DateTime? retryAt;

  // Tokens and OTP values are deliberately absent from observable state.
  AuthState copyWith({
    AuthStatus? status,
    OtpChallenge? challenge,
    bool isBusy = false,
    bool isResending = false,
    bool isSigningOut = false,
    AuthFailure? failure,
    DateTime? retryAt,
  }) => AuthState(
    status: status ?? this.status,
    challenge: challenge ?? this.challenge,
    user: user,
    localPhoneE164: localPhoneE164,
    isNewUser: isNewUser,
    isBusy: isBusy,
    isResending: isResending,
    isSigningOut: isSigningOut,
    failure: failure,
    retryAt: retryAt,
  );

  @override
  List<Object?> get props => [
    status,
    challenge,
    user,
    localPhoneE164,
    isNewUser,
    isBusy,
    isResending,
    isSigningOut,
    failure,
    retryAt,
  ];

  @override
  bool get stringify => false;
}

/// UI/session orchestration depends only on the domain ports.
final class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._repository,
    this._sessionStore, {
    DateTime Function()? clock,
    this.temporaryPhoneEntryEnabled = false,
  }) : _clock = clock ?? DateTime.now,
       super(const AuthState());

  final AuthRepository _repository;
  final AuthSessionStore _sessionStore;
  final DateTime Function() _clock;
  final bool temporaryPhoneEntryEnabled;
  Future<void>? _restoreInFlight;
  AuthSession? _session;

  DateTime get _now => _clock().toUtc();

  Future<void> restoreSession() {
    if (temporaryPhoneEntryEnabled) {
      if (!isClosed && state.status == AuthStatus.restoring) {
        _publish(const AuthState(status: AuthStatus.signedOut));
      }
      return Future.value();
    }
    if (_restoreInFlight case final pending?) return pending;
    if (isClosed || state.isBusy) return Future.value();
    final pending = _restore();
    _restoreInFlight = pending;
    pending.then<void>(
      (_) => _restoreInFlight = null,
      onError: (Object _, StackTrace _) => _restoreInFlight = null,
    );
    return pending;
  }

  Future<void> _restore() async {
    final previous = state;
    _publish(state.copyWith(isBusy: true));
    try {
      var session = await _sessionStore.read();
      if (session == null) {
        _publish(const AuthState(status: AuthStatus.signedOut));
        return;
      }
      if (!_now.isBefore(session.refreshExpiresAt)) {
        await _sessionStore.clear();
        _session = null;
        _publish(const AuthState(status: AuthStatus.signedOut));
        return;
      }
      var refreshed = false;
      if (!_now.isBefore(session.expiresAt)) {
        session = await _refresh(session);
        refreshed = true;
      }
      AuthUser user;
      try {
        user = await _repository.currentUser(accessToken: session.accessToken);
      } on AuthFailure catch (failure) {
        // Handle a server expiry/clock skew once; never loop refresh retries.
        if (failure.code != 'SESSION_INVALID' || refreshed) rethrow;
        session = await _refresh(session);
        user = await _repository.currentUser(accessToken: session.accessToken);
      }
      _session = session;
      _publish(AuthState(status: AuthStatus.authenticated, user: user));
    } catch (error) {
      final failure = _failure(error);
      if (failure.invalidatesSession) {
        await _sessionStore.clear();
        _session = null;
        _publish(AuthState(status: AuthStatus.signedOut, failure: failure));
      } else {
        // A timeout/offline result does not erase stored credentials.
        _publish(
          previous.status == AuthStatus.authenticated
              ? previous.copyWith(failure: failure)
              : AuthState(
                  status: AuthStatus.sessionUnavailable,
                  failure: failure,
                ),
        );
      }
    }
  }

  Future<AuthSession> _refresh(AuthSession session) async {
    final renewed = await _repository.refreshToken(
      refreshToken: session.refreshToken,
    );
    await _sessionStore.write(renewed);
    _session = renewed;
    return renewed;
  }

  Future<void> requestOtp(String input) async {
    if (isClosed || state.isBusy || state.status != AuthStatus.signedOut) {
      return;
    }
    final phone = normalizeSyrianPhone(input);
    if (phone == null) {
      _publish(
        state.copyWith(
          failure: const AuthFailure(
            code: 'PHONE_INVALID',
            message: BilingualMessage(
              ar: 'رقم الهاتف غير صالح',
              en: 'Invalid phone number',
            ),
          ),
        ),
      );
      return;
    }
    if (state.retryAt != null && _now.isBefore(state.retryAt!)) return;
    _publish(state.copyWith(isBusy: true));
    try {
      if (temporaryPhoneEntryEnabled) {
        await _sessionStore.clear();
        _session = null;
        _publish(
          AuthState(status: AuthStatus.localAccess, localPhoneE164: phone),
        );
        return;
      }
      final challenge = await _repository.requestOtp(phoneE164: phone);
      _publish(AuthState(status: AuthStatus.awaitingOtp, challenge: challenge));
    } catch (error) {
      _publishFailure(error);
    }
  }

  Future<void> verifyOtp(String input) async {
    final challenge = state.challenge;
    if (isClosed ||
        state.isBusy ||
        challenge == null ||
        state.status != AuthStatus.awaitingOtp) {
      return;
    }
    _publish(state.copyWith(isBusy: true));
    try {
      final result = await _repository.verifyOtp(
        challengeId: challenge.id,
        code: normalizeDigits(input).trim(),
      );
      await _sessionStore.write(result.session);
      _session = result.session;
      _publish(
        AuthState(
          status: AuthStatus.authenticated,
          user: result.user,
          isNewUser: result.isNewUser,
        ),
      );
    } catch (error) {
      _publishFailure(error);
    }
  }

  Future<void> resendOtp() async {
    final challenge = state.challenge;
    if (isClosed ||
        state.isBusy ||
        challenge == null ||
        state.status != AuthStatus.awaitingOtp) {
      return;
    }
    _publish(state.copyWith(isBusy: true, isResending: true));
    try {
      final refreshed = await _repository.resendOtp(challengeId: challenge.id);
      _publish(AuthState(status: AuthStatus.awaitingOtp, challenge: refreshed));
    } catch (error) {
      _publishFailure(error);
    }
  }

  void editPhone() {
    if (!isClosed && !state.isBusy && state.status == AuthStatus.awaitingOtp) {
      _publish(
        AuthState(status: AuthStatus.signedOut, challenge: state.challenge),
      );
    }
  }

  void clearFailure() {
    if (!isClosed && !state.isBusy && state.failure != null) {
      _publish(state.copyWith(retryAt: state.retryAt));
    }
  }

  Future<void> continueAsGuest() async {
    if (isClosed || state.isBusy || state.status != AuthStatus.signedOut) {
      return;
    }
    _session = null;
    await _sessionStore.clear();
    _publish(const AuthState(status: AuthStatus.guest));
  }

  Future<void> logout() async {
    if (isClosed || state.isBusy) return;
    final localOnly =
        state.status == AuthStatus.localAccess ||
        state.status == AuthStatus.guest;
    _publish(state.copyWith(isBusy: true, isSigningOut: true));
    AuthFailure? failure;
    try {
      final session = localOnly ? null : _session ?? await _sessionStore.read();
      if (session != null) {
        await _repository.logout(refreshToken: session.refreshToken);
      }
    } catch (error) {
      final cause = _failure(error);
      if (!cause.invalidatesSession) {
        failure = const AuthFailure(
          code: 'LOGOUT_REMOTE_UNCONFIRMED',
          message: BilingualMessage(
            ar: 'تم تسجيل الخروج من هذا الجهاز، لكن تعذر تأكيد إبطال الجلسة على الخادم.',
            en: 'Signed out of this device, but server-side session revocation could not be confirmed.',
          ),
        );
      }
    }
    // Explicit sign-out always clears local credentials, even if offline.
    await _sessionStore.clear();
    _session = null;
    _publish(AuthState(status: AuthStatus.signedOut, failure: failure));
  }

  void _publishFailure(Object error) {
    final failure = _failure(error);
    final remaining = failure.attemptsRemaining;
    _publish(
      state.copyWith(
        failure: failure,
        challenge: remaining == null
            ? null
            : state.challenge?.withAttempts(remaining),
        retryAt: failure.retryAfterSeconds == null
            ? null
            : _now.add(Duration(seconds: failure.retryAfterSeconds!)),
      ),
    );
  }

  void _publish(AuthState next) {
    if (!isClosed) emit(next);
  }

  AuthFailure _failure(Object error) => error is AuthFailure
      ? error
      : const AuthFailure(
          code: 'INTERNAL_ERROR',
          message: BilingualMessage(
            ar: 'تعذر إكمال العملية. يرجى المحاولة مرة أخرى.',
            en: 'Unable to complete this action. Please try again.',
          ),
        );
}
