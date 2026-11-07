import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get appName;

  /// No description provided for @authWelcome.
  ///
  /// In ar, this message translates to:
  /// **'أهلًا بك في تم'**
  String get authWelcome;

  /// No description provided for @authPhoneDescription.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتفك للمتابعة'**
  String get authPhoneDescription;

  /// No description provided for @authPhoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get authPhoneLabel;

  /// No description provided for @authPhoneHelper.
  ///
  /// In ar, this message translates to:
  /// **'رقم جوال سوري، بصيغته المحلية أو الدولية.'**
  String get authPhoneHelper;

  /// No description provided for @authPhoneInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتف سوريًا صالحًا'**
  String get authPhoneInvalid;

  /// No description provided for @authSendCode.
  ///
  /// In ar, this message translates to:
  /// **'إرسال رمز التحقق'**
  String get authSendCode;

  /// No description provided for @authSending.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ إرسال الرمز'**
  String get authSending;

  /// No description provided for @authContinueGuest.
  ///
  /// In ar, this message translates to:
  /// **'المتابعة كضيف'**
  String get authContinueGuest;

  /// No description provided for @authUnifiedAccount.
  ///
  /// In ar, this message translates to:
  /// **'سنستخدم رقمك لتسجيل الدخول أو إنشاء حساب جديد بعد تأكيده.'**
  String get authUnifiedAccount;

  /// No description provided for @authVerifyTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد رقم الهاتف'**
  String get authVerifyTitle;

  /// No description provided for @authVerifyDescription.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز التحقق المكوّن من ست خانات'**
  String get authVerifyDescription;

  /// No description provided for @authEditPhone.
  ///
  /// In ar, this message translates to:
  /// **'تعديل رقم الهاتف'**
  String get authEditPhone;

  /// No description provided for @authCodeLabel.
  ///
  /// In ar, this message translates to:
  /// **'رمز التحقق'**
  String get authCodeLabel;

  /// No description provided for @authCodeInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز كاملًا من ست خانات'**
  String get authCodeInvalid;

  /// No description provided for @authCodeExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت صلاحية الرمز'**
  String get authCodeExpired;

  /// No description provided for @authVerifyCode.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الرمز'**
  String get authVerifyCode;

  /// No description provided for @authVerifying.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحقق'**
  String get authVerifying;

  /// No description provided for @authResendCode.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الرمز'**
  String get authResendCode;

  /// No description provided for @authRestartHint.
  ///
  /// In ar, this message translates to:
  /// **'عُد لتعديل الرقم وابدأ عملية تحقق جديدة بعد انتهاء فترة الانتظار.'**
  String get authRestartHint;

  /// No description provided for @authRestoring.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من الجلسة'**
  String get authRestoring;

  /// No description provided for @authSessionDescription.
  ///
  /// In ar, this message translates to:
  /// **'نستعيد بيانات حسابك بأمان'**
  String get authSessionDescription;

  /// No description provided for @authRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get authRetry;

  /// No description provided for @authSignOutThisDevice.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج من هذا الجهاز'**
  String get authSignOutThisDevice;

  /// No description provided for @authGuestTitle.
  ///
  /// In ar, this message translates to:
  /// **'أنت تتصفح كضيف'**
  String get authGuestTitle;

  /// No description provided for @authGuestDescription.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول لمتابعة تجربتك برقم هاتفك.'**
  String get authGuestDescription;

  /// No description provided for @authSignedInTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الدخول'**
  String get authSignedInTitle;

  /// No description provided for @authLogout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get authLogout;

  /// No description provided for @authLoggingOut.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تسجيل الخروج'**
  String get authLoggingOut;

  /// No description provided for @authSignIn.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get authSignIn;

  /// No description provided for @authRetryIn.
  ///
  /// In ar, this message translates to:
  /// **'حاول بعد {seconds} ثانية'**
  String authRetryIn(int seconds);

  /// No description provided for @authResendIn.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال بعد {seconds} ثانية'**
  String authResendIn(int seconds);

  /// No description provided for @authCodeExpires.
  ///
  /// In ar, this message translates to:
  /// **'تنتهي صلاحية الرمز خلال {seconds} ثانية'**
  String authCodeExpires(int seconds);

  /// No description provided for @authAttemptsRemaining.
  ///
  /// In ar, this message translates to:
  /// **'المحاولات المتبقية: {count}'**
  String authAttemptsRemaining(int count);

  /// No description provided for @authSignedInAs.
  ///
  /// In ar, this message translates to:
  /// **'مرحبًا، {identity}'**
  String authSignedInAs(String identity);

  /// No description provided for @authNationalPhoneHint.
  ///
  /// In ar, this message translates to:
  /// **'9XX XXX XXX'**
  String get authNationalPhoneHint;

  /// No description provided for @authPhoneWithCountry.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف، رمز البلد +963'**
  String get authPhoneWithCountry;

  /// No description provided for @authResendCountdown.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الرمز بعد {time}'**
  String authResendCountdown(String time);

  /// No description provided for @authContinue.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get authContinue;

  /// No description provided for @authContinuing.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ المتابعة'**
  String get authContinuing;

  /// No description provided for @authPhonePrivacy.
  ///
  /// In ar, this message translates to:
  /// **'استخدم رقم هاتفك لتخصيص تجربتك.'**
  String get authPhonePrivacy;

  /// No description provided for @homeWelcome.
  ///
  /// In ar, this message translates to:
  /// **'رحلتك تبدأ مع تم'**
  String get homeWelcome;

  /// No description provided for @homePhoneTitle.
  ///
  /// In ar, this message translates to:
  /// **'رقم هاتفك'**
  String get homePhoneTitle;

  /// No description provided for @homeServiceTitle.
  ///
  /// In ar, this message translates to:
  /// **'خدمة الرحلات غير متاحة حاليًا'**
  String get homeServiceTitle;

  /// No description provided for @homeServiceDescription.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك العودة لاحقًا للتحقق من توفر الخدمة.'**
  String get homeServiceDescription;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navRideRequest.
  ///
  /// In ar, this message translates to:
  /// **'طلب رحلة'**
  String get navRideRequest;

  /// No description provided for @navTrips.
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get navTrips;

  /// No description provided for @navNotifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get navNotifications;

  /// No description provided for @navSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get navSettings;

  /// No description provided for @featureNotConnected.
  ///
  /// In ar, this message translates to:
  /// **'هذه الميزة غير متاحة حاليًا.'**
  String get featureNotConnected;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
