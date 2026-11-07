import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_phone_field.dart';
import 'package:tam_customer/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    _phone = TextEditingController(
      text: nationalPhoneEntry(
        context.read<AuthCubit>().state.challenge?.phoneE164 ?? '',
      ),
    );
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    if (_form.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      context.read<AuthCubit>().requestOtp(phoneEntryForRequest(_phone.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final directEntry = context
            .read<AuthCubit>()
            .temporaryPhoneEntryEnabled;
        return AuthScaffold(
          title: t.authWelcome,
          description: t.authPhoneDescription,
          busy: state.isBusy,
          child: Form(
            key: _form,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthPhoneField(
                    key: const Key('auth-phone'),
                    controller: _phone,
                    label: t.authPhoneLabel,
                    hint: t.authNationalPhoneHint,
                    semanticLabel: t.authPhoneWithCountry,
                    invalidMessage: t.authPhoneInvalid,
                    readOnly: state.isBusy,
                    onSubmitted: _submit,
                    onChanged: (_) => context.read<AuthCubit>().clearFailure(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (state.failure != null) ...[
                    AuthErrorNotice(failure: state.failure!),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  AuthCountdown(
                    deadline: state.retryAt,
                    builder: (context, seconds) => TamButton.primary(
                      label: seconds > 0
                          ? t.authRetryIn(seconds)
                          : directEntry
                          ? t.authContinue
                          : t.authSendCode,
                      loadingLabel: directEntry
                          ? t.authContinuing
                          : t.authSending,
                      isLoading: state.isBusy,
                      onPressed: seconds > 0 ? null : _submit,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: state.isBusy
                        ? null
                        : context.read<AuthCubit>().continueAsGuest,
                    child: Text(t.authContinueGuest),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    directEntry ? t.authPhonePrivacy : t.authUnifiedAccount,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
