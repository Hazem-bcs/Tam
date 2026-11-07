// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'تم';

  @override
  String get authWelcome => 'أهلًا بك في تم';

  @override
  String get authPhoneDescription => 'أدخل رقم هاتفك للمتابعة';

  @override
  String get authPhoneLabel => 'رقم الهاتف';

  @override
  String get authPhoneHelper => 'رقم جوال سوري، بصيغته المحلية أو الدولية.';

  @override
  String get authPhoneInvalid => 'أدخل رقم هاتف سوريًا صالحًا';

  @override
  String get authSendCode => 'إرسال رمز التحقق';

  @override
  String get authSending => 'جارٍ إرسال الرمز';

  @override
  String get authContinueGuest => 'المتابعة كضيف';

  @override
  String get authUnifiedAccount =>
      'سنستخدم رقمك لتسجيل الدخول أو إنشاء حساب جديد بعد تأكيده.';

  @override
  String get authVerifyTitle => 'تأكيد رقم الهاتف';

  @override
  String get authVerifyDescription => 'أدخل رمز التحقق المكوّن من ست خانات';

  @override
  String get authEditPhone => 'تعديل رقم الهاتف';

  @override
  String get authCodeLabel => 'رمز التحقق';

  @override
  String get authCodeInvalid => 'أدخل الرمز كاملًا من ست خانات';

  @override
  String get authCodeExpired => 'انتهت صلاحية الرمز';

  @override
  String get authVerifyCode => 'تأكيد الرمز';

  @override
  String get authVerifying => 'جارٍ التحقق';

  @override
  String get authResendCode => 'إعادة إرسال الرمز';

  @override
  String get authRestartHint =>
      'عُد لتعديل الرقم وابدأ عملية تحقق جديدة بعد انتهاء فترة الانتظار.';

  @override
  String get authRestoring => 'التحقق من الجلسة';

  @override
  String get authSessionDescription => 'نستعيد بيانات حسابك بأمان';

  @override
  String get authRetry => 'إعادة المحاولة';

  @override
  String get authSignOutThisDevice => 'تسجيل الخروج من هذا الجهاز';

  @override
  String get authGuestTitle => 'أنت تتصفح كضيف';

  @override
  String get authGuestDescription => 'سجّل الدخول لمتابعة تجربتك برقم هاتفك.';

  @override
  String get authSignedInTitle => 'تم تسجيل الدخول';

  @override
  String get authLogout => 'تسجيل الخروج';

  @override
  String get authLoggingOut => 'جارٍ تسجيل الخروج';

  @override
  String get authSignIn => 'تسجيل الدخول';

  @override
  String authRetryIn(int seconds) {
    return 'حاول بعد $seconds ثانية';
  }

  @override
  String authResendIn(int seconds) {
    return 'إعادة الإرسال بعد $seconds ثانية';
  }

  @override
  String authCodeExpires(int seconds) {
    return 'تنتهي صلاحية الرمز خلال $seconds ثانية';
  }

  @override
  String authAttemptsRemaining(int count) {
    return 'المحاولات المتبقية: $count';
  }

  @override
  String authSignedInAs(String identity) {
    return 'مرحبًا، $identity';
  }

  @override
  String get authNationalPhoneHint => '9XX XXX XXX';

  @override
  String get authPhoneWithCountry => 'رقم الهاتف، رمز البلد +963';

  @override
  String authResendCountdown(String time) {
    return 'إعادة إرسال الرمز بعد $time';
  }

  @override
  String get authContinue => 'متابعة';

  @override
  String get authContinuing => 'جارٍ المتابعة';

  @override
  String get authPhonePrivacy => 'استخدم رقم هاتفك لتخصيص تجربتك.';

  @override
  String get homeWelcome => 'رحلتك تبدأ مع تم';

  @override
  String get homePhoneTitle => 'رقم هاتفك';

  @override
  String get homeServiceTitle => 'خدمة الرحلات غير متاحة حاليًا';

  @override
  String get homeServiceDescription =>
      'يمكنك العودة لاحقًا للتحقق من توفر الخدمة.';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navRideRequest => 'طلب رحلة';

  @override
  String get navTrips => 'طلباتي';

  @override
  String get navNotifications => 'الإشعارات';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get featureNotConnected => 'هذه الميزة غير متاحة حاليًا.';
}
