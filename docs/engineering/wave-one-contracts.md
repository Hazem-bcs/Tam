# تم — أساس التنفيذ وحدود الدفعة الأولى

هذه قرارات تنفيذ للدفعة mock فقط، يثبتها المشرف في نسخة البداية. عقود
الخادم المطلوبة مقترحة للباكند وليست وصفًا لخادم موجود. التغيير المشترك
يُطلب من المشرف ولا يُفرض من فرع ميزة على بقية الوكلاء.

## نقاط الدخول والتشغيل

- `AppConfig.featureDataModes` يقرأ DATA_MODE وoverrides الخمسة الموثقة
  في سياسة المحاكاة؛ mock افتراضي، والقيم غير المعروفة تفشل بوضوح.
- الراوتر يستدعي `<feature>/<feature>_entry.dart` لكل ميزة. يحق لمالكها
  استبدال جسم الدالة دون تغيير توقيعها أو تعديل app/router أو app/app.dart.
  هذه الدالة نقطة تركيب: تختار Repository وتحقنه في Cubit/الصفحات.
- الأجسام الحالية حدود «غير متاح» صادقة حتى ينفذها أصحابها؛ لا تعد ميزات
  منجزة. Home الحالي محفوظ عبر home_entry كي تبقى اختبارات Auth صالحة.
- `CustomerNavigation` يفتح الرئيسية/الحجز/القائمة/تفاصيل رحلة/الإشعارات/
  الإعدادات. لا يكتب الوكيل route strings داخل الميزة؛ لا تمرر JSON إلى التنقل.
- المسارات الحالية: `/`، `/ride-request`، `/trips`، `/trips/:tripId`،
  `/notifications`، `/settings`. تبقى مسارات Auth كما هي. `tripId` هو مدخل
  شاشة التفاصيل، و`TripPrefill` يحمل مكاني الانطلاق والوصول لإعادة الطلب فقط.
- mock يسمح localAccess/guest بواجهات المحاكاة؛ api يحمي المسارات الشخصية
  والحجز والإعدادات بجلسة authenticated. Home عام؛ API implementations
  غير جاهزة تعرض فشل عدم التوفر ولا تستخدم mock كخطة سقوط صامتة.
- لا يكتب أحد FakeAuth أو token أو verified user لتجاوز الحراسة.

## الحالة المشتركة للرحلات

- الأنواع canonical في `shared/domain/trip.dart` و`geo_point.dart`.
  مسار GeoPoint القديم compatibility export؛ لا تُنشئ GeoPoint ثانية.
- TripLocation: label + GeoPoint(latitude, longitude). الموقع بيانات محتوى؛
  لا تعني الأسماء الاصطناعية معرفة موقع الجهاز الحقيقي.
- TripPrefill: pickup/destination فقط. أعِد التسعير قبل أي تأكيد جديد.
- Money: amountMinor عدد صحيح غير سالب، currency مثل SYP، minorUnit.
  سيناريو الدفعة SYP مع minorUnit=0؛ لا تستخدم double للمال ولا تقسّم على
  100 دائمًا. أسماء حقول النقل: amount_minor/currency/minor_unit.
- TripStatus values عند النقل: requested, confirmed, in_progress, completed,
  cancelled؛ `inProgress` اسم Dart المقابل. الإلغاء مسموح requested/confirmed
  فقط، والإلغاء المكرر يعيد النتيجة الملغاة نفسها دون عملية ثانية.
- `MockTripStore` instance واحد يملكه TamApp ويحقنه في entry الحجز وطلباتي.
  يستدعي B `create(input, idempotencyKey: ...)` ويستدعي C `trips/find/changes/cancel`.
  يقرأ C snapshot أولًا ويتابع changes ويلغي اشتراكه عند انتهاء مالك الحالة.
  لا ينشئ أيهما store بديلًا في جسم الصفحة أو عند كل build.
- المستودعات تترجم MockTripStoreFailure إلى فشل domain، ولا تعرضه للـUI
  كاستثناء data. لا يستورد domain هذا المخزن أو وضع التشغيل.
- المحاكاة seed ثابت مشترك: mock-history-001 مكتملة وmock-history-002 ملغاة.
  الطلبات الجديدة mock-trip-N. عند انتهاء جلسة دخول محلية/ضيف/حقيقية يمسح المخزن العمليات المنشأة
  ومفاتيح تكرارها ويعيد فقط seed الاصطناعي الثابت؛ تعاد إشعاراته المرتبطة
  معه كي لا تشير إلى رحلة غائبة. يُغلق المخزن مع التطبيق. لا تحفظ بياناته في جلسة Auth أو SQLite.
- seed خاص بتطوير المحاكاة؛ يحقن في الاختبارات أو السيناريوهات البديلة بدل
  نسخ قائمة رحلات أخرى في C. لا توجد مطابقة سائق أو GPS أو دفع حي بهذه الدفعة.

