import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import '../../domain/account_management_repository.dart';
import '../bloc/account_management_cubit.dart';
import '../widgets/account_feedback.dart';
import '../widgets/account_management_form.dart';

class AccountManagementPage extends StatefulWidget {
  const AccountManagementPage({
    super.key,
    required this.onBack,
    required this.onCompleted,
  });
  final VoidCallback onBack;
  final Future<void> Function() onCompleted;
  @override
  State<AccountManagementPage> createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  final _phone = TextEditingController(), _code = TextEditingController();
  bool _consent = false, _ending = false;
  Future<void> _finish() async {
    if (_ending) return;
    setState(() => _ending = true);
    try {
      await widget.onCompleted();
    } catch (_) {
      /* The finish action permits a local sign-out retry. */
    } finally {
      if (mounted) setState(() => _ending = false);
    }
  }

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context),
        cubit = context.read<AccountManagementCubit>();
    final deleting = cubit.action == AccountAction.deleteAccount;
    return BlocConsumer<AccountManagementCubit, AccountManagementState>(
      listener: (context, state) {
        if (state.ended) {
          _phone.clear();
          _code.clear();
        }
        if (state.receipt != null) unawaited(_finish());
      },
      builder: (context, state) => PopScope(
        canPop: state.receipt == null,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              deleting
                  ? l.accountManagementDeleteAccount
                  : l.accountManagementChangePhone,
            ),
            automaticallyImplyLeading: false,
            leading: state.receipt == null
                ? BackButton(onPressed: widget.onBack)
                : null,
          ),
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView(
                  padding: AppSpacing.pagePadding,
                  children: [
                    Text(
                      l.accountManagementSimulation,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (state.busy)
                      LinearProgressIndicator(
                        semanticsLabel: l.accountManagementBusy,
                      ),
                    if (state.ended)
                      Text(l.accountManagementSessionEnded)
                    else if (state.receipt != null) ...[
                      Text(
                        deleting
                            ? l.accountManagementDeleted
                            : l.accountManagementChanged,
                      ),
                      TamButton.primary(
                        key: const Key('account-finish'),
                        label: l.accountManagementSignOut,
                        onPressed: _ending ? null : _finish,
                      ),
                    ] else ...[
                      if (state.failure != null)
                        AccountFeedback(
                          message: state.locked
                              ? l.accountManagementUncertain
                              : accountFailureLabel(l, state.failure!),
                        ),
                      AccountManagementForm(
                        action: cubit.action,
                        state: state,
                        phoneController: _phone,
                        codeController: _code,
                        consent: _consent,
                        onConsent: (value) => setState(() => _consent = value),
                        onLoad: cubit.load,
                        onStart: () => cubit.start(_phone.text),
                        onConfirm: () => cubit.confirm(_code.text),
                        onResend: cubit.resend,
                        onRestart: cubit.restart,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
