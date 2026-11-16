import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_artwork.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_caret_gaze.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_otp_input.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';

class OtpAuthPage extends StatefulWidget {
  const OtpAuthPage({super.key});

  @override
  State<OtpAuthPage> createState() => _OtpAuthPageState();
}

class _OtpAuthPageState extends State<OtpAuthPage> {
  final _form = GlobalKey<FormState>();
  final _code = TextEditingController();
  bool _otpFocused = false;
  bool _localInvalid = false;

  void _refreshCodeCaret() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _code.addListener(_refreshCodeCaret);
  }

  void _updateOtpFocus(bool hasFocus) {
    if (mounted && _otpFocused != hasFocus) {
      setState(() => _otpFocused = hasFocus);
    }
  }

  @override
  void dispose() {
    _code.removeListener(_refreshCodeCaret);
    _code.dispose();
    super.dispose();
  }

  void _verify() {
    // A previous server error must not veto a corrected code before the next
    // frame has removed TextFormField.forceErrorText.
    if (RegExp(r'^\d{6}$').hasMatch(_code.text)) {
      if (_localInvalid) setState(() => _localInvalid = false);
      FocusScope.of(context).unfocus();
      context.read<AuthCubit>().verifyOtp(_code.text);
    } else {
      _form.currentState!.validate();
      if (!_localInvalid) setState(() => _localInvalid = true);
    }
  }

  Future<void> _resend() async {
    await context.read<AuthCubit>().resendOtp();
    if (mounted && context.read<AuthCubit>().state.failure == null) {
      _code.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final challenge = state.challenge;
        if (challenge == null) return const SizedBox.shrink();
        var resendAt = challenge.resendAt;
        if (state.retryAt != null && state.retryAt!.isAfter(resendAt)) {
          resendAt = state.retryAt!;
        }
        final failure = state.failure;
        return AuthScaffold(
          title: t.authVerifyTitle,
          description: t.authVerifyDescription,
          artwork: AuthArtwork.verification,
          onBack: context.read<AuthCubit>().editPhone,
          busy: state.isBusy,
          inputFocused: _otpFocused,
          gazeProgress: authCaretProgress(_code.value, maxDigits: 6),
          hasError: state.failure != null || _localInvalid,
          otpStage: true,
          child: AuthCountdown(
            deadline: challenge.expiresAt,
            builder: (context, expiry) {
              final blocked =
                  expiry == 0 ||
                  challenge.attemptsRemaining == 0 ||
                  const {
                    'OTP_CHALLENGE_INVALID',
                    'OTP_EXPIRED',
                    'OTP_TOO_MANY_ATTEMPTS',
                  }.contains(failure?.code);
              return Form(
                key: _form,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          color: Theme.of(context).colorScheme.primaryContainer
                              .withValues(alpha: 0.45),
                        ),
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.phone_iphone_outlined,
                                  size: AppDimensions.iconSize,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Flexible(
                                  child: Text(
                                    challenge.phoneE164,
                                    textDirection: TextDirection.ltr,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: state.isBusy
                                  ? null
                                  : context.read<AuthCubit>().editPhone,
                              child: Text(t.authEditPhone),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AuthOtpInput(
                        key: const Key('auth-code'),
                        controller: _code,
                        onFocusChanged: _updateOtpFocus,
                        label: t.authCodeLabel,
                        readOnly: state.isBusy,
                        blocked: blocked,
                        errorText: failure?.code == 'OTP_INVALID'
                            ? failure!.message.forLanguage(
                                Localizations.localeOf(context).languageCode,
                              )
                            : null,
                        validator: (value) =>
                            RegExp(r'^\d{6}$').hasMatch(value ?? '')
                            ? null
                            : t.authCodeInvalid,
                        onSubmitted: _verify,
                        onChanged: (_) {
                          context.read<AuthCubit>().clearFailure();
                          if (_localInvalid) {
                            setState(() => _localInvalid = false);
                          }
                        },
                      ),
                      if (failure != null && failure.code != 'OTP_INVALID') ...[
                        const SizedBox(height: AppSpacing.lg),
                        AuthErrorNotice(failure: failure),
                      ],
                      const SizedBox(height: AppSpacing.xxl),
                      TamButton.primary(
                        key: const Key('auth-confirm'),
                        label: t.authVerifyCode,
                        loadingLabel: t.authVerifying,
                        isLoading: state.isBusy && !state.isResending,
                        onPressed: blocked || state.isBusy ? null : _verify,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AuthCountdown(
                        deadline: resendAt,
                        builder: (context, seconds) {
                          final clock =
                              '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
                          return TextButton(
                            key: const Key('auth-resend'),
                            onPressed: seconds > 0 || blocked || state.isBusy
                                ? null
                                : _resend,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (state.isResending) ...[
                                  const TamLoadingIndicator(
                                    size: AppDimensions.buttonProgressSize,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                ],
                                Flexible(
                                  child: Text(
                                    state.isResending
                                        ? t.authSending
                                        : seconds == 0
                                        ? t.authResendCode
                                        : t.authResendCountdown(clock),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            expiry == 0
                                ? Icons.timer_off_outlined
                                : Icons.timer_outlined,
                            size: 18,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              expiry == 0
                                  ? t.authCodeExpired
                                  : t.authCodeExpires(expiry),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        t.authAttemptsRemaining(challenge.attemptsRemaining),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (blocked) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(t.authRestartHint, textAlign: TextAlign.center),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