## حدود عمليات الباكند بين الملاك

| المالك | العمليات المقترحة التي يحدد عقدها | ما لا يملكه |
|---|---|---|
| A/Home | GET /home لمحتوى الرئيسية فقط | قائمة الرحلات وبحث الأماكن وعداد إشعارات مستقل |
| B/Ride | GET /places، POST /ride-quotes، POST /trips | GET /trips أو إلغاء الرحلات أو واجهة تاريخ ثانية |
| C/Trips | GET /trips، GET /trips/{id}، POST /trips/{id}/cancel | إعادة إنشاء الحجز أو حساب سعر حقيقي |
| D/Notifications | GET /notifications، GET /notifications/unread-count، POST /notifications/{id}/read، POST /notifications/read-all | Push/FCM والتتبع الحي |
| E/Settings | GET /me/profile، PATCH /me/profile، GET/PATCH /me/preferences | تعديل عقد /auth/me أو إنتاج هوية Auth أو SMS |

يجوز حذف endpoint مقترح لا يحتاجه التدفق مع توضيح السبب، لكن إضافة/تغيير
عملية يملكها وكيل آخر تحتاج تنسيقًا. يبدأ كل مالك بتوثيق عقده ويطبق mock
عليه ثم UI؛ تعديل مشترك لاحق يسجل كطلب تغيير وليس نسخة عقد موازية.

## شكل النقل الموحد

- base_url يشمل `/api/v1`، دون أسرار. استعمل قواعد headers ونجاح `data`
  وفشل `error.code` و`error.message.ar/en` في عقد Auth دون تعديل الأصل.
- المعرفات strings opaque؛ أنشئ URLs بأداة URI لا بضم نص غير مرمز.
- كل وقت للخادم ISO-8601 UTC ينتهي Z؛ التحويل للعرض محلي. التقاط الزمن
  في tests قابل للحقن. الحقول nullable وrequired موثقة، ولا تعتمد على defaults مخفية.
- صفحات القوائم: limit=20 افتراضيًا، بين 1 و50؛ cursor opaque اختياري.
  الاستجابة `data: [...]` و`meta: {next_cursor: string|null}`. الترتيب
  created_at تنازليًا ثم id تصاعديًا؛ لا تكرر العناصر عند دمج صفحة لاحقة.
- قائمة الرحلات تقبل filter=all|active|completed|cancelled؛ active تضم
  requested/confirmed/in_progress. النتائج الفارغة نجاح وليست خطأ.
- Trip response المشتركة: id/pickup/destination/vehicle_class_id/fare/status/
  created_at. يملك C تفاصيل العرض الإضافية، وينسق أي تغيير بالحقول المشتركة
  مع B. label وlatitude وlongitude داخل pickup/destination.
- عرض السعر يحمل quote_id وexpires_at وفئة وسعرًا محددين. تأكيد POST /trips
  يحمل quote_id والمواقع والفئة وIdempotency-Key؛ الخادم صاحب السعر النهائي،
  ولا نطلب منه الثقة بسعر يرسله Flutter. المحاكاة تحفظ نفس المفتاح أثناء
  إعادة محاولة التأكيد؛ اختلاف الجسم مع المفتاح نفسه IDEMPOTENCY_CONFLICT.
- أكواد الحجز/الرحلات المشتركة: QUOTE_EXPIRED، IDEMPOTENCY_CONFLICT،
  TRIP_NOT_FOUND، TRIP_NOT_CANCELLABLE، VALIDATION_ERROR، SERVICE_UNAVAILABLE؛
  يحدد العقد statuses والمعلومات الإضافية. لا يُغير ذلك أخطاء Auth المعتمدة.
- وجهة الإشعار allowlist: target.type=home|trips|trip، ومع trip يوجد trip_id؛
  لا تقبل URL خارجيًا أو route نصيًا من استجابة وتفتحه مباشرة. يستخدم D
  mock-history-001 للإشعار الذي يفتح تفاصيل رحلة موجودة. unknown targets
  تظهر المحتوى دون تنقل خاطئ. لا ينسخ A مصدر عداد D؛ شارة Home تؤجل لتكامل
  مصدر D عند التسليم إن لم تكن واجهته جاهزة، دون رقم وهمي ثابت داخل Home.
- E يفصل profile المحاكى عن AuthUser؛ الهاتف المعروض من phoneE164 المحقون
  وهو للقراءة. اللغة ar/en إعداد محلي عبر AppLocaleController، تعمل فورًا
  وتبقى خلال العملية الحالية؛ الحفظ بعد إعادة تشغيل التطبيق مهمة لاحقة.

## ملكية الترجمة دون تعارض

