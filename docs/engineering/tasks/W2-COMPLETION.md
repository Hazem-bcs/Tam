# W2-COMPLETION — ملخص الرحلة والتقييم

الحالة الحالية INTEGRATED للمرحلة الأولى؛ مراجعة W3 الشاملة اعتمدت511ca9c،
ودُمج محليًا عند0409a37 ثم التقريرb775ccc؛625 اختبارًا بعد الدمج.
[المراجعة المستقلة](../deliveries/W3-ACCOUNT-CONTACT/REVIEW.md).
السطور التالية تحفظ بطاقة التنفيذ الأصلية ومدخلاتها.

الدور SUPERVISOR؛ READY ثم IMPLEMENTING بعد تثبيت البطاقة.
الأساس النظيف `bd24d5993ba8ffe14f2b41d06ba9b3106cf5cdec`، تاريخ2026-11-09.
قُرئت AGENTS.md والبروتوكول وخطة التوازي والاتفاق وADR والثيم والتنقل وسياسة
المحاكاة وتسليم الباكند وخطة المرحلتين. المستخدم كلف إكمال المتبقي ووافق
صراحة على تقييم1..5 مع تعليق اختياري ودعم عام أو بلاغ رحلة؛ المحتوى القانوني
غير منشور حتى يزودنا بالنص المعتمد. الأدواتGit/Flutter/عرض الصور متاحة؛ لاbackend حي.
المعيار مرحلة أولى بواجهة مبدئية موحدة، لا مطابقة بصرية نهائية أو جاهزية نشر.
لا push/main/Actions أوAndroid build/محاكي. المراجع المستقل يكلف عند تسليمSHA.

## الملكية والمراجع

