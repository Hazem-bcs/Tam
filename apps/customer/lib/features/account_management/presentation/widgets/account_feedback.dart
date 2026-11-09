import 'package:flutter/material.dart';
import 'package:tam_customer/l10n/app_localizations.dart';

String accountFailureLabel(AppLocalizations l, String code) => switch (code) {
  'ACTIVE_TRIP_EXISTS' => l.accountManagementActiveTrip,
  'ACCOUNT_REQUIRED' => l.accountManagementRequired,
  'PHONE_INVALID' || 'PHONE_UNCHANGED' => l.accountManagementInvalidPhone,
  'PHONE_IN_USE' => l.accountManagementPhoneInUse,
  'VALIDATION_ERROR' => l.accountManagementValidation,
  'OTP_INVALID' => l.accountManagementInvalidCode,
  'OTP_EXPIRED' ||
  'OTP_ATTEMPTS_EXCEEDED' ||
  'CHALLENGE_NOT_FOUND' => l.accountManagementExpired,
  'OTP_COOLDOWN' || 'RATE_LIMITED' => l.accountManagementCooldown,
  'INVALID_RESPONSE' ||
  'IDEMPOTENCY_CONFLICT' => l.accountManagementInvalidResponse,
  _ => l.accountManagementUnavailable,
};

class AccountFeedback extends StatelessWidget {
  const AccountFeedback({super.key, required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.error,
      ),
    ),
  );
}
