// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Tam';

  @override
  String get authWelcome => 'Welcome to Tam';

  @override
  String get authPhoneDescription => 'Enter your phone number to continue';

  @override
  String get authPhoneLabel => 'Phone number';

  @override
  String get authPhoneHelper =>
      'Syrian mobile in local or international format.';

  @override
  String get authPhoneInvalid => 'Enter a valid Syrian mobile number';

  @override
  String get authSendCode => 'Send verification code';

  @override
  String get authSending => 'Sending code';

  @override
  String get authContinueGuest => 'Continue as a guest';

  @override
  String get authUnifiedAccount =>
      'Your verified number signs you in or creates a new account.';

  @override
  String get authVerifyTitle => 'Verify your phone';

  @override
  String get authVerifyDescription => 'Enter the six-digit verification code';

  @override
  String get authEditPhone => 'Change phone number';

  @override
  String get authCodeLabel => 'Verification code';

  @override
  String get authCodeInvalid => 'Enter all six digits';

  @override
  String get authCodeExpired => 'The code has expired';

  @override
  String get authVerifyCode => 'Verify code';

  @override
  String get authVerifying => 'Verifying';

  @override
  String get authResendCode => 'Resend code';

  @override
  String get authRestartHint =>
      'Go back to your phone number to start again after the waiting period.';

  @override
  String get authRestoring => 'Checking your session';

  @override
  String get authSessionDescription => 'Restoring your account information';

  @override
  String get authRetry => 'Try again';

  @override
  String get authSignOutThisDevice => 'Sign out of this device';

  @override
  String get authGuestTitle => 'You are browsing as a guest';

  @override
  String get authGuestDescription =>
      'Sign in to continue with your phone number.';

  @override
  String get authSignedInTitle => 'You are signed in';

  @override
  String get authLogout => 'Sign out';

  @override
  String get authLoggingOut => 'Signing out';

  @override
  String get authSignIn => 'Sign in';

  @override
  String authRetryIn(int seconds) {
    return 'Try again in $seconds seconds';
  }

  @override
  String authResendIn(int seconds) {
    return 'Resend in $seconds seconds';
  }

  @override
  String authCodeExpires(int seconds) {
    return 'Code expires in $seconds seconds';
  }

  @override
  String authAttemptsRemaining(int count) {
    return 'Attempts remaining: $count';
  }

  @override
  String authSignedInAs(String identity) {
    return 'Welcome, $identity';
  }

  @override
  String get authNationalPhoneHint => '9XX XXX XXX';

  @override
  String get authPhoneWithCountry => 'Phone number, country code +963';

  @override
  String authResendCountdown(String time) {
    return 'Resend code in $time';
  }

  @override
  String get authContinue => 'Continue';

  @override
  String get authContinuing => 'Continuing';

  @override
  String get authPhonePrivacy =>
      'Use your phone number to personalize your experience.';

  @override
  String get homeWelcome => 'Your journey starts with Tam';

  @override
  String get homePhoneTitle => 'Your phone number';

  @override
  String get homeServiceTitle => 'Rides are currently unavailable';

  @override
  String get homeServiceDescription =>
      'Please check back later for service availability.';
}