الـARB الأصلية العامة في `apps/customer/l10n/base/` تحت ملكية المشرف.
لكل مالك `lib/features/<feature>/l10n/app_ar.arb` وapp_en.arb. prefixes:
home، rideRequest، trips، notifications، settings؛ الحرف التالي كبير.
المفاتيح متطابقة بين اللغتين، ومع metadata عند وجود placeholders.
هذا امتداد لمدخلات Flutter ARB نفسها، وليس آلية ترجمة ثانية.

من جذر المستودع شغّل `python3 scripts/dev/sync_feature_l10n.py`، ثم من
apps/customer شغّل `flutter gen-l10n` وبعده format/analyze/test.
الأداة تتحقق من اللغات والملكية والتكرار قبل الكتابة. لا تعدّل يدويًا
lib/l10n/app_*.arb ولا app_localizations*.dart. هذه نواتج مجمعة محليًا
لا يضمها الوكيل لكوميت ميزة؛ يرفع fragment المملوك فقط. يذكر في التسليم
أن هذه الملفات المشتقة dirty بسبب التوليد، والمشرف يعيد التوليد ويضمها
لكوميت التكامل. المراجع يعيد الأوامر من SHA التسليم للحصول على النواتج نفسها.

## حدود المراجعة والتصميم

وفق قرار 2026-11-08 في [خطة المرحلتين](development-phases.md)، قبول الدفعة
الحالية تقني/وظيفي مع واجهة مبدئية قريبة من الهدف. تحسين المطابقة البصرية
الكاملة مؤجل للمرحلة الثانية، مع استمرار متطلبات الثيم والتجاوب واللغتين
والاستخدام السليم. تحفظ فروق المراجع في قائمة متابعة ولا تمنع الدمج وحدها.

الهوية تم والثيم الحالي. الصور المذكورة في كل بطاقة مرجع الأقسام، ولا
تمنح ملكية ميزات السائق أو المتجر أو المحفظة. حالات التحميل/الفراغ/الفشل
والتابلت/الخط الكبير التي لا ترسمها الصور تنفذ بنفس المكونات واللغة البصرية.
النطاق التفصيلي ومعايير القبول في بطاقات المهام، وليس تخمين شكل صورة ناقصة.

## امتداد العناوين المحفوظة —2026-11-08

أضيفت features/addresses بمدخلاتها وعقدها في [بطاقة W2-ADDRESSES](tasks/W2-ADDRESSES.md).
العناوين Repository واحد يملكه TamApp، يختاره ADDRESSES_DATA_MODE ويعاد
ضبط mock الخاص به عند نهاية الجلسة. /addresses و/new و/:addressId/edit
مصنفة بحسب وضع الميزة، ولا تكفي guest/localAccess لفتحها في api.
مصدر اختيار العنوان داخل الحجز هو المصدر نفسه، ويمرر TripLocation snapshot؛
تعديل/حذف العنوان لا يغير رحلة أو مسودة حجز مختارة سابقًا. يتغير السعر
عند اختيار موقع جديد عبر قواعد RideDraftBloc الموجودة.
ترجمات الميزة في fragments الخاصة بها، وبادئتها addresses؛ لا نسخة l10n
جديدة. بحث الأماكن يعاد استخدامه من عقد Ride عبر adapter بيانات، دون
مصدر أماكن مكرر أو GPS حي. الواجهات الأولية تخضع لخطة المرحلتين.
# امتداد W2-SCHEDULE — 2026-11-09

توسع الجدولة الحجز الحالي دون Repository أو Draft موازيين. RideQuote
وTripBookingInput يحملان scheduledAt:DateTime?؛ null فوري، وUTC للمجدولة.
المصدر المشترك MockTripStore ينشئ scheduled عند وجود الموعد وrequested بدونه.
active يشمل scheduled، والإلغاء يحفظ الموعد؛ TripPrefill يبقى موقعين فقط.
RideSchedulePolicy في shared/domain، والتركيب المركزي AppConfig، بحد30 دقيقة
و7 أيام شاملة اختاره المستخدم. وقت العرض UTC+03:00 مستقل عن منطقة الجهاز؛
النقل UTC Z. كل تغيير موعد يبطل السعر، والتأكيد يعيد فحص الحد والتوفر.
النتيجة غير المحسومة تحتفظ بالمفتاح والموعد الأصليين؛ لا تعديل أو تسعير جديد.
نُقل TripWireCodec إلى shared/data ليستعمله تسعير/تأكيد Ride وقراءة Trips
لنفس المورد، مع UTC parser مشترك صارم؛ لا نقل JSON إلى Domain.
حزمة docs/api/scheduling/ امتداد معلن لعقود Ride/Trips القديمة مع Postman.
نفس RIDE_REQUEST_DATA_MODE وحماية الوصول؛ لا API أو dispatch محلي جديد.
