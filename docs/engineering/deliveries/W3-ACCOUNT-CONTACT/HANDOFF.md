# إغلاق منطق العميل وحزمة الباكند — مرشح W3

الحالة REVIEW، دون اعتماد مستقل بعد. الكود المجمد:
`882c9e55ca17bc651f238d0b98abbabe14d877fb` على
codex/customer-backend-handoff داخل /home/hazem/projects/mashwar.
أساس W3 هو da34b3d؛ ويشمل upstream W2 للتقييم والدعم الذي لم يُعتمد
مستقلًا بعد. المراجعة المطلوبة تشمل كامل التغيير من bd24d59 إلى المرشح.
المنفذ المشرف root؛ راجع AGENTS وبطاقات المهام والسياسات الحالية.

## قرار المستخدم والنتيجة

المستخدم أكد استكمال منطق الرحلات الحالية مع تغيير الرقم وحذف الحساب
والاتصال بالسائق، ثم تسليم Postman واحد، ثم تحسين الواجهات أثناء عمل
الباكند. المحفظة والدفع الإلكتروني والكوبونات مؤجلة صراحة. الربط الحقيقي
واختبار الخدمات يأتيان بعد جاهزية الباكند؛ لا تعطل هذه المرحلة الصقل البصري.

- تغيير الرقم: تطبيع السوري بالقواعد الحالية، OTP مستقل للرقم الجديد، ثم
  إنهاء الجلسة دون اختراع AuthUser أوتوكن أوترقية localAccess.
- حذف الحساب: موافقة صريحة وOTP للرقم الحالي؛ لا عملية حذف على خادم من
  المحاكاة. القبول ينهي الجلسة ويمسح بيانات محاكاة التطبيق عبر الربط القائم.
- منع إدارة الحساب أثناء رحلة غير منتهية؛ يتحقق المستودع مجددًا عند
  التأكيد لمنع السباق مع حجز جديد. لا دمج حسابات أو سياسة احتفاظ قانونية.
- OTP خمسة دقائق، إعادة بعد30 ثانية، خمسة أخطاء تفرض قفل15 دقيقة عبر
  التحققات الجديدة أيضًا، وفق AccountPolicy المركزية. إعادة الإرسال تبطل
  الرمز السابق؛ معرّفات العمليات ثابتة عند إعادة المحاولة، ولا نكرر الأثر.
- تأكيد غير محسوم يقفل النية والرمز حتى قراءة receipt أو retry نفسه؛
  رفض هوية إقرار مختلفة، ومنع الإرسال المتزامن والردود بعد إغلاق/خروج.
- الاتصال: مصدر Trip نفسه، للحالات المسموحة وسائق معيّن فقط؛ يعاد التحقق
  من الهوية والصلاحية قبل فتح تطبيق الهاتف. tel منE164 فقط، لا URL حر أو
  CALL_PHONE. MockPhoneDialer لا يمرر أرقام fixtures إلى النظام.
- DriverPhoneDialer يستخدم url_launcher6.3.3، مع seam لاختبار URI ورفض
  الأرقام غير الآمنة وفشل المنصة. لا يدعي اتصالًا أو رد السائق.
- إذا انتقل التطبيق للخلفية أو انتهت الجلسة قبل الرد، لا يفتح اتصالًا متأخرًا.

المداخل في Settings وActiveTrip، والاختيار المركزي ACCOUNT_MANAGEMENT_DATA_MODE
وDRIVER_CONTACT_DATA_MODE يرث DATA_MODE. API غير جاهز يفشل صراحة بلا fallback.
لا تغيير لعقد Auth أو TEMPORARY_PHONE_ENTRY. الفئات Domain خالصة، والـSDK
فيdata، وget_it في التركيب، والـBloc/ARB والثيم والتوكنز مشتركة.

## ملف الباكند

[Postman الموحد](../../../api/postman/Tam-Customer-API-v1.postman_collection.json)
يضم14 مجلدًا و58 مثال طلب، وليس58 endpoint منفصلًا. وصف المجموعة فيه
العقد العربي الموحد، ووصف كل مجلد فيه عقد الميزة كاملًا، مع الطلبات والأمثلة.
[دليل المطور](../../../api/postman/README.ar.md) و[المصادر](../../../api/postman/customer-api-v1.manifest.json).

التجميع حتمي من14 مصدرًا، دون تكرار حزمة Auth المؤرشفة. المتغيرات التخصصية
لها بادئات مستقلة، والتفويض محفوظ عند حدود المجلدات والطلبات العامة. لا
scripts أوتوكنات حقيقية. وحدت401 لميزات Settings/Trips إلى UNAUTHENTICATED،
وأبقيت أكواد Auth الأصلية. حدثت القيود القديمة لـTrip والحجز لتوافق امتدادي
الجدولة والمتابعة؛ لا مصدر رحلة أوإلغاء موازٍ. تكرار endpoint يشرح سيناريوهات.

