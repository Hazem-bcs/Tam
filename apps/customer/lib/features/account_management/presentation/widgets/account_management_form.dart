import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_text_field.dart';
import '../../domain/account_management_repository.dart';
import '../bloc/account_management_state.dart';
import 'account_feedback.dart';

class AccountManagementForm extends StatelessWidget {
  const AccountManagementForm({
    super.key,
    required this.action,
    required this.state,
    required this.phoneController,
    required this.codeController,
    required this.consent,
    required this.onConsent,
    required this.onLoad,
    required this.onStart,
    required this.onConfirm,
    required this.onResend,
    required this.onRestart,
  });
  final AccountAction action;
  final AccountManagementState state;
  final TextEditingController phoneController, codeController;
  final bool consent;
  final ValueChanged<bool> onConsent;
  final VoidCallback onLoad, onStart, onConfirm, onResend, onRestart;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final deleting = action == AccountAction.deleteAccount;
    final disabled = state.busy || state.locked || state.ended;
    if (state.eligibility == null) {
      return TamButton.secondary(
        label: l.accountManagementRetry,
        onPressed: state.busy ? null : onLoad,
      );
    }
    if (!state.eligibility!.canManage) {
      return AccountFeedback(
        message: state.eligibility!.phoneE164 == null
            ? l.accountManagementRequired
            : l.accountManagementActiveTrip,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.challenge == null) ...[
          Text(
            deleting
                ? l.accountManagementDeleteNotice
                : l.accountManagementChangedNotice,
          ),
          const SizedBox(height: AppSpacing.md),
          if (deleting)
            CheckboxListTile(
              key: const Key('account-consent'),
              value: consent,
              title: Text(l.accountManagementDeleteConsent),
              onChanged: disabled ? null : (v) => onConsent(v == true),
            )
          else
            TamTextField(
              key: const Key('account-phone'),
              controller: phoneController,
              labelText: l.accountManagementPhone,
              textDirection: TextDirection.ltr,
              keyboardType: TextInputType.phone,
              enabled: !disabled,
            ),
          const SizedBox(height: AppSpacing.lg),
          TamButton.primary(
            key: const Key('account-start'),
            label: state.locked
                ? l.accountManagementRetry
                : l.accountManagementRequestCode,
            onPressed: state.busy || (deleting && !consent) ? null : onStart,
          ),
        ] else ...[
          Text(state.challenge!.phoneE164, textDirection: TextDirection.ltr),
          Text(l.accountManagementOtpHint),
          const SizedBox(height: AppSpacing.lg),
          TamTextField(
            key: const Key('account-code'),
            controller: codeController,
            labelText: l.accountManagementCode,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            enabled: !disabled,
          ),
          const SizedBox(height: AppSpacing.lg),
          TamButton.primary(
            key: const Key('account-confirm'),
            label: state.locked
                ? l.accountManagementRetry
                : l.accountManagementConfirm,
            onPressed: state.busy ? null : onConfirm,
          ),
          TamButton.secondary(
            key: const Key('account-resend'),
            label: l.accountManagementResend,
            onPressed: disabled ? null : onResend,
          ),
          TamButton.secondary(
            key: const Key('account-restart'),
            label: l.accountManagementRestart,
            onPressed: disabled ? null : onRestart,
          ),
        ],
      ],
    );
  }
}
