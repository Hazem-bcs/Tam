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

  @override
  String get homeGreeting => 'أهلًا بك،';

  @override
  String get homeChooseService => 'اختر خدمتك';

  @override
  String get homeRideEntryTitle => 'وين حابب تروح؟';

  @override
  String get homeRideEntryHint => 'حدد نقطة الانطلاق والوجهة لطلب رحلة';

  @override
  String get homeRide => 'مشوار';

  @override
  String get homeFood => 'الطعام';

  @override
  String get homeShopping => 'التسوق';

  @override
  String get homeComingSoon => 'قريبًا';

  @override
  String get homeLoading => 'جارٍ تحميل الرئيسية';

  @override
  String get homeEmpty => 'لا يوجد محتوى متاح حاليًا.';

  @override
  String get homeUnavailable => 'خدمة الرئيسية غير متاحة في وضع API حاليًا.';

  @override
  String get homeError => 'تعذر تحميل المحتوى. تحقق من اتصالك وحاول مجددًا.';

  @override
  String homeUnreadNotifications(int count) {
    return 'الإشعارات، غير المقروء: $count';
  }

  @override
  String get rideRequestTitle => 'احجز مشوارك';

  @override
  String get rideRequestPickup => 'نقطة الانطلاق';

  @override
  String get rideRequestPickupHint => 'حدد مكان الانطلاق';

  @override
  String get rideRequestDestination => 'الوجهة';

  @override
  String get rideRequestDestinationHint => 'إلى أين تريد الذهاب؟';

  @override
  String get rideRequestSearchPlaces => 'ابحث عن موقع';

  @override
  String get rideRequestNoPlaces => 'لا توجد مواقع مطابقة. جرّب اسمًا آخر.';

  @override
  String get rideRequestMockMap => 'خريطة توضيحية • المواقع محاكاة وليست GPS';

  @override
  String get rideRequestRouteHint =>
      'اختر الانطلاق والوجهة لعرض السعر التقريبي.';

  @override
  String get rideRequestChooseClass => 'حدد نوع الرحلة';

  @override
  String get rideRequestStandard => 'عادية';

  @override
  String get rideRequestStandardDescription => 'لمشاويرك اليومية';

  @override
  String get rideRequestComfort => 'مريحة';

  @override
  String get rideRequestComfortDescription => 'مساحة وراحة أكثر';

  @override
  String get rideRequestVan => 'فان';

  @override
  String get rideRequestVanDescription => 'للمجموعات والعائلة';

  @override
  String get rideRequestMotorbike => 'موتور';

  @override
  String get rideRequestMotorbikeDescription => 'للمستندات والطرود';

  @override
  String get rideRequestQuoteTitle => 'تفاصيل الرحلة';

  @override
  String get rideRequestDistance => 'المسافة';

  @override
  String get rideRequestDuration => 'المدة';

  @override
  String get rideRequestFare => 'السعر';

  @override
  String get rideRequestCurrencySyp => 'ل.س';

  @override
  String get rideRequestKm => 'كم';

  @override
  String get rideRequestMinute => 'دقيقة';

  @override
  String get rideRequestPayment => 'طريقة الدفع';

  @override
  String get rideRequestCash => 'نقدًا';

  @override
  String get rideRequestCashOnly => 'الدفع النقدي متاح حاليًا في المحاكاة فقط.';

  @override
  String get rideRequestReview => 'مراجعة الطلب';

  @override
  String get rideRequestConfirm => 'تأكيد طلب الرحلة';

  @override
  String get rideRequestConfirming => 'جارٍ تأكيد الطلب';

  @override
  String get rideRequestQuoteLoading => 'جارٍ احتساب السعر';

  @override
  String get rideRequestRetry => 'إعادة المحاولة';

  @override
  String get rideRequestRefreshQuote => 'إعادة تسعير الرحلة';

  @override
  String get rideRequestErrorValidation =>
      'تحقق من اختيار موقعين مختلفين وفئة صالحة.';

  @override
  String get rideRequestErrorExpired =>
      'انتهت صلاحية السعر. اطلب سعرًا جديدًا.';

  @override
  String get rideRequestErrorUnavailable =>
      'الخدمة غير متاحة الآن. حاول مجددًا.';

  @override
  String get rideRequestErrorConflict => 'تعذر التأكيد بسبب تعارض في الطلب.';

  @override
  String get rideRequestErrorGeneric => 'تعذر إكمال العملية. حاول مجددًا.';

  @override
  String get rideRequestSimulationNotice =>
      'تجربة محلية فقط: لا تُرسل رحلة حقيقية ولا تُخصم مبالغ.';

  @override
  String get rideRequestSelected => 'تم الاختيار';

  @override
  String get rideRequestPlaceSearchLoading => 'جارٍ البحث عن المواقع';

  @override
  String get rideRequestEdit => 'تعديل';

  @override
  String get rideRequestImmediate => 'فوري';

  @override
  String get rideRequestScheduled => 'مجدولة';

  @override
  String get rideRequestScheduleTitle => 'حدد موعد الرحلة';

  @override
  String get rideRequestScheduleDate => 'التاريخ';

  @override
  String get rideRequestScheduleTime => 'موعد الرحلة';

  @override
  String rideRequestScheduleTimezone(String offset) {
    return 'التوقيت المعتمد: $offset';
  }

  @override
  String rideRequestScheduleRange(int minutes, int days) {
    return 'اختر موعدًا بين $minutes دقيقة و$days أيام من الآن.';
  }

  @override
  String get rideRequestScheduleInvalid =>
      'الموعد خارج المدى المتاح الآن. عدّل التاريخ أو الوقت ثم أعد المحاولة.';

  @override
  String get rideRequestScheduleUnavailable =>
      'الجدولة غير متاحة لهذا الموعد. اختر موعدًا آخر أو اطلب رحلة فورية.';

  @override
  String get rideRequestScheduleSave => 'تأكيد الموعد';

  @override
  String get rideRequestScheduleCancel => 'إلغاء';

  @override
  String get rideRequestScheduledNotice =>
      'حجز موعد مسبق لا يعني تعيين سائق الآن.';

  @override
  String get rideRequestHour => 'الساعة';

  @override
  String get rideRequestMinuteInput => 'الدقيقة';

  @override
  String get rideRequestTimeFormat => 'الوقت بنظام 24 ساعة (00–23).';

  @override
  String get rideRequestTimeInvalid => 'أدخل قيمة صحيحة ضمن المجال.';

  @override
  String get tripsAll => 'الكل';

  @override
  String get tripsActive => 'النشطة';

  @override
  String get tripsCompletedFilter => 'المكتملة';

  @override
  String get tripsCancelledFilter => 'الملغاة';

  @override
  String get tripsStatusRequested => 'بانتظار التأكيد';

  @override
  String get tripsStatusConfirmed => 'مؤكدة';

  @override
  String get tripsStatusInProgress => 'قيد التنفيذ';

  @override
  String get tripsStatusCompleted => 'مكتملة';

  @override
  String get tripsStatusCancelled => 'ملغاة';

  @override
  String get tripsFrom => 'من';

  @override
  String get tripsTo => 'إلى';

  @override
  String get tripsDetails => 'التفاصيل';

  @override
  String get tripsDetailsTitle => 'تفاصيل الرحلة';

  @override
  String tripsTripNumber(String id) {
    return 'الرحلة رقم $id';
  }

  @override
  String get tripsCreatedAt => 'وقت الطلب';

  @override
  String get tripsFare => 'الأجرة';

  @override
  String get tripsVehicleClass => 'فئة المركبة';

  @override
  String get tripsVehicleStandard => 'عادية';

  @override
  String get tripsEmptyTitle => 'لا توجد رحلات هنا';

  @override
  String get tripsEmptyDescription => 'ستظهر رحلاتك في هذا القسم عندما تتوفر.';

  @override
  String get tripsErrorTitle => 'تعذّر تحميل الرحلات';

  @override
  String get tripsErrorDescription => 'تحقق من اتصالك وأعد المحاولة.';

  @override
  String get tripsRetry => 'إعادة المحاولة';

  @override
  String get tripsRefresh => 'تحديث';

  @override
  String get tripsLoadMore => 'عرض المزيد';

  @override
  String get tripsCancel => 'إلغاء الرحلة';

  @override
  String get tripsCancelTitle => 'هل تريد إلغاء الرحلة؟';

  @override
  String get tripsCancelPrompt => 'لا يمكن التراجع عن الإلغاء بعد تأكيده.';

  @override
  String get tripsConfirmCancel => 'تأكيد الإلغاء';

  @override
  String get tripsKeepTrip => 'الاحتفاظ بالرحلة';

  @override
  String get tripsCancelledSuccess => 'تم إلغاء الرحلة.';

  @override
  String get tripsCannotCancel => 'لا يمكن إلغاء الرحلة في حالتها الحالية.';

  @override
  String get tripsRebook => 'اطلب مجددًا';

  @override
  String get tripsNotFoundTitle => 'الرحلة غير موجودة';

  @override
  String get tripsNotFoundDescription =>
      'ربما حُذفت هذه الرحلة أو لم يعد الوصول إليها متاحًا.';

  @override
  String get tripsBackToList => 'العودة إلى طلباتي';

  @override
  String get tripsFareNote =>
      'هذه أجرة محفوظة للرحلة السابقة، ولا تُستخدم عند إعادة الطلب.';

  @override
  String get tripsServiceUnavailable => 'خدمة الرحلات غير متاحة حاليًا.';

  @override
  String get tripsValidationError => 'الطلب غير صالح. أعد المحاولة.';

  @override
  String get tripsUnknownError => 'حدث خطأ غير متوقع. أعد المحاولة.';

  @override
  String get tripsPaginationError => 'تعذّر تحميل المزيد من الرحلات.';

  @override
  String get tripsRoute => 'مسار الرحلة';

  @override
  String get tripsInformation => 'معلومات الرحلة';

  @override
  String get tripsNoLiveTracking =>
      'لا يتوفر تتبع مباشر للرحلة في هذا الإصدار.';

  @override
  String get tripsLoading => 'جارٍ تحميل الرحلات';

  @override
  String get tripsLoadingDetails => 'جارٍ تحميل تفاصيل الرحلة';

  @override
  String get tripsCancelling => 'جارٍ الإلغاء';

  @override
  String get tripsTripList => 'قائمة الرحلات';

  @override
  String get tripsStatusScheduled => 'مجدولة';

  @override
  String get tripsScheduledTime => 'موعد الرحلة';

  @override
  String tripsScheduledAt(String time) {
    return 'الموعد: $time';
  }

  @override
  String get tripsStatusDriverEnRoute => 'السائق في الطريق';

  @override
  String get tripsStatusDriverArrived => 'السائق ينتظرك';

  @override
  String get tripsStatusNoDriver => 'لا يوجد سائق';

  @override
  String get tripsCompletion => 'ملخص الرحلة وتقييمها';

  @override
  String get tripsSupport => 'المساعدة بخصوص الرحلة';

  @override
  String get notificationsMarkAll => 'تعيين الكل كمقروء';

  @override
  String notificationsUnreadCount(int count) {
    return 'غير مقروء: $count';
  }

  @override
  String get notificationsUnknownCount => 'العدد غير متاح';

  @override
  String get notificationsToday => 'اليوم';

  @override
  String get notificationsYesterday => 'أمس';

  @override
  String get notificationsEarlier => 'سابقًا';

  @override
  String get notificationsLoadMore => 'عرض المزيد';

  @override
  String get notificationsLoadingMore => 'جاري تحميل المزيد';

  @override
  String get notificationsRefresh => 'تحديث';

  @override
  String get notificationsRetry => 'إعادة المحاولة';

  @override
  String get notificationsEmptyTitle => 'لا توجد إشعارات بعد';

  @override
  String get notificationsEmptyBody => 'ستظهر إشعاراتك هنا عند توفرها.';

  @override
  String get notificationsErrorTitle => 'تعذر تحميل الإشعارات';

  @override
  String get notificationsErrorBody => 'تحقق من اتصالك وحاول مجددًا.';

  @override
  String get notificationsOfflineBody =>
      'خدمة الإشعارات غير متاحة في وضع API حاليًا.';

  @override
  String get notificationsMutationError =>
      'لم يُحفظ تغيير حالة القراءة. حاول مجددًا.';

  @override
  String get notificationsMoreError => 'تعذر تحميل المزيد.';

  @override
  String get notificationsUnavailableTarget =>
      'لا تتوفر وجهة آمنة لفتح هذا الإشعار.';

  @override
  String get notificationsRead => 'مقروء';

  @override
  String get notificationsUnread => 'غير مقروء';

  @override
  String get notificationsLoading => 'جاري تحميل الإشعارات';

  @override
  String get notificationsOpenNotification => 'فتح الإشعار';

  @override
  String get settingsTitle => 'حسابي';

  @override
  String get settingsProfileSubtitle => 'إدارة بيانات حسابك';

  @override
  String get settingsEditName => 'تعديل الاسم';

  @override
  String get settingsName => 'الاسم الظاهر';

  @override
  String get settingsNameHint => 'من حرفين إلى 60 حرفًا';

  @override
  String get settingsNameValidation =>
      'أدخل اسمًا من حرفين إلى 60 حرفًا دون رموز تحكم';

  @override
  String get settingsPhone => 'رقم الهاتف';

  @override
  String get settingsPhoneReadOnly =>
      'رقم الهاتف مأخوذ من تسجيل الدخول ولا يمكن تغييره هنا';

  @override
  String get settingsPhoneUnavailable => 'لا يوجد رقم هاتف لهذه الجلسة';

  @override
  String get settingsSaveName => 'حفظ الاسم';

  @override
  String get settingsPreferencesTitle => 'الإعدادات';

  @override
  String get settingsAccountNotifications => 'إشعارات الحساب';

  @override
  String get settingsNotificationHint =>
      'تفضيل محلي تجريبي للإشعارات داخل التطبيق؛ لا يطلب صلاحية Push';

  @override
  String get settingsSavePreferences => 'حفظ تفضيل الإشعارات';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsArabic => 'العربية';

  @override
  String get settingsEnglish => 'English';

  @override
  String get settingsUnsaved => 'تغييرات غير محفوظة';

  @override
  String get settingsUnsavedTitle => 'تغييرات غير محفوظة';

  @override
  String get settingsUnsavedMessage =>
      'إذا غادرت الآن فستفقد التغييرات التي لم تحفظها.';

  @override
  String get settingsKeepEditing => 'متابعة التعديل';

  @override
  String get settingsDiscard => 'تجاهل التغييرات';

  @override
  String get settingsInfoTitle => 'الدعم والمعلومات';

  @override
  String get settingsMockNotice =>
      'الحساب والتفضيلات هنا محاكاة للتطوير، وليسا متصلين بخادم. حفظ اللغة يعمل فورًا طوال هذه الجلسة فقط.';

  @override
  String get settingsLogout => 'تسجيل الخروج';

  @override
  String get settingsLogoutConfirm => 'هل تريد تسجيل الخروج من الجلسة الحالية؟';

  @override
  String get settingsCancel => 'إلغاء';

  @override
  String get settingsLogoutError => 'تعذر تسجيل الخروج. حاول مجددًا.';

  @override
  String get settingsNotifications => 'فتح الإشعارات';

  @override
  String get settingsLoading => 'تحميل الإعدادات';

  @override
  String get settingsServiceUnavailable =>
      'تعذر تحميل بيانات الحساب. الخدمة غير متاحة حاليًا.';

  @override
  String get settingsRetry => 'إعادة المحاولة';

  @override
  String get settingsSaveError =>
      'تعذر حفظ التغييرات. لم يتم تعديل البيانات المحفوظة؛ يمكنك المحاولة مجددًا.';

  @override
  String get settingsSaved => 'تم حفظ التغييرات التجريبية';

  @override
  String get settingsSaving => 'جارٍ الحفظ';

  @override
  String get settingsLoggingOut => 'جارٍ تسجيل الخروج';

  @override
  String get settingsHelp => 'المساعدة والدعم';

  @override
  String get settingsTerms => 'الشروط والأحكام';

  @override
  String get settingsPrivacy => 'سياسة الخصوصية';

  @override
  String get addressesTitle => 'عناويني';

  @override
  String get addressesDescription => 'احفظ أماكنك للوصول إليها أسرع';

  @override
  String get addressesAdd => 'إضافة موقع';

  @override
  String get addressesEdit => 'تعديل الموقع';

  @override
  String get addressesDelete => 'حذف الموقع';

  @override
  String get addressesDeleteTitle => 'حذف هذا الموقع؟';

  @override
  String get addressesDeleteBody =>
      'سيُحذف من عناوينك المحفوظة. لن تتغير الرحلات السابقة.';

  @override
  String get addressesCancel => 'إلغاء';

  @override
  String get addressesConfirmDelete => 'حذف';

  @override
  String get addressesLoading => 'جارٍ تحميل العناوين';

  @override
  String get addressesSaving => 'جارٍ حفظ الموقع';

  @override
  String get addressesSave => 'حفظ الموقع';

  @override
  String get addressesEmpty => 'لا توجد عناوين محفوظة بعد';

  @override
  String get addressesEmptyBody => 'أضف مكانًا لتختاره بسهولة عند طلب رحلة.';

  @override
  String get addressesError => 'تعذر إكمال العملية. حاول مجددًا.';

  @override
  String get addressesUnavailable =>
      'خدمة العناوين غير متاحة في وضع API حاليًا.';

  @override
  String get addressesNotFound => 'هذا العنوان لم يعد موجودًا.';

  @override
  String addressesLimit(int max) {
    return 'يمكنك حفظ $max عنوانًا كحد أقصى.';
  }

  @override
  String get addressesConflict => 'تعارضت محاولة الحفظ. أعد المحاولة.';

  @override
  String get addressesRetry => 'إعادة المحاولة';

  @override
  String get addressesRefresh => 'تحديث العناوين';

  @override
  String get addressesName => 'اسم المكان';

  @override
  String get addressesNameHint => 'مثال: المنزل أو العمل';

  @override
  String addressesNameError(int max) {
    return 'اكتب اسمًا من 1 إلى $max محرفًا.';
  }

  @override
  String get addressesLocation => 'الموقع';

  @override
  String get addressesChooseLocation => 'اختر موقع المكان';

  @override
  String get addressesLocationError => 'اختر موقعًا قبل الحفظ.';

  @override
  String get addressesSearch => 'ابحث عن مكان';

  @override
  String get addressesNoPlaces => 'لا توجد أماكن مطابقة. جرّب بحثًا آخر.';

  @override
  String get addressesChooseIcon => 'اختر أيقونة';

  @override
  String get addressesIconHome => 'منزل';

  @override
  String get addressesIconWork => 'عمل';

  @override
  String get addressesIconStudy => 'دراسة';

  @override
  String get addressesIconGym => 'نادي';

  @override
  String get addressesIconOther => 'أخرى';

  @override
  String get addressesDiscardTitle => 'تجاهل التعديلات؟';

  @override
  String get addressesDiscardBody => 'لم تُحفظ تعديلاتك على هذا المكان بعد.';

  @override
  String get addressesDiscard => 'تجاهل';

  @override
  String get addressesKeepEditing => 'متابعة التعديل';

  @override
  String get addressesRetryPending =>
      'لم يصل تأكيد الحفظ. أعد المحاولة للتحقق من العملية نفسها دون إضافة موقع مكرر.';

  @override
  String get addressesManage => 'إدارة العناوين';

  @override
  String get addressesSavedTab => 'العناوين المحفوظة';

  @override
  String get addressesSearchTab => 'البحث';

  @override
  String get activeTripTitle => 'متابعة الرحلة';

  @override
  String get activeTripHome => 'الرئيسية';

  @override
  String get activeTripFollow => 'متابعة رحلتي';

  @override
  String get activeTripLoading => 'جارٍ تحديث الرحلة…';

  @override
  String get activeTripRefresh => 'تحديث الحالة';

  @override
  String get activeTripEmpty => 'لا توجد رحلة متاحة للمتابعة الآن.';

  @override
  String get activeTripNewBooking => 'اطلب رحلة';

  @override
  String get activeTripScheduledHint =>
      'رحلتك محفوظة للموعد المحدد. يبدأ البحث عند الموعد.';

  @override
  String get activeTripSearchingHint => 'نبحث عن سائق مناسب لرحلتك.';

  @override
  String get activeTripAssignedHint =>
      'تم قبول الرحلة. يتجهز السائق للانطلاق إليك.';

  @override
  String get activeTripEnRouteHint => 'السائق في الطريق إلى نقطة الانطلاق.';

  @override
  String get activeTripArrivedHint => 'وصل السائق وينتظرك عند نقطة الانطلاق.';

  @override
  String get activeTripJourneyHint => 'أنت في الطريق إلى وجهتك.';

  @override
  String get activeTripCompletedHint => 'وصلت إلى وجهتك. اكتملت الرحلة.';

  @override
  String get activeTripCancelledHint => 'أُلغيت هذه الرحلة.';

  @override
  String get activeTripNoDriverHint =>
      'لم نجد سائقًا لهذه الرحلة. يمكنك طلب رحلة جديدة بسعر محدث.';

  @override
  String activeTripPlate(String plate) {
    return 'رقم السيارة: $plate';
  }

  @override
  String activeTripRating(String rating) {
    return 'التقييم: $rating من 5';
  }

  @override
  String get activeTripDriverDetails => 'عرض بيانات السائق والسيارة';

  @override
  String get activeTripContactPending => 'المكالمات غير مربوطة حاليًا.';

  @override
  String get activeTripClose => 'إغلاق';

  @override
  String activeTripRouteSemantics(String pickup, String destination) {
    return 'المسار من $pickup إلى $destination';
  }

  @override
  String get activeTripPositionStale =>
      'موقع السائق غير محدث؛ لا تعتمد على موضعه أو وقت الوصول السابق.';

  @override
  String get activeTripSchematic => 'مسار توضيحي؛ ليس خريطة ملاحة.';

  @override
  String get activeTripCancelTitle => 'إلغاء الرحلة';

  @override
  String get activeTripCancelPrompt => 'هل تريد إلغاء هذه الرحلة؟';

  @override
  String get activeTripKeep => 'متابعة الرحلة';

  @override
  String get activeTripConfirmCancel => 'تأكيد الإلغاء';

  @override
  String get activeTripCancelUncertain =>
      'لم نتأكد من نتيجة الإلغاء. أعد المحاولة للرحلة نفسها قبل طلب بديل.';

  @override
  String get activeTripRetryCancel => 'إعادة محاولة الإلغاء';

  @override
  String get activeTripCancelling => 'جارٍ الإلغاء…';

  @override
  String get activeTripRebook => 'طلب رحلة جديدة';

  @override
  String get activeTripDetails => 'تفاصيل الطلب';

  @override
  String get activeTripCannotCancel =>
      'بدأت الرحلة أو تغيرت حالتها؛ لا يمكن إلغاؤها الآن.';

  @override
  String get activeTripNotFound => 'لم تعد هذه الرحلة متاحة.';

  @override
  String get activeTripInvalidResponse =>
      'تعذر التحقق من تحديث الرحلة. حاول التحديث مجددًا.';

  @override
  String get activeTripAccessDenied => 'تحتاج هذه العملية إلى جلسة مصرح بها.';

  @override
  String get activeTripUnavailable => 'خدمة متابعة الرحلة غير متاحة حاليًا.';

  @override
  String get activeTripConnectionLost =>
      'تعذر تحديث الرحلة. تحقق من الاتصال وأعد المحاولة.';

  @override
  String get activeTripCached =>
      'هذه آخر حالة وصلت؛ قد تكون الرحلة تغيرت أثناء الانقطاع.';

  @override
  String activeTripEta(int minutes) {
    return 'الوصول المتوقع خلال $minutes دقيقة';
  }

  @override
  String get activeTripSimulationNotice =>
      'تعمل الرحلة حاليًا بمحاكاة محلية حتى ربط الخدمة.';

  @override
  String get activeTripChat => 'محادثة السائق';

  @override
  String get activeTripCompletion => 'ملخص الرحلة وتقييمها';

  @override
  String get activeTripSupport => 'المساعدة بخصوص الرحلة';

  @override
  String get chatTitle => 'السائق';

  @override
  String get chatRetry => 'إعادة المحاولة';

  @override
  String get chatMessageHint => 'اكتب رسالة…';

  @override
  String get chatSend => 'إرسال';

  @override
  String get chatRefresh => 'تحديث المحادثة';

  @override
  String get chatLoading => 'جارٍ تحميل المحادثة';

  @override
  String get chatEmpty => 'لا توجد رسائل بعد';

  @override
  String get chatReadOnly => 'انتهت الرحلة. المحادثة للقراءة فقط.';

  @override
  String get chatLoadOlder => 'تحميل رسائل أقدم';

  @override
  String get chatNewest => 'أحدث الرسائل';

  @override
  String get chatSent => 'أُرسلت';

  @override
  String get chatDelivered => 'تم التسليم';

  @override
  String get chatRead => 'مقروءة';

  @override
  String get chatSending => 'جارٍ الإرسال…';

  @override
  String get chatFailed => 'تعذر الإرسال';

  @override
  String get chatUncertain => 'لم يتأكد الإرسال — حدّث أو أعد المحاولة';

  @override
  String get chatValidation => 'أدخل رسالة من ١ إلى ١٠٠٠ حرف.';

  @override
  String get chatUnavailable => 'المحادثة غير متاحة لهذا السائق أو هذه الرحلة.';

  @override
  String get chatSessionEnded => 'انتهت الجلسة. ارجع إلى الرئيسية.';

  @override
  String get chatConnectionError =>
      'تعذر الاتصال. آخر الرسائل محفوظة؛ حدّث للمحاولة مجددًا.';

  @override
  String chatCharacterCount(int count, int max) {
    return '$count / $max حرف';
  }

  @override
  String get chatSimulation => 'محاكاة تطوير';
}