المنفذ implement_completion في codex/w2-completion داخل
/home/hazem/.codex/worktrees/review-w2-addresses/mashwar.
يملك features/completion/** واختباراتها وحزمة docs/api/completion/**
وتسليم docs/engineering/deliveries/W2-COMPLETION/** عداREVIEW.
المشرف فقط يملك app/config/router/DI/shared/الترجمات المولدة وsync script
وActiveTrip/Trips/Settings ومدخل الدعم واختباراتApp واللوحة.
المرجع UI-03: apps/customer/Tam Cusstomer UI/WhatsApp Image 2026-11-04 at 3.02.59 PM (1).jpeg.
فُتح فعليًا؛ يوجد ملخص بيانات وأجرة ودعم، ولا صورة أصلية كاملة للتقييم.
يُصمم التقييم مبدئيًا بمكونات الثيم؛ لا نستعير صفحات السائق.

## السلوك والحدود

المصدر Trip/MockTripStore نفسه، لا قائمة رحلات موازية أو تغيير حالة العميل
إلىcompleted. العرض والتقييم متاحان فقط TripStatus.completed، حتى التاريخ
القديم دونlive؛ هذا تقييم تجربة الرحلة، وليس اشتراط تقييم سائق بهوية مخترعة.
ملخص مواقع ومعرف وتاريخ وحالة ومبلغ الطلب منbooking.fare؛ بيانات السائق
اختيارية منlive إن وجدت. لا claim دفع أو إيصال ضريبي أو مبلغ نهائي معدّل،
ولا خصم/رسوم/مسافة/مدة مختلقة. السعر المعروض هو مبلغ الطلب المسجل.

تقييم واحد immutable لكل رحلة،1..5نجوم وتعليق اختياري trim بحد500codepoints
فيCompletionPolicy مركزي. يُعرض التقييم المحفوظ بدل نموذج قابل للتعديل.
مفتاح idempotency عشوائي آمن مستقل عنclock وعمرCubit؛ نفسالمفتاح/النص/النجوم
يعيد نفسالمورد، ونفسالمفتاح معpayload مختلف409IDEMPOTENCY_CONFLICT.
مفتاح جديد لرحلةمقيّمة409RATING_ALREADY_SUBMITTED؛ لا تعديل/حذف/تخطي مصطنع.
فقد الرد يبقي intent ثابتًا وغيرقابلللتعديل، ويحسم GET أوretryنفسالمفتاح.
القراءات/الإقرارات المتأخرة لا تعكس إصدارًا أحدث أو تخلط هوية رحلة أوجلسة.
تحقق ack منمطابقة intent/المعرف/الهوية، ومنعإرسال مكرر متزامن.
الخروجيمسح تقييمات المحاكاة وينهي الصفحات؛ المقبول يستعاد عندإعادةالفتح
داخل جلسةالمستودع. المسودة/غيرالمقبول مرتبطان بعمرالصفحة،لاoutboxدائم.

## الحدود والعقد الثابت للربط

Domain خالص: CompletionRepository وCompletionPolicy وimmutable models/failures.
fetch(String tripId) -> TripCompletion، submitRating(String tripId,
{required int stars, required String comment, required String idempotencyKey})
-> TripCompletion، Stream<CompletionChange>changes يحملsessionReset.
TripCompletion يضمTrip وTripRating? وrevision متزايد؛ canRate مشتق منcompleted
وعدموجودrating. يجوز اختيارنموذجfocusآخرمع تثبيت الأسماء مبكرًا للمشرف.
MockCompletionRepository(MockTripStore,{now,policy,scenario}) معresetSession/dispose.
CompletionMockScenario.parse يدعمsuccess/offline/lost_response؛ لاswitchداخلUI.
UnavailableCompletionRepository يفشلSERVICE_UNAVAILABLE دونfallback.
completion_entry.dart: registerCompletionDependencies(GetIt) factoryParam مستخدم،
buildCompletionFeature({repository,tripId,policy,now,onBack,onSupport,onHome}).
UI keys completion-stars-1..5، completion-comment، completion-submit، completion-retry.
مدخل المشرف منActiveTripCompleted وتفاصيلTripsCompleted فقط؛ لا auto-navigation
يقطع صفحة أخرى أو نموذجًا. onSupport يفتح دعم الرحلة نفسها.
COMPLETION_DATA_MODE مستقل ويرثDATA_MODE، والسياسة والسيناريو فيAppConfig.

GET /trips/{trip_id}/completion، POST /trips/{trip_id}/rating:
JSON stars/comment وheader Idempotency-Key؛ auth/ownership فيكلعملية.
envelope data/error.code/message.ar/en،UTC/TripWireCodec المشترك حيثيلزم،
version/revision، تأكيدnot-completed/duplicate/conflict/validation/401/403/404/429/503.
حزمةعربيةv1 وREADME.ar.md وcompletion-v1.postman_collection.json وأمثلةمنmock
واختباراتتطابقها. لا backend فعلي أو رفعPostman.

## القبول والفحوص

صفحةمركبةوwidgetsمركزة يفضل<=300، ثيم/توكنز/Tam/ARB completion*.
تحميل/فراغمناسب/خطأ/readonly/success/uncertain؛ نجوم ذاتsemantics وtouch48
وتعليقاتmultilineبتمرير،320/390/800/landscape وخط2x وRTL/LTR والكيبورد.
اختباراتvalidation/idempotency/lost response/reload/late replies/close/session/
identity/invalidack وcodec/Postman؛ صورwidget renders فعليةمفتوحةومراجعة.
format/analyze/fulltests وl10n/JSON/diff، ثمSHA وتسليمومراجع مستقل وفحصالمجموع.

## تحديث تسليم المشرف — 2026-11-09

كانت الحالة REVIEW عند تسليم التنفيذ؛ المنفذ الأصلي توقف برسالة usage limit. حُفظت تغييراته
المملوكة في كوميت وجُمعت إلى فرع التكامل؛ أكمل المشرف النواقص والعقود
والتحقق بنفسه. المرشح `7c040f7d9954033530d724237d382780b563bbea`
على codex/w2-final-features-integration؛569 اختبارًا ناجحًا، analyze نظيف،
format307/0 و76 اختبار مقارنة UI ناجحًا دون تحديث.
التسليم: docs/engineering/deliveries/W2-COMPLETION/HANDOFF.md.
كانت المراجعة معلقة آنذاك؛ استوعبتها W3-CUSTOMER-REVIEW لاحقًا وانتهت
بالاعتماد والدمج المسجلين في أول هذه البطاقة.