عقد الحساب يحدد X-Operation-Token المحدود لحسم عملية بعد إبطال الجلسة؛
لا يسمح بأول أثر دون Bearer وOTP، ولا يعيد ملف الحساب أوهاتفه. محول HTTP
المستقبلي يخزنه خصوصيًا في data؛ لا يمر عبر BLoC state أوlogs أوURL.
يلزم تدقيق مستقل لهذا الجانب وعقد الحذف والـidempotency قبل التسليم.

## الفحوص الفعلية

من apps/customer:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub --reporter expanded
```

334 ملفًا دون تغيير؛ analyze بلا ملاحظات؛ **618 اختبارًا ناجحًا**.
السجلات /tmp/tam-w3-analyze.log و/tmp/tam-w3-all-tests.log.
من الجذر: build_customer_postman.py --check وsync_feature_l10n.py --check
وgit diff --check ناجحة؛ JSON218 صالح، وستة اختبارات Python ناجحة:

```bash
python3 scripts/api/build_customer_postman.py --check
python3 -m unittest discover -s scripts/api/tests -v
python3 scripts/dev/sync_feature_l10n.py --check
git diff --check
```

الأمثلة الجديدة تطابق mock وmappers، والاختبارات تشمل العقد وOTP/cooldown/
expiry/lockout/retry/session reset/late replies وURI/background/dialer errors.
اختبارات App تعبر من Settings إلى تغيير/حذف وإنهاء الجلسة وإعادة الدخول
المحلي، ومن حجز بسائق إلى اتصال محاكى، مع حراسة API للضيف وlocalAccess.

40 صورة في screenshots/ فُتحت فعليًا عبر view_image ومجموعات صور؛ العربية
والإنجليزية،320/390/800 وlandscape،1x/2x وkeyboard insets محاكية. راجعت
أيضًا صور ActiveTrip/Settings الحالية بعد إضافة المداخل؛ لا صقل بصري نهائي.
المصدر Flutter widget renderer وخطوط Noto المحلية، لا Android أوiOS.
الصفحة الجديدة133 سطرًا وأكبر ملف ميزة269؛ DriverContact أكبر ملف99 سطرًا.

قارنة نهائية **92 اختبار UI ناجحًا دون تحديث الصور** بأعلام:
CAPTURE_ACCOUNT_CONTACT_UI وCAPTURE_COMPLETION_UI وCAPTURE_SUPPORT_UI و
CAPTURE_ACTIVE_TRIP_UI وCAPTURE_SETTINGS_GOLDENS وCAPTURE_TRIP_COMPLETION_UI
وCAPTURE_CHAT_UI=true، وCHAT_UI_DELIVERY=W2-FINAL-FEATURES. الملفات:
account_management/account_layout_test.dart، completion/completion_layout_test.dart،
completion/completion_widget_test.dart، support/support_widget_test.dart،
active_trip/active_trip_widget_test.dart، settings/settings_page_test.dart،
trips/trip_completion_layout_test.dart، chat/chat_widget_test.dart داخلtest/features.
السجل /tmp/tam-w3-golden-verify.log. التوليد الأولي استخدم --update-goldens
ثم فُحصت الرسوم وأعيدت المقارنة دون تحديث. الصور التاريخية في تسليم W2 لم تتغير.

## المتبقي وحدود القبول

المراجعة المستقلة للكود والعقود والملف المجمع على SHA محدد، ثم إصلاح
ملاحظاتها واعتماد الملف للإرسال. لم تُنفذ بعد؛ لا APPROVED_AT_SHA أوادعاء
تسليم نهائي. تراجع كذلك دفعة W2 السابقة ضمن الأساس المجمع.
لم تُنفذ طلبات خادم أوSMS أواتصال جهاز أو استيراد Postman فعلي. لا HTTP
repository حي، ولا Android build أومحاكي، ولا push/main/Actions.

بيانات المحاكاة محلية للجلسة؛ المسودات والعمليات غير المحسومة لعمر الصفحة،
دون outbox دائم. SDK الخرائط/GPS وPush وتسجيل الجهاز والتسليم بالخلفية
وربط الخدمات الحية لها مرحلة الربط وعقودها عند تحديد تكاملها؛ لا تُحسب
نجاحات محاكاة كخدمات حقيقية. لا نص قانوني منشور، ولا جاهزية إصدار.
