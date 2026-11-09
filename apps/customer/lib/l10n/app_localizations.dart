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
  /// **'تفاصيل الرحلة'**
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
  /// **'رقم الهاتف مأخوذ من تسجيل الدخول ولا يمكن تغييره هنا'**
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
