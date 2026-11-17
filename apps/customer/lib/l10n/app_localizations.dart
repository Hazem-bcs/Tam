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
  /// **'نشاطي'**
  String get navTrips;

  /// No description provided for @navNotifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get navNotifications;

  /// No description provided for @navSettings.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get navSettings;

  /// No description provided for @featureNotConnected.
  ///
  /// In ar, this message translates to:
  /// **'هذه الميزة غير متاحة حاليًا.'**
  String get featureNotConnected;

  /// No description provided for @authLoginTitle.
  ///
  /// In ar, this message translates to:
  /// **'أهلًا بعودتك'**
  String get authLoginTitle;

  /// No description provided for @authLoginDescription.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك برقم هاتفك.'**
  String get authLoginDescription;

  /// No description provided for @authRegisterTitle.
  ///
  /// In ar, this message translates to:
  /// **'خلّينا نبدأ مشوارك'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterDescription.
  ///
  /// In ar, this message translates to:
  /// **'اسمك ورقمك، ونبدأ مع تم.'**
  String get authRegisterDescription;

  /// No description provided for @authUserName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get authUserName;

  /// No description provided for @authUserNameHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسمك'**
  String get authUserNameHint;

  /// No description provided for @authUserNameInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسمًا من حرفين على الأقل'**
  String get authUserNameInvalid;

  /// No description provided for @authCreateAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get authCreateAccount;

  /// No description provided for @authHaveAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟'**
  String get authHaveAccount;

  /// No description provided for @authNoAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get authNoAccount;

  /// No description provided for @authLegalIntro.
  ///
  /// In ar, this message translates to:
  /// **'بمتابعتك، توافق على'**
  String get authLegalIntro;

  /// No description provided for @authRegisterPreview.
  ///
  /// In ar, this message translates to:
  /// **'معاينة إنشاء الحساب: حفظ الاسم والتسجيل الجديد غير مربوطين بالخادم بعد. يمكنك تسجيل الدخول برقم هاتفك أو المتابعة كضيف.'**
  String get authRegisterPreview;

  /// No description provided for @authRegisterPreviewAction.
  ///
  /// In ar, this message translates to:
  /// **'معاينة البيانات'**
  String get authRegisterPreviewAction;

  /// No description provided for @authRegisterPreviewShort.
  ///
  /// In ar, this message translates to:
  /// **'معاينة للتصميم — إنشاء الحساب غير مربوط بالخادم بعد.'**
  String get authRegisterPreviewShort;

  /// No description provided for @homeGreeting.
  ///
  /// In ar, this message translates to:
  /// **'أهلًا بك،'**
  String get homeGreeting;

  /// No description provided for @homeChooseService.
  ///
  /// In ar, this message translates to:
  /// **'اختر خدمتك'**
  String get homeChooseService;

  /// No description provided for @homeRideEntryTitle.
  ///
  /// In ar, this message translates to:
  /// **'وين حابب تروح؟'**
  String get homeRideEntryTitle;

  /// No description provided for @homeRideEntryHint.
  ///
  /// In ar, this message translates to:
  /// **'حدد نقطة الانطلاق والوجهة لطلب رحلة'**
  String get homeRideEntryHint;

  /// No description provided for @homeRide.
  ///
  /// In ar, this message translates to:
  /// **'مشوار'**
  String get homeRide;

  /// No description provided for @homeFood.
  ///
  /// In ar, this message translates to:
  /// **'الطعام'**
  String get homeFood;

  /// No description provided for @homeShopping.
  ///
  /// In ar, this message translates to:
  /// **'التسوق'**
  String get homeShopping;

  /// No description provided for @homeComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'قريبًا'**
  String get homeComingSoon;

  /// No description provided for @homeLoading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحميل الرئيسية'**
  String get homeLoading;

  /// No description provided for @homeEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد محتوى متاح حاليًا.'**
  String get homeEmpty;

  /// No description provided for @homeUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'خدمة الرئيسية غير متاحة في وضع API حاليًا.'**
  String get homeUnavailable;

  /// No description provided for @homeError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل المحتوى. تحقق من اتصالك وحاول مجددًا.'**
  String get homeError;

  /// No description provided for @homeUnreadNotifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات، غير المقروء: {count}'**
  String homeUnreadNotifications(int count);

  /// No description provided for @homeLandingQuestion.
  ///
  /// In ar, this message translates to:
  /// **'وين رايح اليوم؟'**
  String get homeLandingQuestion;

  /// No description provided for @homeLandingSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'مشوارك يبدأ بخطوة بسيطة'**
  String get homeLandingSubtitle;

  /// No description provided for @homePickupLabel.
  ///
  /// In ar, this message translates to:
  /// **'نقطة الانطلاق'**
  String get homePickupLabel;

  /// No description provided for @homePickupPrompt.
  ///
  /// In ar, this message translates to:
  /// **'من وين بدنا نبلّش؟'**
  String get homePickupPrompt;

  /// No description provided for @homeDestinationLabel.
  ///
  /// In ar, this message translates to:
  /// **'الوجهة'**
  String get homeDestinationLabel;

  /// No description provided for @homeDestinationPrompt.
  ///
  /// In ar, this message translates to:
  /// **'لوين المشوار؟'**
  String get homeDestinationPrompt;

  /// No description provided for @homeBookRide.
  ///
  /// In ar, this message translates to:
  /// **'اطلب مشوار'**
  String get homeBookRide;

  /// No description provided for @homeServicesHeading.
  ///
  /// In ar, this message translates to:
  /// **'خدمات تم'**
  String get homeServicesHeading;

  /// No description provided for @homeServicesDescription.
  ///
  /// In ar, this message translates to:
  /// **'خدمات جديدة لتسهّل يومك، قريبًا'**
  String get homeServicesDescription;

  /// No description provided for @homeRideUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'خدمة المشوار غير متاحة حاليًا.'**
  String get homeRideUnavailable;

  /// No description provided for @homeLatest.
  ///
  /// In ar, this message translates to:
  /// **'آخر الأخبار'**
  String get homeLatest;

  /// No description provided for @homeChooseDestination.
  ///
  /// In ar, this message translates to:
  /// **'حدد وجهتك'**
  String get homeChooseDestination;

  /// No description provided for @homePromotionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعلانات تم'**
  String get homePromotionsTitle;

  /// No description provided for @homePromotionEyebrow.
  ///
  /// In ar, this message translates to:
  /// **'جديد في تم'**
  String get homePromotionEyebrow;

  /// No description provided for @homeServicesComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'قريباً في تم'**
  String get homeServicesComingSoon;

  /// No description provided for @homeBrowsingLabel.
  ///
  /// In ar, this message translates to:
  /// **'تصفح خدمات تم'**
  String get homeBrowsingLabel;

  /// No description provided for @homeCouponTitle.
  ///
  /// In ar, this message translates to:
  /// **'معك كوبون حسم؟'**
  String get homeCouponTitle;

  /// No description provided for @homeCouponHint.
  ///
  /// In ar, this message translates to:
  /// **'وفّر على مشوارك القادم مع تم'**
  String get homeCouponHint;

  /// No description provided for @homeCouponDetails.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get homeCouponDetails;

  /// No description provided for @homeCouponInstructions.
  ///
  /// In ar, this message translates to:
  /// **'اختر مشوارك، ثم أضف الكوبون في خانة كوبون الحسم قبل تأكيد الرحلة. ستظهر قيمة الحسم والسعر الجديد إذا كان الكوبون صالحًا.'**
  String get homeCouponInstructions;

  /// No description provided for @homeSelectDefaultAddress.
  ///
  /// In ar, this message translates to:
  /// **'حدد عنوانك الافتراضي'**
  String get homeSelectDefaultAddress;

  /// No description provided for @rideRequestTitle.
  ///
  /// In ar, this message translates to:
  /// **'احجز مشوارك'**
  String get rideRequestTitle;

  /// No description provided for @rideRequestPickup.
  ///
  /// In ar, this message translates to:
  /// **'نقطة الانطلاق'**
  String get rideRequestPickup;

  /// No description provided for @rideRequestPickupHint.
  ///
  /// In ar, this message translates to:
  /// **'حدد مكان الانطلاق'**
  String get rideRequestPickupHint;

  /// No description provided for @rideRequestDestination.
  ///
  /// In ar, this message translates to:
  /// **'الوجهة'**
  String get rideRequestDestination;

  /// No description provided for @rideRequestDestinationHint.
  ///
  /// In ar, this message translates to:
  /// **'إلى أين تريد الذهاب؟'**
  String get rideRequestDestinationHint;

  /// No description provided for @rideRequestSearchPlaces.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن موقع'**
  String get rideRequestSearchPlaces;

  /// No description provided for @rideRequestNoPlaces.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مواقع مطابقة. جرّب اسمًا آخر.'**
  String get rideRequestNoPlaces;

  /// No description provided for @rideRequestMockMap.
  ///
  /// In ar, this message translates to:
  /// **'خريطة توضيحية • المواقع محاكاة وليست GPS'**
  String get rideRequestMockMap;

  /// No description provided for @rideRequestRouteHint.
  ///
  /// In ar, this message translates to:
  /// **'اختر الانطلاق والوجهة لعرض السعر التقريبي.'**
  String get rideRequestRouteHint;

  /// No description provided for @rideRequestChooseClass.
  ///
  /// In ar, this message translates to:
  /// **'حدد نوع الرحلة'**
  String get rideRequestChooseClass;

  /// No description provided for @rideRequestStandard.
  ///
  /// In ar, this message translates to:
  /// **'عادية'**
  String get rideRequestStandard;

  /// No description provided for @rideRequestStandardDescription.
  ///
  /// In ar, this message translates to:
  /// **'لمشاويرك اليومية'**
  String get rideRequestStandardDescription;

  /// No description provided for @rideRequestComfort.
  ///
  /// In ar, this message translates to:
  /// **'مريحة'**
  String get rideRequestComfort;

  /// No description provided for @rideRequestComfortDescription.
  ///
  /// In ar, this message translates to:
  /// **'مساحة وراحة أكثر'**
  String get rideRequestComfortDescription;

  /// No description provided for @rideRequestVan.
  ///
  /// In ar, this message translates to:
  /// **'فان'**
  String get rideRequestVan;

  /// No description provided for @rideRequestVanDescription.
  ///
  /// In ar, this message translates to:
  /// **'للمجموعات والعائلة'**
  String get rideRequestVanDescription;

  /// No description provided for @rideRequestMotorbike.
  ///
  /// In ar, this message translates to:
  /// **'موتور'**
  String get rideRequestMotorbike;

  /// No description provided for @rideRequestMotorbikeDescription.
  ///
  /// In ar, this message translates to:
  /// **'للمستندات والطرود'**
  String get rideRequestMotorbikeDescription;

  /// No description provided for @rideRequestQuoteTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الرحلة'**
  String get rideRequestQuoteTitle;

  /// No description provided for @rideRequestDistance.
  ///
  /// In ar, this message translates to:
  /// **'المسافة'**
  String get rideRequestDistance;

  /// No description provided for @rideRequestDuration.
  ///
  /// In ar, this message translates to:
  /// **'المدة'**
  String get rideRequestDuration;

  /// No description provided for @rideRequestFare.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get rideRequestFare;

  /// No description provided for @rideRequestCurrencySyp.
  ///
  /// In ar, this message translates to:
  /// **'ل.س'**
  String get rideRequestCurrencySyp;

  /// No description provided for @rideRequestKm.
  ///
  /// In ar, this message translates to:
  /// **'كم'**
  String get rideRequestKm;

  /// No description provided for @rideRequestMinute.
  ///
  /// In ar, this message translates to:
  /// **'دقيقة'**
  String get rideRequestMinute;

  /// No description provided for @rideRequestPayment.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get rideRequestPayment;

  /// No description provided for @rideRequestCash.
  ///
  /// In ar, this message translates to:
  /// **'نقدًا'**
  String get rideRequestCash;

  /// No description provided for @rideRequestCashOnly.
  ///
  /// In ar, this message translates to:
  /// **'الدفع النقدي متاح حاليًا في المحاكاة فقط.'**
  String get rideRequestCashOnly;

  /// No description provided for @rideRequestReview.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة الطلب'**
  String get rideRequestReview;

  /// No description provided for @rideRequestConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد طلب الرحلة'**
  String get rideRequestConfirm;

  /// No description provided for @rideRequestConfirming.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تأكيد الطلب'**
  String get rideRequestConfirming;

  /// No description provided for @rideRequestQuoteLoading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ احتساب السعر'**
  String get rideRequestQuoteLoading;

  /// No description provided for @rideRequestRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get rideRequestRetry;

  /// No description provided for @rideRequestRefreshQuote.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تسعير الرحلة'**
  String get rideRequestRefreshQuote;

  /// No description provided for @rideRequestErrorValidation.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من اختيار موقعين مختلفين وفئة صالحة.'**
  String get rideRequestErrorValidation;

  /// No description provided for @rideRequestErrorExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت صلاحية السعر. اطلب سعرًا جديدًا.'**
  String get rideRequestErrorExpired;

  /// No description provided for @rideRequestErrorUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'الخدمة غير متاحة الآن. حاول مجددًا.'**
  String get rideRequestErrorUnavailable;

  /// No description provided for @rideRequestErrorConflict.
  ///
  /// In ar, this message translates to:
  /// **'تعذر التأكيد بسبب تعارض في الطلب.'**
  String get rideRequestErrorConflict;

  /// No description provided for @rideRequestErrorGeneric.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إكمال العملية. حاول مجددًا.'**
  String get rideRequestErrorGeneric;

  /// No description provided for @rideRequestSimulationNotice.
  ///
  /// In ar, this message translates to:
  /// **'تجربة محلية فقط: لا تُرسل رحلة حقيقية ولا تُخصم مبالغ.'**
  String get rideRequestSimulationNotice;

  /// No description provided for @rideRequestSelected.
  ///
  /// In ar, this message translates to:
  /// **'تم الاختيار'**
  String get rideRequestSelected;

  /// No description provided for @rideRequestPlaceSearchLoading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ البحث عن المواقع'**
  String get rideRequestPlaceSearchLoading;

  /// No description provided for @rideRequestEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get rideRequestEdit;

  /// No description provided for @rideRequestImmediate.
  ///
  /// In ar, this message translates to:
  /// **'فوري'**
  String get rideRequestImmediate;

  /// No description provided for @rideRequestScheduled.
  ///
  /// In ar, this message translates to:
  /// **'مجدولة'**
  String get rideRequestScheduled;

  /// No description provided for @rideRequestScheduleTitle.
  ///
  /// In ar, this message translates to:
  /// **'حدد موعد الرحلة'**
  String get rideRequestScheduleTitle;

  /// No description provided for @rideRequestScheduleDate.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get rideRequestScheduleDate;

  /// No description provided for @rideRequestScheduleTime.
  ///
  /// In ar, this message translates to:
  /// **'موعد الرحلة'**
  String get rideRequestScheduleTime;

  /// No description provided for @rideRequestScheduleTimezone.
  ///
  /// In ar, this message translates to:
  /// **'التوقيت المعتمد: {offset}'**
  String rideRequestScheduleTimezone(String offset);

  /// No description provided for @rideRequestScheduleRange.
  ///
  /// In ar, this message translates to:
  /// **'اختر موعدًا بين {minutes} دقيقة و{days} أيام من الآن.'**
  String rideRequestScheduleRange(int minutes, int days);

  /// No description provided for @rideRequestScheduleInvalid.
  ///
  /// In ar, this message translates to:
  /// **'الموعد خارج المدى المتاح الآن. عدّل التاريخ أو الوقت ثم أعد المحاولة.'**
  String get rideRequestScheduleInvalid;

  /// No description provided for @rideRequestScheduleUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'الجدولة غير متاحة لهذا الموعد. اختر موعدًا آخر أو اطلب رحلة فورية.'**
  String get rideRequestScheduleUnavailable;

  /// No description provided for @rideRequestScheduleSave.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الموعد'**
  String get rideRequestScheduleSave;

  /// No description provided for @rideRequestScheduleCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get rideRequestScheduleCancel;

  /// No description provided for @rideRequestScheduledNotice.
  ///
  /// In ar, this message translates to:
  /// **'حجز موعد مسبق لا يعني تعيين سائق الآن.'**
  String get rideRequestScheduledNotice;

  /// No description provided for @rideRequestHour.
  ///
  /// In ar, this message translates to:
  /// **'الساعة'**
  String get rideRequestHour;

  /// No description provided for @rideRequestMinuteInput.
  ///
  /// In ar, this message translates to:
  /// **'الدقيقة'**
  String get rideRequestMinuteInput;

  /// No description provided for @rideRequestTimeFormat.
  ///
  /// In ar, this message translates to:
  /// **'الوقت بنظام 24 ساعة (00–23).'**
  String get rideRequestTimeFormat;

  /// No description provided for @rideRequestTimeInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل قيمة صحيحة ضمن المجال.'**
  String get rideRequestTimeInvalid;

  /// No description provided for @rideRequestFlowStartTitle.
  ///
  /// In ar, this message translates to:
  /// **'لوين مشوارك؟'**
  String get rideRequestFlowStartTitle;

  /// No description provided for @rideRequestFlowStartSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'المس وجهتك على الخريطة، أو ابحث عنها'**
  String get rideRequestFlowStartSubtitle;

  /// No description provided for @rideRequestFlowStartAction.
  ///
  /// In ar, this message translates to:
  /// **'تحديد مسار الرحلة'**
  String get rideRequestFlowStartAction;

  /// No description provided for @rideRequestFlowPickupTitle.
  ///
  /// In ar, this message translates to:
  /// **'من وين بدك تنطلق؟'**
  String get rideRequestFlowPickupTitle;

  /// No description provided for @rideRequestFlowDestinationTitle.
  ///
  /// In ar, this message translates to:
  /// **'لوين بدك توصل؟'**
  String get rideRequestFlowDestinationTitle;

  /// No description provided for @rideRequestFlowChoosePlaces.
  ///
  /// In ar, this message translates to:
  /// **'حدد الانطلاق والوجهة'**
  String get rideRequestFlowChoosePlaces;

  /// No description provided for @rideRequestFlowContinue.
  ///
  /// In ar, this message translates to:
  /// **'متابعة اختيارك'**
  String get rideRequestFlowContinue;

  /// No description provided for @rideRequestFlowReviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد تفاصيل الرحلة'**
  String get rideRequestFlowReviewTitle;

  /// No description provided for @rideRequestFlowReviewSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'راجع مشوارك قبل تأكيده'**
  String get rideRequestFlowReviewSubtitle;

  /// No description provided for @rideRequestFlowVisualMap.
  ///
  /// In ar, this message translates to:
  /// **'مخطط توضيحي • الخرائط الحية غير متصلة'**
  String get rideRequestFlowVisualMap;

  /// No description provided for @rideRequestFlowSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'طلبك تمّ'**
  String get rideRequestFlowSubmitted;

  /// No description provided for @rideRequestFlowStep.
  ///
  /// In ar, this message translates to:
  /// **'الخطوة {current} من {total}'**
  String rideRequestFlowStep(int current, int total);

  /// No description provided for @rideRequestExpandPanel.
  ///
  /// In ar, this message translates to:
  /// **'إظهار تفاصيل المشوار'**
  String get rideRequestExpandPanel;

  /// No description provided for @rideRequestCollapsePanel.
  ///
  /// In ar, this message translates to:
  /// **'طي التفاصيل وتوسيع الخريطة'**
  String get rideRequestCollapsePanel;

  /// No description provided for @rideRequestProgressPlan.
  ///
  /// In ar, this message translates to:
  /// **'خطط لمشوارك'**
  String get rideRequestProgressPlan;

  /// No description provided for @rideRequestProgressVehicle.
  ///
  /// In ar, this message translates to:
  /// **'اختيار المركبة'**
  String get rideRequestProgressVehicle;

  /// No description provided for @rideRequestProgressReview.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة المشوار'**
  String get rideRequestProgressReview;

  /// No description provided for @rideRequestProgressMatching.
  ///
  /// In ar, this message translates to:
  /// **'نبحث عن سائقك'**
  String get rideRequestProgressMatching;

  /// No description provided for @rideRequestMapPoint.
  ///
  /// In ar, this message translates to:
  /// **'نقطة على الخريطة'**
  String get rideRequestMapPoint;

  /// No description provided for @rideRequestMapPointTitle.
  ///
  /// In ar, this message translates to:
  /// **'هذا المكان…'**
  String get rideRequestMapPointTitle;

  /// No description provided for @rideRequestMapPointHint.
  ///
  /// In ar, this message translates to:
  /// **'تريده وجهة الوصول أم نقطة الانطلاق؟'**
  String get rideRequestMapPointHint;

  /// No description provided for @rideRequestMapPointDescription.
  ///
  /// In ar, this message translates to:
  /// **'وصف المكان (اختياري)'**
  String get rideRequestMapPointDescription;

  /// No description provided for @rideRequestMapPointCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء اختيار النقطة'**
  String get rideRequestMapPointCancel;

  /// No description provided for @rideRequestUseAsDestination.
  ///
  /// In ar, this message translates to:
  /// **'اجعلها الوجهة'**
  String get rideRequestUseAsDestination;

  /// No description provided for @rideRequestUseAsPickup.
  ///
  /// In ar, this message translates to:
  /// **'اجعلها نقطة الانطلاق'**
  String get rideRequestUseAsPickup;

  /// No description provided for @rideRequestPickupMoved.
  ///
  /// In ar, this message translates to:
  /// **'تغيّر موقع انطلاقك. حدّثنا المسار، راجع السعر والتفاصيل قبل التأكيد.'**
  String get rideRequestPickupMoved;

  /// No description provided for @rideRequestPickFromMap.
  ///
  /// In ar, this message translates to:
  /// **'حدد نقطة من الخريطة'**
  String get rideRequestPickFromMap;

  /// No description provided for @rideRequestPickFromMapHint.
  ///
  /// In ar, this message translates to:
  /// **'حرّك الخريطة والمس المكان'**
  String get rideRequestPickFromMapHint;

  /// No description provided for @rideRequestSuggestedPlaces.
  ///
  /// In ar, this message translates to:
  /// **'أماكن مقترحة'**
  String get rideRequestSuggestedPlaces;

  /// No description provided for @rideRequestSearchResults.
  ///
  /// In ar, this message translates to:
  /// **'نتائج البحث'**
  String get rideRequestSearchResults;

  /// No description provided for @rideRequestPhasePlace.
  ///
  /// In ar, this message translates to:
  /// **'المكان'**
  String get rideRequestPhasePlace;

  /// No description provided for @rideRequestPhaseVehicle.
  ///
  /// In ar, this message translates to:
  /// **'المركبة'**
  String get rideRequestPhaseVehicle;

  /// No description provided for @rideRequestPhaseConfirm.
  ///
  /// In ar, this message translates to:
  /// **'التأكيد'**
  String get rideRequestPhaseConfirm;

  /// No description provided for @rideRequestPhasePickup.
  ///
  /// In ar, this message translates to:
  /// **'الانطلاق'**
  String get rideRequestPhasePickup;

  /// No description provided for @rideRequestSelectedPlace.
  ///
  /// In ar, this message translates to:
  /// **'المكان المحدد'**
  String get rideRequestSelectedPlace;

  /// No description provided for @rideRequestConfirmMapPoint.
  ///
  /// In ar, this message translates to:
  /// **'اعتمد هذه النقطة على الخريطة'**
  String get rideRequestConfirmMapPoint;

  /// No description provided for @rideRequestAddDriverNote.
  ///
  /// In ar, this message translates to:
  /// **'أضف وصفًا للسائق'**
  String get rideRequestAddDriverNote;

  /// No description provided for @rideRequestDriverNoteHint.
  ///
  /// In ar, this message translates to:
  /// **'مثلاً: بجانب المدخل الرئيسي'**
  String get rideRequestDriverNoteHint;

  /// No description provided for @rideRequestConfirmPickup.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد نقطة الانطلاق'**
  String get rideRequestConfirmPickup;

  /// No description provided for @rideRequestConfirmDestination.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد الوجهة'**
  String get rideRequestConfirmDestination;

  /// No description provided for @rideRequestSearchPickupTitle.
  ///
  /// In ar, this message translates to:
  /// **'من أين؟'**
  String get rideRequestSearchPickupTitle;

  /// No description provided for @rideRequestSearchDestinationTitle.
  ///
  /// In ar, this message translates to:
  /// **'إلى أين؟'**
  String get rideRequestSearchDestinationTitle;

  /// No description provided for @rideRequestSearchDestinationHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن وجهتك'**
  String get rideRequestSearchDestinationHint;

  /// No description provided for @rideRequestSearchFrom.
  ///
  /// In ar, this message translates to:
  /// **'من {place}'**
  String rideRequestSearchFrom(String place);

  /// No description provided for @rideRequestSearchTo.
  ///
  /// In ar, this message translates to:
  /// **'إلى {place}'**
  String rideRequestSearchTo(String place);

  /// No description provided for @rideRequestChooseFromMap.
  ///
  /// In ar, this message translates to:
  /// **'اختيار من الخريطة'**
  String get rideRequestChooseFromMap;

  /// No description provided for @rideRequestSavedPlaces.
  ///
  /// In ar, this message translates to:
  /// **'عناوينك المحفوظة'**
  String get rideRequestSavedPlaces;

  /// No description provided for @rideRequestClearSearch.
  ///
  /// In ar, this message translates to:
  /// **'مسح البحث'**
  String get rideRequestClearSearch;

  /// No description provided for @rideRequestWallet.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة'**
  String get rideRequestWallet;

  /// No description provided for @rideRequestEstimatedFare.
  ///
  /// In ar, this message translates to:
  /// **'التكلفة التقديرية'**
  String get rideRequestEstimatedFare;

  /// No description provided for @rideRequestDiscountedFare.
  ///
  /// In ar, this message translates to:
  /// **'التكلفة بعد الحسم'**
  String get rideRequestDiscountedFare;

  /// No description provided for @rideRequestLivePriceHint.
  ///
  /// In ar, this message translates to:
  /// **'اختر مركبتك وشاهد التكلفة مباشرة'**
  String get rideRequestLivePriceHint;

  /// No description provided for @rideRequestVehicleAndConfirm.
  ///
  /// In ar, this message translates to:
  /// **'المركبة والتأكيد'**
  String get rideRequestVehicleAndConfirm;

  /// No description provided for @rideRequestVehicleScrollHint.
  ///
  /// In ar, this message translates to:
  /// **'اسحب لمقارنة الفئات'**
  String get rideRequestVehicleScrollHint;

  /// No description provided for @rideRequestNextVehicles.
  ///
  /// In ar, this message translates to:
  /// **'مركبات أخرى'**
  String get rideRequestNextVehicles;

  /// No description provided for @rideRequestPreviousVehicles.
  ///
  /// In ar, this message translates to:
  /// **'المركبات السابقة'**
  String get rideRequestPreviousVehicles;

  /// No description provided for @rideRequestCoupon.
  ///
  /// In ar, this message translates to:
  /// **'كوبون حسم'**
  String get rideRequestCoupon;

  /// No description provided for @rideRequestCouponHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز الكوبون'**
  String get rideRequestCouponHint;

  /// No description provided for @rideRequestApplyCoupon.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق'**
  String get rideRequestApplyCoupon;

  /// No description provided for @rideRequestRemoveCoupon.
  ///
  /// In ar, this message translates to:
  /// **'إزالة الكوبون'**
  String get rideRequestRemoveCoupon;

  /// No description provided for @rideRequestCouponInvalid.
  ///
  /// In ar, this message translates to:
  /// **'الكوبون غير صالح أو انتهت صلاحيته. صحّحه أو أزله للمتابعة.'**
  String get rideRequestCouponInvalid;

  /// No description provided for @rideRequestCouponSaving.
  ///
  /// In ar, this message translates to:
  /// **'وفّرت {amount} ل.س'**
  String rideRequestCouponSaving(String amount);

  /// No description provided for @rideRequestFareUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'السعر غير متاح حاليًا'**
  String get rideRequestFareUnavailable;

  /// No description provided for @rideRequestFareDisclaimer.
  ///
  /// In ar, this message translates to:
  /// **'قد يتغير التقدير عند تعديل المسار أو الموعد'**
  String get rideRequestFareDisclaimer;

  /// No description provided for @rideRequestPaymentUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع غير متاحة. اختر النقد أو أعد المحاولة.'**
  String get rideRequestPaymentUnavailable;

  /// No description provided for @rideRequestWalletInsufficient.
  ///
  /// In ar, this message translates to:
  /// **'رصيد المحفظة غير كافٍ. اختر الدفع النقدي للمتابعة.'**
  String get rideRequestWalletInsufficient;

  /// No description provided for @tripsAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get tripsAll;

  /// No description provided for @tripsActive.
  ///
  /// In ar, this message translates to:
  /// **'النشطة'**
  String get tripsActive;

  /// No description provided for @tripsCompletedFilter.
  ///
  /// In ar, this message translates to:
  /// **'المكتملة'**
  String get tripsCompletedFilter;

  /// No description provided for @tripsCancelledFilter.
  ///
  /// In ar, this message translates to:
  /// **'الملغاة'**
  String get tripsCancelledFilter;

  /// No description provided for @tripsStatusRequested.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار التأكيد'**
  String get tripsStatusRequested;

  /// No description provided for @tripsStatusConfirmed.
  ///
  /// In ar, this message translates to:
  /// **'مؤكدة'**
  String get tripsStatusConfirmed;

  /// No description provided for @tripsStatusInProgress.
  ///
  /// In ar, this message translates to:
  /// **'قيد التنفيذ'**
  String get tripsStatusInProgress;

  /// No description provided for @tripsStatusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get tripsStatusCompleted;

  /// No description provided for @tripsStatusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة'**
  String get tripsStatusCancelled;

  /// No description provided for @tripsFrom.
  ///
  /// In ar, this message translates to:
  /// **'من'**
  String get tripsFrom;

  /// No description provided for @tripsTo.
  ///
  /// In ar, this message translates to:
  /// **'إلى'**
  String get tripsTo;

  /// No description provided for @tripsDetails.
  ///
  /// In ar, this message translates to:
  /// **'التفاصيل'**
  String get tripsDetails;

  /// No description provided for @tripsDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الطلب'**
  String get tripsDetailsTitle;

  /// No description provided for @tripsTripNumber.
  ///
  /// In ar, this message translates to:
  /// **'الرحلة رقم {id}'**
  String tripsTripNumber(String id);

  /// No description provided for @tripsCreatedAt.
  ///
  /// In ar, this message translates to:
  /// **'وقت الطلب'**
  String get tripsCreatedAt;

  /// No description provided for @tripsFare.
  ///
  /// In ar, this message translates to:
  /// **'الأجرة'**
  String get tripsFare;

  /// No description provided for @tripsVehicleClass.
  ///
  /// In ar, this message translates to:
  /// **'فئة المركبة'**
  String get tripsVehicleClass;

  /// No description provided for @tripsVehicleStandard.
  ///
  /// In ar, this message translates to:
  /// **'عادية'**
  String get tripsVehicleStandard;

  /// No description provided for @tripsEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رحلات هنا'**
  String get tripsEmptyTitle;

  /// No description provided for @tripsEmptyDescription.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر رحلاتك في هذا القسم عندما تتوفر.'**
  String get tripsEmptyDescription;

  /// No description provided for @tripsErrorTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الرحلات'**
  String get tripsErrorTitle;

  /// No description provided for @tripsErrorDescription.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من اتصالك وأعد المحاولة.'**
  String get tripsErrorDescription;

  /// No description provided for @tripsRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get tripsRetry;

  /// No description provided for @tripsRefresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get tripsRefresh;

  /// No description provided for @tripsLoadMore.
  ///
  /// In ar, this message translates to:
  /// **'عرض المزيد'**
  String get tripsLoadMore;

  /// No description provided for @tripsCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الرحلة'**
  String get tripsCancel;

  /// No description provided for @tripsCancelTitle.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إلغاء الرحلة؟'**
  String get tripsCancelTitle;

  /// No description provided for @tripsCancelPrompt.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن التراجع عن الإلغاء بعد تأكيده.'**
  String get tripsCancelPrompt;

  /// No description provided for @tripsConfirmCancel.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الإلغاء'**
  String get tripsConfirmCancel;

  /// No description provided for @tripsKeepTrip.
  ///
  /// In ar, this message translates to:
  /// **'الاحتفاظ بالرحلة'**
  String get tripsKeepTrip;

  /// No description provided for @tripsCancelledSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء الرحلة.'**
  String get tripsCancelledSuccess;

  /// No description provided for @tripsCannotCancel.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن إلغاء الرحلة في حالتها الحالية.'**
  String get tripsCannotCancel;

  /// No description provided for @tripsRebook.
  ///
  /// In ar, this message translates to:
  /// **'اطلب مجددًا'**
  String get tripsRebook;

  /// No description provided for @tripsNotFoundTitle.
  ///
  /// In ar, this message translates to:
  /// **'الرحلة غير موجودة'**
  String get tripsNotFoundTitle;

  /// No description provided for @tripsNotFoundDescription.
  ///
  /// In ar, this message translates to:
  /// **'ربما حُذفت هذه الرحلة أو لم يعد الوصول إليها متاحًا.'**
  String get tripsNotFoundDescription;

  /// No description provided for @tripsBackToList.
  ///
  /// In ar, this message translates to:
  /// **'العودة إلى طلباتي'**
  String get tripsBackToList;

  /// No description provided for @tripsFareNote.
  ///
  /// In ar, this message translates to:
  /// **'هذه أجرة محفوظة للرحلة السابقة، ولا تُستخدم عند إعادة الطلب.'**
  String get tripsFareNote;

  /// No description provided for @tripsServiceUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'خدمة الرحلات غير متاحة حاليًا.'**
  String get tripsServiceUnavailable;

  /// No description provided for @tripsValidationError.
  ///
  /// In ar, this message translates to:
  /// **'الطلب غير صالح. أعد المحاولة.'**
  String get tripsValidationError;

  /// No description provided for @tripsUnknownError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع. أعد المحاولة.'**
  String get tripsUnknownError;

  /// No description provided for @tripsPaginationError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل المزيد من الرحلات.'**
  String get tripsPaginationError;

  /// No description provided for @tripsRoute.
  ///
  /// In ar, this message translates to:
  /// **'مسار الرحلة'**
  String get tripsRoute;

  /// No description provided for @tripsInformation.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الرحلة'**
  String get tripsInformation;

  /// No description provided for @tripsNoLiveTracking.
  ///
  /// In ar, this message translates to:
  /// **'لا يتوفر تتبع مباشر للرحلة في هذا الإصدار.'**
  String get tripsNoLiveTracking;

  /// No description provided for @tripsLoading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحميل الرحلات'**
  String get tripsLoading;

  /// No description provided for @tripsLoadingDetails.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحميل تفاصيل الرحلة'**
  String get tripsLoadingDetails;

  /// No description provided for @tripsCancelling.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الإلغاء'**
  String get tripsCancelling;

  /// No description provided for @tripsTripList.
  ///
  /// In ar, this message translates to:
  /// **'قائمة الرحلات'**
  String get tripsTripList;

  /// No description provided for @tripsStatusScheduled.
  ///
  /// In ar, this message translates to:
  /// **'مجدولة'**
  String get tripsStatusScheduled;

  /// No description provided for @tripsScheduledTime.
  ///
  /// In ar, this message translates to:
  /// **'موعد الرحلة'**
  String get tripsScheduledTime;

  /// No description provided for @tripsScheduledAt.
  ///
  /// In ar, this message translates to:
  /// **'الموعد: {time}'**
  String tripsScheduledAt(String time);

  /// No description provided for @tripsStatusDriverEnRoute.
  ///
  /// In ar, this message translates to:
  /// **'السائق في الطريق'**
  String get tripsStatusDriverEnRoute;

  /// No description provided for @tripsStatusDriverArrived.
  ///
  /// In ar, this message translates to:
  /// **'السائق ينتظرك'**
  String get tripsStatusDriverArrived;

  /// No description provided for @tripsStatusNoDriver.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد سائق'**
  String get tripsStatusNoDriver;

  /// No description provided for @tripsCompletion.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الرحلة وتقييمها'**
  String get tripsCompletion;

  /// No description provided for @tripsSupport.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة بخصوص الرحلة'**
  String get tripsSupport;

  /// No description provided for @tripsActivityTitle.
  ///
  /// In ar, this message translates to:
  /// **'نشاطي'**
  String get tripsActivityTitle;

  /// No description provided for @tripsAccountLabel.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get tripsAccountLabel;

  /// No description provided for @tripsServiceRides.
  ///
  /// In ar, this message translates to:
  /// **'الرحلات'**
  String get tripsServiceRides;

  /// No description provided for @tripsServiceShopping.
  ///
  /// In ar, this message translates to:
  /// **'التسوق'**
  String get tripsServiceShopping;

  /// No description provided for @tripsServiceFood.
  ///
  /// In ar, this message translates to:
  /// **'الطعام'**
  String get tripsServiceFood;

  /// No description provided for @tripsSoon.
  ///
  /// In ar, this message translates to:
  /// **'قريباً'**
  String get tripsSoon;

  /// No description provided for @tripsFilterLabel.
  ///
  /// In ar, this message translates to:
  /// **'تصفية الرحلات'**
  String get tripsFilterLabel;

  /// No description provided for @tripsActiveJourney.
  ///
  /// In ar, this message translates to:
  /// **'رحلة جارية'**
  String get tripsActiveJourney;

  /// No description provided for @tripsFollowJourney.
  ///
  /// In ar, this message translates to:
  /// **'متابعة الرحلة'**
  String get tripsFollowJourney;

  /// No description provided for @tripsToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get tripsToday;

  /// No description provided for @tripsYesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get tripsYesterday;

  /// No description provided for @tripsActivitySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'كل مشوار، وتفاصيله معك'**
  String get tripsActivitySubtitle;

  /// No description provided for @tripsHistoryHeading.
  ///
  /// In ar, this message translates to:
  /// **'آخر مشاويرك'**
  String get tripsHistoryHeading;

  /// No description provided for @tripsLiveHeading.
  ///
  /// In ar, this message translates to:
  /// **'على الطريق الآن'**
  String get tripsLiveHeading;

  /// No description provided for @tripsVisibleCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} في السجل'**
  String tripsVisibleCount(int count);

  /// No description provided for @tripsNextPrompt.
  ///
  /// In ar, this message translates to:
  /// **'جاهز لمشوار جديد؟'**
  String get tripsNextPrompt;

  /// No description provided for @tripsNextSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الوجهة الجاية أقرب مما تتخيل'**
  String get tripsNextSubtitle;

  /// No description provided for @tripsCurrencySyp.
  ///
  /// In ar, this message translates to:
  /// **'ل.س'**
  String get tripsCurrencySyp;

  /// No description provided for @tripsDriverSection.
  ///
  /// In ar, this message translates to:
  /// **'بيانات السائق'**
  String get tripsDriverSection;

  /// No description provided for @tripsDriverUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'لم تتوفر بيانات السائق لهذه الرحلة'**
  String get tripsDriverUnavailable;

  /// No description provided for @tripsFareSection.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الأجرة'**
  String get tripsFareSection;

  /// No description provided for @tripsRecordedTotal.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الأجرة المسجّلة'**
  String get tripsRecordedTotal;

  /// No description provided for @tripsPaymentStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة الدفع'**
  String get tripsPaymentStatus;

  /// No description provided for @tripsUnavailableValue.
  ///
  /// In ar, this message translates to:
  /// **'غير متوفر'**
  String get tripsUnavailableValue;

  /// No description provided for @tripsPaymentUnconfirmed.
  ///
  /// In ar, this message translates to:
  /// **'غير مؤكدة في بيانات الرحلة'**
  String get tripsPaymentUnconfirmed;

  /// No description provided for @tripsDiscountUnrecorded.
  ///
  /// In ar, this message translates to:
  /// **'قيمة الخصم غير محفوظة'**
  String get tripsDiscountUnrecorded;

  /// No description provided for @tripsDistance.
  ///
  /// In ar, this message translates to:
  /// **'المسافة'**
  String get tripsDistance;

  /// No description provided for @tripsDuration.
  ///
  /// In ar, this message translates to:
  /// **'مدة الرحلة'**
  String get tripsDuration;

  /// No description provided for @tripsRateAction.
  ///
  /// In ar, this message translates to:
  /// **'تقييم الرحلة'**
  String get tripsRateAction;

  /// No description provided for @tripsSupportAction.
  ///
  /// In ar, this message translates to:
  /// **'التواصل مع الدعم'**
  String get tripsSupportAction;

  /// No description provided for @tripsRecordedDistance.
  ///
  /// In ar, this message translates to:
  /// **'{value} كم'**
  String tripsRecordedDistance(String value);

  /// No description provided for @tripsRecordedDuration.
  ///
  /// In ar, this message translates to:
  /// **'{value} دقيقة'**
  String tripsRecordedDuration(String value);

  /// No description provided for @tripsDiscountAmount.
  ///
  /// In ar, this message translates to:
  /// **'خصم الكوبون'**
  String get tripsDiscountAmount;

  /// No description provided for @tripsPaid.
  ///
  /// In ar, this message translates to:
  /// **'مدفوع'**
  String get tripsPaid;

  /// No description provided for @tripsUnpaid.
  ///
  /// In ar, this message translates to:
  /// **'غير مدفوع'**
  String get tripsUnpaid;

  /// No description provided for @tripsDemoReceipt.
  ///
  /// In ar, this message translates to:
  /// **'معاينة ببيانات رحلة تجريبية، وليست عملية دفع حقيقية.'**
  String get tripsDemoReceipt;

  /// No description provided for @notificationsMarkAll.
  ///
  /// In ar, this message translates to:
  /// **'تعيين الكل كمقروء'**
  String get notificationsMarkAll;

  /// No description provided for @notificationsUnreadCount.
  ///
  /// In ar, this message translates to:
  /// **'غير مقروء: {count}'**
  String notificationsUnreadCount(int count);

  /// No description provided for @notificationsUnknownCount.
  ///
  /// In ar, this message translates to:
  /// **'العدد غير متاح'**
  String get notificationsUnknownCount;

  /// No description provided for @notificationsToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get notificationsToday;

  /// No description provided for @notificationsYesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get notificationsYesterday;

  /// No description provided for @notificationsEarlier.
  ///
  /// In ar, this message translates to:
  /// **'سابقًا'**
  String get notificationsEarlier;

  /// No description provided for @notificationsLoadMore.
  ///
  /// In ar, this message translates to:
  /// **'عرض المزيد'**
  String get notificationsLoadMore;

  /// No description provided for @notificationsLoadingMore.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل المزيد'**
  String get notificationsLoadingMore;

  /// No description provided for @notificationsRefresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get notificationsRefresh;

  /// No description provided for @notificationsRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get notificationsRetry;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات بعد'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر إشعاراتك هنا عند توفرها.'**
  String get notificationsEmptyBody;

  /// No description provided for @notificationsErrorTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل الإشعارات'**
  String get notificationsErrorTitle;

  /// No description provided for @notificationsErrorBody.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من اتصالك وحاول مجددًا.'**
  String get notificationsErrorBody;

  /// No description provided for @notificationsOfflineBody.
  ///
  /// In ar, this message translates to:
  /// **'خدمة الإشعارات غير متاحة في وضع API حاليًا.'**
  String get notificationsOfflineBody;

  /// No description provided for @notificationsMutationError.
  ///
  /// In ar, this message translates to:
  /// **'لم يُحفظ تغيير حالة القراءة. حاول مجددًا.'**
  String get notificationsMutationError;

  /// No description provided for @notificationsMoreError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل المزيد.'**
  String get notificationsMoreError;

  /// No description provided for @notificationsUnavailableTarget.
  ///
  /// In ar, this message translates to:
  /// **'لا تتوفر وجهة آمنة لفتح هذا الإشعار.'**
  String get notificationsUnavailableTarget;

  /// No description provided for @notificationsRead.
  ///
  /// In ar, this message translates to:
  /// **'مقروء'**
  String get notificationsRead;

  /// No description provided for @notificationsUnread.
  ///
  /// In ar, this message translates to:
  /// **'غير مقروء'**
  String get notificationsUnread;

  /// No description provided for @notificationsLoading.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل الإشعارات'**
  String get notificationsLoading;

  /// No description provided for @notificationsOpenNotification.
  ///
  /// In ar, this message translates to:
  /// **'فتح الإشعار'**
  String get notificationsOpenNotification;

  /// No description provided for @notificationsFeedTitle.
  ///
  /// In ar, this message translates to:
  /// **'كل جديد في طريقك'**
  String get notificationsFeedTitle;

  /// No description provided for @notificationsFeedSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'رحلاتك وتحديثات تم في مكان واحد'**
  String get notificationsFeedSubtitle;

  /// No description provided for @notificationsAllFilter.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get notificationsAllFilter;

  /// No description provided for @notificationsUnreadFilter.
  ///
  /// In ar, this message translates to:
  /// **'غير المقروءة'**
  String get notificationsUnreadFilter;

  /// No description provided for @notificationsNoUnread.
  ///
  /// In ar, this message translates to:
  /// **'أنت على اطلاع بكل جديد'**
  String get notificationsNoUnread;

  /// No description provided for @notificationsShowAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض كل الإشعارات'**
  String get notificationsShowAll;

  /// No description provided for @notificationsTripsFilter.
  ///
  /// In ar, this message translates to:
  /// **'الرحلات'**
  String get notificationsTripsFilter;

  /// No description provided for @notificationsOffersFilter.
  ///
  /// In ar, this message translates to:
  /// **'العروض'**
  String get notificationsOffersFilter;

  /// No description provided for @notificationsAccountFilter.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get notificationsAccountFilter;

  /// No description provided for @notificationsSystemFilter.
  ///
  /// In ar, this message translates to:
  /// **'النظام'**
  String get notificationsSystemFilter;

  /// No description provided for @notificationsOpenTrip.
  ///
  /// In ar, this message translates to:
  /// **'عرض الرحلة'**
  String get notificationsOpenTrip;

  /// No description provided for @notificationsExploreOffer.
  ///
  /// In ar, this message translates to:
  /// **'استعراض العرض'**
  String get notificationsExploreOffer;

  /// No description provided for @notificationsOpenTrips.
  ///
  /// In ar, this message translates to:
  /// **'سجل الرحلات'**
  String get notificationsOpenTrips;

  /// No description provided for @notificationsExploreServices.
  ///
  /// In ar, this message translates to:
  /// **'استكشف الخدمات'**
  String get notificationsExploreServices;

  /// No description provided for @notificationsMarkRead.
  ///
  /// In ar, this message translates to:
  /// **'تحديد كمقروء'**
  String get notificationsMarkRead;

  /// No description provided for @notificationsNoMatches.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات في هذا التصنيف'**
  String get notificationsNoMatches;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get settingsTitle;

  /// No description provided for @settingsProfileSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة بيانات حسابك'**
  String get settingsProfileSubtitle;

  /// No description provided for @settingsEditName.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الاسم'**
  String get settingsEditName;

  /// No description provided for @settingsName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الظاهر'**
  String get settingsName;

  /// No description provided for @settingsNameHint.
  ///
  /// In ar, this message translates to:
  /// **'من حرفين إلى 60 حرفًا'**
  String get settingsNameHint;

  /// No description provided for @settingsNameValidation.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسمًا من حرفين إلى 60 حرفًا دون رموز تحكم'**
  String get settingsNameValidation;

  /// No description provided for @settingsPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get settingsPhone;

  /// No description provided for @settingsPhoneReadOnly.
  ///
  /// In ar, this message translates to:
  /// **'الرقم مرتبط بالدخول؛ لتغييره استخدم خيار تغيير رقم الهاتف.'**
  String get settingsPhoneReadOnly;

  /// No description provided for @settingsPhoneUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد رقم هاتف لهذه الجلسة'**
  String get settingsPhoneUnavailable;

  /// No description provided for @settingsSaveName.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الاسم'**
  String get settingsSaveName;

  /// No description provided for @settingsPreferencesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsPreferencesTitle;

  /// No description provided for @settingsAccountNotifications.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات الحساب'**
  String get settingsAccountNotifications;

  /// No description provided for @settingsNotificationHint.
  ///
  /// In ar, this message translates to:
  /// **'تفضيل محلي تجريبي للإشعارات داخل التطبيق؛ لا يطلب صلاحية Push'**
  String get settingsNotificationHint;

  /// No description provided for @settingsSavePreferences.
  ///
  /// In ar, this message translates to:
  /// **'حفظ تفضيل الإشعارات'**
  String get settingsSavePreferences;

  /// No description provided for @settingsLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get settingsLanguage;

  /// No description provided for @settingsArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get settingsArabic;

  /// No description provided for @settingsEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get settingsEnglish;

  /// No description provided for @settingsUnsaved.
  ///
  /// In ar, this message translates to:
  /// **'تغييرات غير محفوظة'**
  String get settingsUnsaved;

  /// No description provided for @settingsUnsavedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تغييرات غير محفوظة'**
  String get settingsUnsavedTitle;

  /// No description provided for @settingsUnsavedMessage.
  ///
  /// In ar, this message translates to:
  /// **'إذا غادرت الآن فستفقد التغييرات التي لم تحفظها.'**
  String get settingsUnsavedMessage;

  /// No description provided for @settingsKeepEditing.
  ///
  /// In ar, this message translates to:
  /// **'متابعة التعديل'**
  String get settingsKeepEditing;

  /// No description provided for @settingsDiscard.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل التغييرات'**
  String get settingsDiscard;

  /// No description provided for @settingsInfoTitle.
  ///
  /// In ar, this message translates to:
  /// **'الدعم والمعلومات'**
  String get settingsInfoTitle;

  /// No description provided for @settingsMockNotice.
  ///
  /// In ar, this message translates to:
  /// **'الحساب والتفضيلات هنا محاكاة للتطوير، وليسا متصلين بخادم. حفظ اللغة يعمل فورًا طوال هذه الجلسة فقط.'**
  String get settingsMockNotice;

  /// No description provided for @settingsLogout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تسجيل الخروج من الجلسة الحالية؟'**
  String get settingsLogoutConfirm;

  /// No description provided for @settingsCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get settingsCancel;

  /// No description provided for @settingsLogoutError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تسجيل الخروج. حاول مجددًا.'**
  String get settingsLogoutError;

  /// No description provided for @settingsNotifications.
  ///
  /// In ar, this message translates to:
  /// **'فتح الإشعارات'**
  String get settingsNotifications;

  /// No description provided for @settingsLoading.
  ///
  /// In ar, this message translates to:
  /// **'تحميل الإعدادات'**
  String get settingsLoading;

  /// No description provided for @settingsServiceUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل بيانات الحساب. الخدمة غير متاحة حاليًا.'**
  String get settingsServiceUnavailable;

  /// No description provided for @settingsRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get settingsRetry;

  /// No description provided for @settingsSaveError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حفظ التغييرات. لم يتم تعديل البيانات المحفوظة؛ يمكنك المحاولة مجددًا.'**
  String get settingsSaveError;

  /// No description provided for @settingsSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التغييرات التجريبية'**
  String get settingsSaved;

  /// No description provided for @settingsSaving.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الحفظ'**
  String get settingsSaving;

  /// No description provided for @settingsLoggingOut.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تسجيل الخروج'**
  String get settingsLoggingOut;

  /// No description provided for @settingsHelp.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة والدعم'**
  String get settingsHelp;

  /// No description provided for @settingsTerms.
  ///
  /// In ar, this message translates to:
  /// **'الشروط والأحكام'**
  String get settingsTerms;

  /// No description provided for @settingsPrivacy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get settingsPrivacy;

  /// No description provided for @settingsWelcome.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك في تم'**
  String get settingsWelcome;

  /// No description provided for @settingsAccountSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحساب والعناوين'**
  String get settingsAccountSectionTitle;

  /// No description provided for @settingsDangerSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الحساب'**
  String get settingsDangerSectionTitle;

  /// No description provided for @settingsInternalNotificationHint.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات داخل التطبيق فقط، ولا تشمل تنبيهات الهاتف.'**
  String get settingsInternalNotificationHint;

  /// No description provided for @settingsDevelopmentDisclosureTitle.
  ///
  /// In ar, this message translates to:
  /// **'عن هذه النسخة'**
  String get settingsDevelopmentDisclosureTitle;

  /// No description provided for @settingsCurrentPhoneHint.
  ///
  /// In ar, this message translates to:
  /// **'رقم هذه الجلسة'**
  String get settingsCurrentPhoneHint;

  /// No description provided for @settingsWalletUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد غير متاح حاليًا'**
  String get settingsWalletUnavailable;

  /// No description provided for @settingsProfileEditorTitle.
  ///
  /// In ar, this message translates to:
  /// **'بياناتك الشخصية'**
  String get settingsProfileEditorTitle;

  /// No description provided for @settingsChoosePhoto.
  ///
  /// In ar, this message translates to:
  /// **'اختيار صورة من المعرض'**
  String get settingsChoosePhoto;

  /// No description provided for @settingsPhotoError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر اختيار الصورة. اختر صورة واضحة بحجم أقل من 5 ميغابايت وحاول مجددًا.'**
  String get settingsPhotoError;

  /// No description provided for @settingsProfileLocalNotice.
  ///
  /// In ar, this message translates to:
  /// **'تُحفظ بياناتك تجريبيًا خلال هذه الجلسة فقط، ولا تُرفع الصورة إلى الخادم.'**
  String get settingsProfileLocalNotice;

  /// No description provided for @settingsProfileSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ البيانات'**
  String get settingsProfileSave;

  /// No description provided for @settingsCouponsTitle.
  ///
  /// In ar, this message translates to:
  /// **'أكواد الحسم'**
  String get settingsCouponsTitle;

  /// No description provided for @settingsCouponsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'خصوماتك في مكان واحد'**
  String get settingsCouponsSubtitle;

  /// No description provided for @settingsCouponsAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة كود'**
  String get settingsCouponsAdd;

  /// No description provided for @settingsCouponsDemoNotice.
  ///
  /// In ar, this message translates to:
  /// **'معاينة تجريبية فقط. هذه الأكواد ليست عروضاً حقيقية ولا ترتبط بالخادم.'**
  String get settingsCouponsDemoNotice;

  /// No description provided for @settingsCouponsAvailable.
  ///
  /// In ar, this message translates to:
  /// **'متاح للتجربة'**
  String get settingsCouponsAvailable;

  /// No description provided for @settingsCouponsExpired.
  ///
  /// In ar, this message translates to:
  /// **'منتهي'**
  String get settingsCouponsExpired;

  /// No description provided for @settingsCouponsTrips.
  ///
  /// In ar, this message translates to:
  /// **'الرحلات المتبقية: {remaining}'**
  String settingsCouponsTrips(String remaining);

  /// No description provided for @settingsCouponsExpiry.
  ///
  /// In ar, this message translates to:
  /// **'انتهى في {date}'**
  String settingsCouponsExpiry(String date);

  /// No description provided for @settingsCouponsCopy.
  ///
  /// In ar, this message translates to:
  /// **'نسخ الرمز'**
  String get settingsCouponsCopy;

  /// No description provided for @settingsCouponsCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ رمز الكوبون'**
  String get settingsCouponsCopied;

  /// No description provided for @settingsCouponsSheetTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة كود حسم'**
  String get settingsCouponsSheetTitle;

  /// No description provided for @settingsCouponsSheetDescription.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز الكوبون لإضافته إلى قائمة المعاينة.'**
  String get settingsCouponsSheetDescription;

  /// No description provided for @settingsCouponsCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز الكوبون'**
  String get settingsCouponsCode;

  /// No description provided for @settingsCouponsHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: TAM10'**
  String get settingsCouponsHint;

  /// No description provided for @settingsCouponsConfirm.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get settingsCouponsConfirm;

  /// No description provided for @settingsCouponsInvalid.
  ///
  /// In ar, this message translates to:
  /// **'هذا الكود غير متاح في المعاينة التجريبية.'**
  String get settingsCouponsInvalid;

  /// No description provided for @settingsCouponsDuplicate.
  ///
  /// In ar, this message translates to:
  /// **'لقد أضفت هذا الكود مسبقاً.'**
  String get settingsCouponsDuplicate;

  /// No description provided for @settingsCouponsAdded.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة الكوبون التجريبي'**
  String get settingsCouponsAdded;

  /// No description provided for @settingsCouponsDemoHelp.
  ///
  /// In ar, this message translates to:
  /// **'يمكن استخدام TAM10 في شاشة الحجز التجريبية فقط. الإضافة هنا لا تطبقه على طلباتك تلقائياً.'**
  String get settingsCouponsDemoHelp;

  /// No description provided for @addressesTitle.
  ///
  /// In ar, this message translates to:
  /// **'عناويني'**
  String get addressesTitle;

  /// No description provided for @addressesDescription.
  ///
  /// In ar, this message translates to:
  /// **'احفظ أماكنك للوصول إليها أسرع'**
  String get addressesDescription;

  /// No description provided for @addressesAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة موقع'**
  String get addressesAdd;

  /// No description provided for @addressesEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الموقع'**
  String get addressesEdit;

  /// No description provided for @addressesDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف الموقع'**
  String get addressesDelete;

  /// No description provided for @addressesDeleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف هذا الموقع؟'**
  String get addressesDeleteTitle;

  /// No description provided for @addressesDeleteBody.
  ///
  /// In ar, this message translates to:
  /// **'سيُحذف من عناوينك المحفوظة. لن تتغير الرحلات السابقة.'**
  String get addressesDeleteBody;

  /// No description provided for @addressesCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get addressesCancel;

  /// No description provided for @addressesConfirmDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get addressesConfirmDelete;

  /// No description provided for @addressesLoading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحميل العناوين'**
  String get addressesLoading;

  /// No description provided for @addressesSaving.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ حفظ الموقع'**
  String get addressesSaving;

  /// No description provided for @addressesSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الموقع'**
  String get addressesSave;

  /// No description provided for @addressesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عناوين محفوظة بعد'**
  String get addressesEmpty;

  /// No description provided for @addressesEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'أضف مكانًا لتختاره بسهولة عند طلب رحلة.'**
  String get addressesEmptyBody;

  /// No description provided for @addressesError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إكمال العملية. حاول مجددًا.'**
  String get addressesError;

  /// No description provided for @addressesUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'خدمة العناوين غير متاحة في وضع API حاليًا.'**
  String get addressesUnavailable;

  /// No description provided for @addressesNotFound.
  ///
  /// In ar, this message translates to:
  /// **'هذا العنوان لم يعد موجودًا.'**
  String get addressesNotFound;

  /// No description provided for @addressesLimit.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك حفظ {max} عنوانًا كحد أقصى.'**
  String addressesLimit(int max);

  /// No description provided for @addressesConflict.
  ///
  /// In ar, this message translates to:
  /// **'تعارضت محاولة الحفظ. أعد المحاولة.'**
  String get addressesConflict;

  /// No description provided for @addressesRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get addressesRetry;

  /// No description provided for @addressesRefresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث العناوين'**
  String get addressesRefresh;

  /// No description provided for @addressesName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المكان'**
  String get addressesName;

  /// No description provided for @addressesNameHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: المنزل أو العمل'**
  String get addressesNameHint;

  /// No description provided for @addressesNameError.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسمًا من 1 إلى {max} محرفًا.'**
  String addressesNameError(int max);

  /// No description provided for @addressesLocation.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get addressesLocation;

  /// No description provided for @addressesChooseLocation.
  ///
  /// In ar, this message translates to:
  /// **'اختر موقع المكان'**
  String get addressesChooseLocation;

  /// No description provided for @addressesLocationError.
  ///
  /// In ar, this message translates to:
  /// **'اختر موقعًا قبل الحفظ.'**
  String get addressesLocationError;

  /// No description provided for @addressesSearch.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن مكان'**
  String get addressesSearch;

  /// No description provided for @addressesNoPlaces.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أماكن مطابقة. جرّب بحثًا آخر.'**
  String get addressesNoPlaces;

  /// No description provided for @addressesChooseIcon.
  ///
  /// In ar, this message translates to:
  /// **'اختر أيقونة'**
  String get addressesChooseIcon;

  /// No description provided for @addressesIconHome.
  ///
  /// In ar, this message translates to:
  /// **'منزل'**
  String get addressesIconHome;

  /// No description provided for @addressesIconWork.
  ///
  /// In ar, this message translates to:
  /// **'عمل'**
  String get addressesIconWork;

  /// No description provided for @addressesIconStudy.
  ///
  /// In ar, this message translates to:
  /// **'دراسة'**
  String get addressesIconStudy;

  /// No description provided for @addressesIconGym.
  ///
  /// In ar, this message translates to:
  /// **'نادي'**
  String get addressesIconGym;

  /// No description provided for @addressesIconOther.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get addressesIconOther;

  /// No description provided for @addressesDiscardTitle.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل التعديلات؟'**
  String get addressesDiscardTitle;

  /// No description provided for @addressesDiscardBody.
  ///
  /// In ar, this message translates to:
  /// **'لم تُحفظ تعديلاتك على هذا المكان بعد.'**
  String get addressesDiscardBody;

  /// No description provided for @addressesDiscard.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل'**
  String get addressesDiscard;

  /// No description provided for @addressesKeepEditing.
  ///
  /// In ar, this message translates to:
  /// **'متابعة التعديل'**
  String get addressesKeepEditing;

  /// No description provided for @addressesRetryPending.
  ///
  /// In ar, this message translates to:
  /// **'لم يصل تأكيد الحفظ. أعد المحاولة للتحقق من العملية نفسها دون إضافة موقع مكرر.'**
  String get addressesRetryPending;

  /// No description provided for @addressesManage.
  ///
  /// In ar, this message translates to:
  /// **'إدارة العناوين'**
  String get addressesManage;

  /// No description provided for @addressesSavedTab.
  ///
  /// In ar, this message translates to:
  /// **'العناوين المحفوظة'**
  String get addressesSavedTab;

  /// No description provided for @addressesSearchTab.
  ///
  /// In ar, this message translates to:
  /// **'البحث'**
  String get addressesSearchTab;

  /// No description provided for @activeTripTitle.
  ///
  /// In ar, this message translates to:
  /// **'متابعة الرحلة'**
  String get activeTripTitle;

  /// No description provided for @activeTripHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get activeTripHome;

  /// No description provided for @activeTripFollow.
  ///
  /// In ar, this message translates to:
  /// **'متابعة رحلتي'**
  String get activeTripFollow;

  /// No description provided for @activeTripLoading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحديث الرحلة…'**
  String get activeTripLoading;

  /// No description provided for @activeTripRefresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الحالة'**
  String get activeTripRefresh;

  /// No description provided for @activeTripEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رحلة متاحة للمتابعة الآن.'**
  String get activeTripEmpty;

  /// No description provided for @activeTripNewBooking.
  ///
  /// In ar, this message translates to:
  /// **'اطلب رحلة'**
  String get activeTripNewBooking;

  /// No description provided for @activeTripScheduledHint.
  ///
  /// In ar, this message translates to:
  /// **'رحلتك محفوظة للموعد المحدد. يبدأ البحث عند الموعد.'**
  String get activeTripScheduledHint;

  /// No description provided for @activeTripSearchingHint.
  ///
  /// In ar, this message translates to:
  /// **'نبحث عن سائق مناسب لرحلتك.'**
  String get activeTripSearchingHint;

  /// No description provided for @activeTripAssignedHint.
  ///
  /// In ar, this message translates to:
  /// **'تم قبول الرحلة. يتجهز السائق للانطلاق إليك.'**
  String get activeTripAssignedHint;

  /// No description provided for @activeTripEnRouteHint.
  ///
  /// In ar, this message translates to:
  /// **'السائق في الطريق إلى نقطة الانطلاق.'**
  String get activeTripEnRouteHint;

  /// No description provided for @activeTripArrivedHint.
  ///
  /// In ar, this message translates to:
  /// **'وصل السائق وينتظرك عند نقطة الانطلاق.'**
  String get activeTripArrivedHint;

  /// No description provided for @activeTripJourneyHint.
  ///
  /// In ar, this message translates to:
  /// **'أنت في الطريق إلى وجهتك.'**
  String get activeTripJourneyHint;

  /// No description provided for @activeTripCompletedHint.
  ///
  /// In ar, this message translates to:
  /// **'وصلت إلى وجهتك. اكتملت الرحلة.'**
  String get activeTripCompletedHint;

  /// No description provided for @activeTripCancelledHint.
  ///
  /// In ar, this message translates to:
  /// **'أُلغيت هذه الرحلة.'**
  String get activeTripCancelledHint;

  /// No description provided for @activeTripNoDriverHint.
  ///
  /// In ar, this message translates to:
  /// **'لم نجد سائقًا لهذه الرحلة. يمكنك طلب رحلة جديدة بسعر محدث.'**
  String get activeTripNoDriverHint;

  /// No description provided for @activeTripPlate.
  ///
  /// In ar, this message translates to:
  /// **'رقم السيارة: {plate}'**
  String activeTripPlate(String plate);

  /// No description provided for @activeTripRating.
  ///
  /// In ar, this message translates to:
  /// **'التقييم: {rating} من 5'**
  String activeTripRating(String rating);

  /// No description provided for @activeTripDriverDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض بيانات السائق والسيارة'**
  String get activeTripDriverDetails;

  /// No description provided for @activeTripContactPending.
  ///
  /// In ar, this message translates to:
  /// **'المكالمات غير مربوطة حاليًا.'**
  String get activeTripContactPending;

  /// No description provided for @activeTripClose.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get activeTripClose;

  /// No description provided for @activeTripRouteSemantics.
  ///
  /// In ar, this message translates to:
  /// **'المسار من {pickup} إلى {destination}'**
  String activeTripRouteSemantics(String pickup, String destination);

  /// No description provided for @activeTripPositionStale.
  ///
  /// In ar, this message translates to:
  /// **'موقع السائق غير محدث؛ لا تعتمد على موضعه أو وقت الوصول السابق.'**
  String get activeTripPositionStale;

  /// No description provided for @activeTripSchematic.
  ///
  /// In ar, this message translates to:
  /// **'مسار توضيحي؛ ليس خريطة ملاحة.'**
  String get activeTripSchematic;

  /// No description provided for @activeTripCancelTitle.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الرحلة'**
  String get activeTripCancelTitle;

  /// No description provided for @activeTripCancelPrompt.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إلغاء هذه الرحلة؟'**
  String get activeTripCancelPrompt;

  /// No description provided for @activeTripKeep.
  ///
  /// In ar, this message translates to:
  /// **'متابعة الرحلة'**
  String get activeTripKeep;

  /// No description provided for @activeTripConfirmCancel.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الإلغاء'**
  String get activeTripConfirmCancel;

  /// No description provided for @activeTripCancelUncertain.
  ///
  /// In ar, this message translates to:
  /// **'لم نتأكد من نتيجة الإلغاء. أعد المحاولة للرحلة نفسها قبل طلب بديل.'**
  String get activeTripCancelUncertain;

  /// No description provided for @activeTripRetryCancel.
  ///
  /// In ar, this message translates to:
  /// **'إعادة محاولة الإلغاء'**
  String get activeTripRetryCancel;

  /// No description provided for @activeTripCancelling.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الإلغاء…'**
  String get activeTripCancelling;

  /// No description provided for @activeTripRebook.
  ///
  /// In ar, this message translates to:
  /// **'طلب رحلة جديدة'**
  String get activeTripRebook;

  /// No description provided for @activeTripDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الطلب'**
  String get activeTripDetails;

  /// No description provided for @activeTripCannotCancel.
  ///
  /// In ar, this message translates to:
  /// **'بدأت الرحلة أو تغيرت حالتها؛ لا يمكن إلغاؤها الآن.'**
  String get activeTripCannotCancel;

  /// No description provided for @activeTripNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم تعد هذه الرحلة متاحة.'**
  String get activeTripNotFound;

  /// No description provided for @activeTripInvalidResponse.
  ///
  /// In ar, this message translates to:
  /// **'تعذر التحقق من تحديث الرحلة. حاول التحديث مجددًا.'**
  String get activeTripInvalidResponse;

  /// No description provided for @activeTripAccessDenied.
  ///
  /// In ar, this message translates to:
  /// **'تحتاج هذه العملية إلى جلسة مصرح بها.'**
  String get activeTripAccessDenied;

  /// No description provided for @activeTripUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'خدمة متابعة الرحلة غير متاحة حاليًا.'**
  String get activeTripUnavailable;

  /// No description provided for @activeTripConnectionLost.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحديث الرحلة. تحقق من الاتصال وأعد المحاولة.'**
  String get activeTripConnectionLost;

  /// No description provided for @activeTripCached.
  ///
  /// In ar, this message translates to:
  /// **'هذه آخر حالة وصلت؛ قد تكون الرحلة تغيرت أثناء الانقطاع.'**
  String get activeTripCached;

  /// No description provided for @activeTripEta.
  ///
  /// In ar, this message translates to:
  /// **'الوصول المتوقع خلال {minutes} دقيقة'**
  String activeTripEta(int minutes);

  /// No description provided for @activeTripSimulationNotice.
  ///
  /// In ar, this message translates to:
  /// **'تعمل الرحلة حاليًا بمحاكاة محلية حتى ربط الخدمة.'**
  String get activeTripSimulationNotice;

  /// No description provided for @activeTripChat.
  ///
  /// In ar, this message translates to:
  /// **'محادثة السائق'**
  String get activeTripChat;

  /// No description provided for @activeTripCompletion.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الرحلة وتقييمها'**
  String get activeTripCompletion;

  /// No description provided for @activeTripSupport.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة بخصوص الرحلة'**
  String get activeTripSupport;

  /// No description provided for @chatTitle.
  ///
  /// In ar, this message translates to:
  /// **'السائق'**
  String get chatTitle;

  /// No description provided for @chatRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get chatRetry;

  /// No description provided for @chatMessageHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رسالة…'**
  String get chatMessageHint;

  /// No description provided for @chatSend.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get chatSend;

  /// No description provided for @chatRefresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث المحادثة'**
  String get chatRefresh;

  /// No description provided for @chatLoading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحميل المحادثة'**
  String get chatLoading;

  /// No description provided for @chatEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رسائل بعد'**
  String get chatEmpty;

  /// No description provided for @chatReadOnly.
  ///
  /// In ar, this message translates to:
  /// **'انتهت الرحلة. المحادثة للقراءة فقط.'**
  String get chatReadOnly;

  /// No description provided for @chatLoadOlder.
  ///
  /// In ar, this message translates to:
  /// **'تحميل رسائل أقدم'**
  String get chatLoadOlder;

  /// No description provided for @chatNewest.
  ///
  /// In ar, this message translates to:
  /// **'أحدث الرسائل'**
  String get chatNewest;

  /// No description provided for @chatSent.
  ///
  /// In ar, this message translates to:
  /// **'أُرسلت'**
  String get chatSent;

  /// No description provided for @chatDelivered.
  ///
  /// In ar, this message translates to:
  /// **'تم التسليم'**
  String get chatDelivered;

  /// No description provided for @chatRead.
  ///
  /// In ar, this message translates to:
  /// **'مقروءة'**
  String get chatRead;

  /// No description provided for @chatSending.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الإرسال…'**
  String get chatSending;

  /// No description provided for @chatFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر الإرسال'**
  String get chatFailed;

  /// No description provided for @chatUncertain.
  ///
  /// In ar, this message translates to:
  /// **'لم يتأكد الإرسال — حدّث أو أعد المحاولة'**
  String get chatUncertain;

  /// No description provided for @chatValidation.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رسالة من ١ إلى ١٠٠٠ حرف.'**
  String get chatValidation;

  /// No description provided for @chatUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'المحادثة غير متاحة لهذا السائق أو هذه الرحلة.'**
  String get chatUnavailable;

  /// No description provided for @chatSessionEnded.
  ///
  /// In ar, this message translates to:
  /// **'انتهت الجلسة. ارجع إلى الرئيسية.'**
  String get chatSessionEnded;

  /// No description provided for @chatConnectionError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر الاتصال. آخر الرسائل محفوظة؛ حدّث للمحاولة مجددًا.'**
  String get chatConnectionError;

  /// No description provided for @chatCharacterCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} / {max} حرف'**
  String chatCharacterCount(int count, int max);

  /// No description provided for @chatSimulation.
  ///
  /// In ar, this message translates to:
  /// **'محاكاة تطوير'**
  String get chatSimulation;

  /// No description provided for @completionTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الرحلة والتقييم'**
  String get completionTitle;

  /// No description provided for @completionLoading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحميل ملخص الرحلة'**
  String get completionLoading;

  /// No description provided for @completionSessionEnded.
  ///
  /// In ar, this message translates to:
  /// **'انتهت الجلسة. عد إلى الرئيسية للمتابعة.'**
  String get completionSessionEnded;

  /// No description provided for @completionThankYou.
  ///
  /// In ar, this message translates to:
  /// **'شكرًا لرحلتك مع تم'**
  String get completionThankYou;

  /// No description provided for @completionTripId.
  ///
  /// In ar, this message translates to:
  /// **'رقم الطلب: {id}'**
  String completionTripId(String id);

  /// No description provided for @completionRecordedFare.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ الطلب المسجل'**
  String get completionRecordedFare;

  /// No description provided for @completionFareNote.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المسجل عند الطلب، وليس تأكيدًا للدفع أو إيصالًا.'**
  String get completionFareNote;

  /// No description provided for @completionDriver.
  ///
  /// In ar, this message translates to:
  /// **'السائق: {name}'**
  String completionDriver(String name);

  /// No description provided for @completionRateTrip.
  ///
  /// In ar, this message translates to:
  /// **'كيف كانت تجربة رحلتك؟'**
  String get completionRateTrip;

  /// No description provided for @completionStars.
  ///
  /// In ar, this message translates to:
  /// **'{count} من ٥ نجوم'**
  String completionStars(int count);

  /// No description provided for @completionComment.
  ///
  /// In ar, this message translates to:
  /// **'تعليق اختياري'**
  String get completionComment;

  /// No description provided for @completionCommentLimit.
  ///
  /// In ar, this message translates to:
  /// **'حتى {count} حرف بعد إزالة الفراغات الطرفية.'**
  String completionCommentLimit(int count);

  /// No description provided for @completionSubmit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال التقييم'**
  String get completionSubmit;

  /// No description provided for @completionSubmitting.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ إرسال التقييم'**
  String get completionSubmitting;

  /// No description provided for @completionSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ تقييمك، شكرًا لك'**
  String get completionSaved;

  /// No description provided for @completionImmutable.
  ///
  /// In ar, this message translates to:
  /// **'يُسجل تقييم واحد لكل رحلة ولا يمكن تعديله.'**
  String get completionImmutable;

  /// No description provided for @completionUncertain.
  ///
  /// In ar, this message translates to:
  /// **'لم نتمكن من تأكيد الحفظ. أبقينا تقييمك كما هو؛ أعد المحاولة للتحقق دون تكراره.'**
  String get completionUncertain;

  /// No description provided for @completionRetry.
  ///
  /// In ar, this message translates to:
  /// **'تحقق وأعد المحاولة'**
  String get completionRetry;

  /// No description provided for @completionSupport.
  ///
  /// In ar, this message translates to:
  /// **'التواصل مع دعم هذه الرحلة'**
  String get completionSupport;

  /// No description provided for @completionHome.
  ///
  /// In ar, this message translates to:
  /// **'العودة إلى الرئيسية'**
  String get completionHome;

  /// No description provided for @completionValidation.
  ///
  /// In ar, this message translates to:
  /// **'اختر من نجمة إلى خمس نجوم، والتزم بالحد المسموح للتعليق.'**
  String get completionValidation;

  /// No description provided for @completionNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم نعثر على هذه الرحلة.'**
  String get completionNotFound;

  /// No description provided for @completionNotCompleted.
  ///
  /// In ar, this message translates to:
  /// **'يتاح الملخص والتقييم بعد اكتمال الرحلة فقط.'**
  String get completionNotCompleted;

  /// No description provided for @completionUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'ربط خدمة التقييم غير متاح حاليًا.'**
  String get completionUnavailable;

  /// No description provided for @completionAlreadyRated.
  ///
  /// In ar, this message translates to:
  /// **'سبق تقييم هذه الرحلة. جارٍ التحقق من التقييم المحفوظ.'**
  String get completionAlreadyRated;

  /// No description provided for @completionInvalidResponse.
  ///
  /// In ar, this message translates to:
  /// **'تعذر التحقق من نتيجة العملية. أعد المحاولة للتحقق أو تواصل مع الدعم.'**
  String get completionInvalidResponse;

  /// No description provided for @completionOffline.
  ///
  /// In ar, this message translates to:
  /// **'تعذر الاتصال. تحقق من الشبكة وأعد المحاولة.'**
  String get completionOffline;

  /// No description provided for @completionSimulationNotice.
  ///
  /// In ar, this message translates to:
  /// **'التقييمات في هذا الإصدار محفوظة محليًا للتجربة حتى ربط الخدمة.'**
  String get completionSimulationNotice;

  /// No description provided for @completionRateHint.
  ///
  /// In ar, this message translates to:
  /// **'ساعدنا على تحسين الخدمة'**
  String get completionRateHint;

  /// No description provided for @completionQuickFeedbackHint.
  ///
  /// In ar, this message translates to:
  /// **'ما الذي أعجبك في الرحلة؟'**
  String get completionQuickFeedbackHint;

  /// No description provided for @completionTagDriverRespect.
  ///
  /// In ar, this message translates to:
  /// **'سائق محترم'**
  String get completionTagDriverRespect;

  /// No description provided for @completionTagCleanCar.
  ///
  /// In ar, this message translates to:
  /// **'مركبة نظيفة'**
  String get completionTagCleanCar;

  /// No description provided for @completionTagComfort.
  ///
  /// In ar, this message translates to:
  /// **'رحلة مريحة'**
  String get completionTagComfort;

  /// No description provided for @completionTagArrivalDelay.
  ///
  /// In ar, this message translates to:
  /// **'تأخر الوصول'**
  String get completionTagArrivalDelay;

  /// No description provided for @completionTagCarIssue.
  ///
  /// In ar, this message translates to:
  /// **'مشكلة بالمركبة'**
  String get completionTagCarIssue;

  /// No description provided for @completionTagServiceIssue.
  ///
  /// In ar, this message translates to:
  /// **'تجربة غير مريحة'**
  String get completionTagServiceIssue;

  /// No description provided for @completionQuickFeedbackCritical.
  ///
  /// In ar, this message translates to:
  /// **'ما الذي يمكن تحسينه؟'**
  String get completionQuickFeedbackCritical;

  /// No description provided for @completionFeedbackOptional.
  ///
  /// In ar, this message translates to:
  /// **'اختياري'**
  String get completionFeedbackOptional;

  /// No description provided for @supportTitle.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة والدعم'**
  String get supportTitle;

  /// No description provided for @supportIntro.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ طلب دعم عام أو اختر رحلة لإرسال بلاغ عنها.'**
  String get supportIntro;

  /// No description provided for @supportNewTicket.
  ///
  /// In ar, this message translates to:
  /// **'طلب دعم جديد'**
  String get supportNewTicket;

  /// No description provided for @supportChooseTrip.
  ///
  /// In ar, this message translates to:
  /// **'اختيار رحلة للإبلاغ عنها'**
  String get supportChooseTrip;

  /// No description provided for @supportMyTickets.
  ///
  /// In ar, this message translates to:
  /// **'طلبات الدعم'**
  String get supportMyTickets;

  /// No description provided for @supportEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات دعم بعد.'**
  String get supportEmpty;

  /// No description provided for @supportLoading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل'**
  String get supportLoading;

  /// No description provided for @supportLoadMore.
  ///
  /// In ar, this message translates to:
  /// **'عرض المزيد'**
  String get supportLoadMore;

  /// No description provided for @supportCategory.
  ///
  /// In ar, this message translates to:
  /// **'الفئة'**
  String get supportCategory;

  /// No description provided for @supportBody.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الطلب'**
  String get supportBody;

  /// No description provided for @supportBodyHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب من 10 إلى 2000 حرف دون المسافات المحيطة.'**
  String get supportBodyHint;

  /// No description provided for @supportSubmit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الطلب'**
  String get supportSubmit;

  /// No description provided for @supportSending.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الإرسال'**
  String get supportSending;

  /// No description provided for @supportCreated.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء طلب الدعم'**
  String get supportCreated;

  /// No description provided for @supportRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get supportRetry;

  /// No description provided for @supportUncertain.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تأكيد الإرسال. احتفظنا بالتفاصيل كما هي؛ أعد المحاولة للتحقق بنفس معرّف الطلب دون تكراره.'**
  String get supportUncertain;

  /// No description provided for @supportBodyValidation.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يتكون النص من 10 إلى 2000 حرف بعد حذف المسافات المحيطة.'**
  String get supportBodyValidation;

  /// No description provided for @supportInvalidCategory.
  ///
  /// In ar, this message translates to:
  /// **'اختر فئة صالحة لسياق الطلب.'**
  String get supportInvalidCategory;

  /// No description provided for @supportNotFound.
  ///
  /// In ar, this message translates to:
  /// **'الطلب أو الرحلة غير متاحين لهذا الحساب.'**
  String get supportNotFound;

  /// No description provided for @supportSessionEnded.
  ///
  /// In ar, this message translates to:
  /// **'انتهت الجلسة. أُزيلت بيانات الدعم من هذه الصفحة.'**
  String get supportSessionEnded;

  /// No description provided for @supportConflict.
  ///
  /// In ar, this message translates to:
  /// **'معرّف الطلب مستخدم لتفاصيل مختلفة. تعذر تأكيد هذا الطلب.'**
  String get supportConflict;

  /// No description provided for @supportOffline.
  ///
  /// In ar, this message translates to:
  /// **'تعذر الاتصال. حاول مجددًا عند توفر الشبكة.'**
  String get supportOffline;

  /// No description provided for @supportUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'الدعم غير متاح حاليًا. حاول لاحقًا.'**
  String get supportUnavailable;

  /// No description provided for @supportStatusOpen.
  ///
  /// In ar, this message translates to:
  /// **'مفتوح'**
  String get supportStatusOpen;

  /// No description provided for @supportStatusInProgress.
  ///
  /// In ar, this message translates to:
  /// **'قيد المعالجة'**
  String get supportStatusInProgress;

  /// No description provided for @supportStatusResolved.
  ///
  /// In ar, this message translates to:
  /// **'تم الحل'**
  String get supportStatusResolved;

  /// No description provided for @supportTicketDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل طلب الدعم'**
  String get supportTicketDetails;

  /// No description provided for @supportTerms.
  ///
  /// In ar, this message translates to:
  /// **'الشروط والأحكام'**
  String get supportTerms;

  /// No description provided for @supportPrivacy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get supportPrivacy;

  /// No description provided for @supportLegalUnpublished.
  ///
  /// In ar, this message translates to:
  /// **'المحتوى المعتمد غير منشور بعد. سيظهر هنا بعد توفيره واعتماده.'**
  String get supportLegalUnpublished;

  /// No description provided for @supportTicketReference.
  ///
  /// In ar, this message translates to:
  /// **'طلب الدعم: {id}'**
  String supportTicketReference(String id);

  /// No description provided for @supportTripReference.
  ///
  /// In ar, this message translates to:
  /// **'الرحلة: {id}'**
  String supportTripReference(String id);

  /// No description provided for @supportLegalVersion.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار {version} · نُشر {date}'**
  String supportLegalVersion(String version, String date);

  /// No description provided for @supportSimulationNotice.
  ///
  /// In ar, this message translates to:
  /// **'عمليات الدعم في هذا الإصدار محاكاة للتجربة، ولا تُرسل إلى فريق دعم فعلي.'**
  String get supportSimulationNotice;

  /// No description provided for @supportEditorHeadline.
  ///
  /// In ar, this message translates to:
  /// **'كيف نقدر نساعدك؟'**
  String get supportEditorHeadline;

  /// No description provided for @supportEditorSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'صف لنا استفسارك أو المشكلة التي تواجهها.'**
  String get supportEditorSubtitle;

  /// No description provided for @supportEditorPlaceholder.
  ///
  /// In ar, this message translates to:
  /// **'اكتب التفاصيل التي تساعدنا على فهم طلبك...'**
  String get supportEditorPlaceholder;

  /// No description provided for @supportEditorCategory.
  ///
  /// In ar, this message translates to:
  /// **'نوع الاستفسار'**
  String get supportEditorCategory;

  /// No description provided for @supportEditorTripContext.
  ///
  /// In ar, this message translates to:
  /// **'بخصوص رحلة سابقة'**
  String get supportEditorTripContext;

  /// No description provided for @accountManagementChangePhone.
  ///
  /// In ar, this message translates to:
  /// **'تغيير رقم الهاتف'**
  String get accountManagementChangePhone;

  /// No description provided for @accountManagementDeleteAccount.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get accountManagementDeleteAccount;

  /// No description provided for @accountManagementSimulation.
  ///
  /// In ar, this message translates to:
  /// **'تجربة محلية؛ لا يتم تعديل أو حذف حساب على الخادم.'**
  String get accountManagementSimulation;

  /// No description provided for @accountManagementPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف الجديد'**
  String get accountManagementPhone;

  /// No description provided for @accountManagementRequestCode.
  ///
  /// In ar, this message translates to:
  /// **'إرسال رمز التحقق'**
  String get accountManagementRequestCode;

  /// No description provided for @accountManagementCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز التحقق'**
  String get accountManagementCode;

  /// No description provided for @accountManagementOtpHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز المرسل إلى الرقم المعروض. تحقق هذه العملية مستقل عن تسجيل الدخول.'**
  String get accountManagementOtpHint;

  /// No description provided for @accountManagementConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد العملية'**
  String get accountManagementConfirm;

  /// No description provided for @accountManagementResend.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الرمز'**
  String get accountManagementResend;

  /// No description provided for @accountManagementRestart.
  ///
  /// In ar, this message translates to:
  /// **'بدء تحقق جديد'**
  String get accountManagementRestart;

  /// No description provided for @accountManagementDeleteNotice.
  ///
  /// In ar, this message translates to:
  /// **'بعد تأكيد الحذف تُنهى الجلسة. لا يمكن التراجع عن الحذف من التطبيق.'**
  String get accountManagementDeleteNotice;

  /// No description provided for @accountManagementDeleteConsent.
  ///
  /// In ar, this message translates to:
  /// **'أؤكد أنني أريد حذف حسابي'**
  String get accountManagementDeleteConsent;

  /// No description provided for @accountManagementChanged.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير الرقم. سجل الدخول بالرقم الجديد.'**
  String get accountManagementChanged;

  /// No description provided for @accountManagementDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم تأكيد حذف الحساب.'**
  String get accountManagementDeleted;

  /// No description provided for @accountManagementSignOut.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء الجلسة والمتابعة'**
  String get accountManagementSignOut;

  /// No description provided for @accountManagementBusy.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تنفيذ العملية'**
  String get accountManagementBusy;

  /// No description provided for @accountManagementRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get accountManagementRetry;

  /// No description provided for @accountManagementUncertain.
  ///
  /// In ar, this message translates to:
  /// **'لم يصل تأكيد العملية. التفاصيل مقفلة؛ أعد المحاولة للتحقق دون إنشاء عملية أخرى.'**
  String get accountManagementUncertain;

  /// No description provided for @accountManagementActiveTrip.
  ///
  /// In ar, this message translates to:
  /// **'أنهِ الرحلات الجارية أو ألغِ الرحلات المجدولة قبل إدارة رقم الحساب أو حذفه.'**
  String get accountManagementActiveTrip;

  /// No description provided for @accountManagementRequired.
  ///
  /// In ar, this message translates to:
  /// **'تحتاج إلى دخول برقم هاتف لإدارة الحساب.'**
  String get accountManagementRequired;

  /// No description provided for @accountManagementInvalidPhone.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتف سوري صالحًا ومختلفًا عن الرقم الحالي.'**
  String get accountManagementInvalidPhone;

  /// No description provided for @accountManagementPhoneInUse.
  ///
  /// In ar, this message translates to:
  /// **'هذا الرقم مرتبط بحساب آخر. لا يمكن دمج الحسابات من هنا.'**
  String get accountManagementPhoneInUse;

  /// No description provided for @accountManagementInvalidCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز التحقق غير صحيح.'**
  String get accountManagementInvalidCode;

  /// No description provided for @accountManagementExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهى التحقق أو استُنفدت المحاولات. ابدأ تحققًا جديدًا عند السماح بذلك.'**
  String get accountManagementExpired;

  /// No description provided for @accountManagementCooldown.
  ///
  /// In ar, this message translates to:
  /// **'انتظر قبل إعادة إرسال الرمز أو المحاولة مجددًا.'**
  String get accountManagementCooldown;

  /// No description provided for @accountManagementUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إكمال العملية. أعد المحاولة عند توفر الخدمة.'**
  String get accountManagementUnavailable;

  /// No description provided for @accountManagementInvalidResponse.
  ///
  /// In ar, this message translates to:
  /// **'تعذر التحقق من استجابة الخدمة. أعد المحاولة لنفس العملية.'**
  String get accountManagementInvalidResponse;

  /// No description provided for @accountManagementSessionEnded.
  ///
  /// In ar, this message translates to:
  /// **'انتهت الجلسة. لم يعد هذا النموذج متاحًا.'**
  String get accountManagementSessionEnded;

  /// No description provided for @accountManagementChangedNotice.
  ///
  /// In ar, this message translates to:
  /// **'بعد التحقق ستنتهي الجلسة، ثم تدخل باستخدام رقمك الجديد.'**
  String get accountManagementChangedNotice;

  /// No description provided for @accountManagementValidation.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من البيانات المدخلة ثم أعد المحاولة.'**
  String get accountManagementValidation;

  /// No description provided for @driverContactTitle.
  ///
  /// In ar, this message translates to:
  /// **'الاتصال بالسائق'**
  String get driverContactTitle;

  /// No description provided for @driverContactCall.
  ///
  /// In ar, this message translates to:
  /// **'فتح الاتصال'**
  String get driverContactCall;

  /// No description provided for @driverContactHint.
  ///
  /// In ar, this message translates to:
  /// **'نطلب وسيلة الاتصال المتاحة لهذه الرحلة، ثم نفتح تطبيق الهاتف. فتح التطبيق لا يؤكد إجراء المكالمة.'**
  String get driverContactHint;

  /// No description provided for @driverContactSimulation.
  ///
  /// In ar, this message translates to:
  /// **'تمت محاكاة فتح الاتصال؛ لن يتم الاتصال برقم تجريبي.'**
  String get driverContactSimulation;

  /// No description provided for @driverContactOpened.
  ///
  /// In ar, this message translates to:
  /// **'تم تسليم الرقم إلى تطبيق الهاتف.'**
  String get driverContactOpened;

  /// No description provided for @driverContactBusy.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تجهيز الاتصال'**
  String get driverContactBusy;

  /// No description provided for @driverContactUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'الاتصال غير متاح لهذه الرحلة حاليًا.'**
  String get driverContactUnavailable;

  /// No description provided for @driverContactChanged.
  ///
  /// In ar, this message translates to:
  /// **'تغير السائق المعيّن. عد إلى متابعة الرحلة وحدّث بياناتها.'**
  String get driverContactChanged;

  /// No description provided for @driverContactDialerUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'تعذر فتح تطبيق الهاتف على هذا الجهاز.'**
  String get driverContactDialerUnavailable;

  /// No description provided for @driverContactOffline.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تجهيز الاتصال. تحقق من الشبكة وأعد المحاولة.'**
  String get driverContactOffline;

  /// No description provided for @driverContactSessionEnded.
  ///
  /// In ar, this message translates to:
  /// **'انتهت الجلسة ولم يُفتح اتصال جديد.'**
  String get driverContactSessionEnded;

  /// No description provided for @mapsNotConfigured.
  ///
  /// In ar, this message translates to:
  /// **'لم تُهيأ خدمة خريطة تم بعد.'**
  String get mapsNotConfigured;

  /// No description provided for @mapsTilesFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل الخريطة. تحقق من الاتصال وحاول مجددًا.'**
  String get mapsTilesFailed;

  /// No description provided for @mapsRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get mapsRetry;

  /// No description provided for @mapsAttribution.
  ///
  /// In ar, this message translates to:
  /// **'OpenStreetMap'**
  String get mapsAttribution;

  /// No description provided for @mapsOrigin.
  ///
  /// In ar, this message translates to:
  /// **'نقطة الانطلاق'**
  String get mapsOrigin;

  /// No description provided for @mapsDestination.
  ///
  /// In ar, this message translates to:
  /// **'الوجهة'**
  String get mapsDestination;

  /// No description provided for @mapsDriver.
  ///
  /// In ar, this message translates to:
  /// **'موقع السائق'**
  String get mapsDriver;

  /// No description provided for @mapsZoomIn.
  ///
  /// In ar, this message translates to:
  /// **'تكبير الخريطة'**
  String get mapsZoomIn;

  /// No description provided for @mapsZoomOut.
  ///
  /// In ar, this message translates to:
  /// **'تصغير الخريطة'**
  String get mapsZoomOut;

  /// No description provided for @mapsPickLocation.
  ///
  /// In ar, this message translates to:
  /// **'اختيار موقع على الخريطة'**
  String get mapsPickLocation;

  /// No description provided for @mapsUseMyLocation.
  ///
  /// In ar, this message translates to:
  /// **'استخدام موقعي الحالي'**
  String get mapsUseMyLocation;

  /// No description provided for @mapsLocationDisabled.
  ///
  /// In ar, this message translates to:
  /// **'خدمة الموقع مغلقة. فعّلها من إعدادات الجهاز أو اختر نقطة يدويًا.'**
  String get mapsLocationDisabled;

  /// No description provided for @mapsPermissionDenied.
  ///
  /// In ar, this message translates to:
  /// **'لم يُسمح بالوصول للموقع. يمكنك اختيار نقطة يدويًا.'**
  String get mapsPermissionDenied;

  /// No description provided for @mapsPermissionPermanent.
  ///
  /// In ar, this message translates to:
  /// **'إذن الموقع مرفوض. يمكنك تفعيله من إعدادات التطبيق في الجهاز أو الاختيار يدويًا.'**
  String get mapsPermissionPermanent;

  /// No description provided for @mapsLocationUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحديد موقعك الآن. حاول مجددًا أو اختر نقطة يدويًا.'**
  String get mapsLocationUnavailable;

  /// No description provided for @mapsNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم نجد عنوانًا لهذه النقطة. اكتب وصف المكان يدويًا.'**
  String get mapsNotFound;

  /// No description provided for @mapsRateLimited.
  ///
  /// In ar, this message translates to:
  /// **'طلبات كثيرة. انتظر قليلًا ثم حاول مجددًا.'**
  String get mapsRateLimited;

  /// No description provided for @mapsServiceFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر الاتصال بخدمة الخريطة. يمكنك الاحتفاظ بالنقطة وتسميتها يدويًا.'**
  String get mapsServiceFailed;

  /// No description provided for @mapsTapHint.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على الخريطة لتحديد نقطة، ثم راجع وصف المكان قبل تأكيده.'**
  String get mapsTapHint;

  /// No description provided for @mapsAddressLabel.
  ///
  /// In ar, this message translates to:
  /// **'وصف المكان'**
  String get mapsAddressLabel;

  /// No description provided for @mapsAddressHint.
  ///
  /// In ar, this message translates to:
  /// **'مثل: أمام مدخل المبنى'**
  String get mapsAddressHint;

  /// No description provided for @mapsSearch.
  ///
  /// In ar, this message translates to:
  /// **'البحث عن مكان'**
  String get mapsSearch;

  /// No description provided for @mapsConfirmLocation.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الموقع'**
  String get mapsConfirmLocation;

  /// No description provided for @mapsRouteFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل مسار الطريق من خدمة تم.'**
  String get mapsRouteFailed;

  /// No description provided for @mapsInvalidInput.
  ///
  /// In ar, this message translates to:
  /// **'راجع الموقع أو نص البحث المدخل.'**
  String get mapsInvalidInput;

  /// No description provided for @mapsAttributionUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'تعذر فتح معلومات حقوق الخريطة. حاول مجددًا.'**
  String get mapsAttributionUnavailable;

  /// No description provided for @mapsShowAttribution.
  ///
  /// In ar, this message translates to:
  /// **'معلومات مصدر الخريطة'**
  String get mapsShowAttribution;

  /// No description provided for @mapsOsmAttribution.
  ///
  /// In ar, this message translates to:
  /// **'© OpenStreetMap contributors'**
  String get mapsOsmAttribution;

  /// No description provided for @mapsSelectedPoint.
  ///
  /// In ar, this message translates to:
  /// **'نقطة محددة على الخريطة'**
  String get mapsSelectedPoint;

  /// No description provided for @mapsCurrentLocation.
  ///
  /// In ar, this message translates to:
  /// **'موقعي الحالي'**
  String get mapsCurrentLocation;

  /// No description provided for @mapsLocating.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحديد موقعك…'**
  String get mapsLocating;

  /// No description provided for @mapsEnableLocation.
  ///
  /// In ar, this message translates to:
  /// **'فعّل الموقع لتحديد الانطلاق'**
  String get mapsEnableLocation;

  /// No description provided for @mapsOpenSettings.
  ///
  /// In ar, this message translates to:
  /// **'فتح الإعدادات'**
  String get mapsOpenSettings;

  /// No description provided for @mapsLocationInaccurate.
  ///
  /// In ar, this message translates to:
  /// **'الموقع غير دقيق بما يكفي أو قراءته قديمة. فعّل الموقع الدقيق وحاول مجددًا، أو اختر الانطلاق على الخريطة.'**
  String get mapsLocationInaccurate;

  /// No description provided for @mapsNativeUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'الخريطة المتجهة متاحة على Android وiOS والويب.'**
  String get mapsNativeUnavailable;

  /// No description provided for @mapsMoveToSelect.
  ///
  /// In ar, this message translates to:
  /// **'حرّك الخريطة لتحديد المكان'**
  String get mapsMoveToSelect;

  /// No description provided for @mapsTurnOnLocation.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل الموقع'**
  String get mapsTurnOnLocation;

  /// No description provided for @mapsAllowLocation.
  ///
  /// In ar, this message translates to:
  /// **'السماح بالموقع'**
  String get mapsAllowLocation;
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
