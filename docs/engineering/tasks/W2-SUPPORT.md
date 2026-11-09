# W2-SUPPORT — الدعم والبلاغات والمحتوى القانوني

الدور SUPERVISOR؛ READY ثم IMPLEMENTING بعد تثبيت البطاقة.
الأساس النظيف `bd24d5993ba8ffe14f2b41d06ba9b3106cf5cdec`، تاريخ2026-11-09.
قُرئت AGENTS.md والبروتوكول وخطة التوازي والاتفاق وADR والثيم والتنقل وسياسة
المحاكاة وتسليم الباكند وخطة المرحلتين. المستخدم كلف إكمال المتبقي ووافق
صراحة على تقييم1..5 مع تعليق اختياري ودعم عام أو بلاغ رحلة؛ المحتوى القانوني
غير منشور حتى يزودنا بالنص المعتمد. الأدواتGit/Flutter/عرض الصور متاحة؛ لاbackend حي.
المعيار مرحلة أولى بواجهة مبدئية موحدة، لا مطابقة بصرية نهائية أو جاهزية نشر.
لا push/main/Actions أوAndroid build/محاكي. المراجع المستقل يكلف عند تسليمSHA.

## الملكية والمراجع

المنفذ implement_support فيcodex/w2-support داخل
/home/hazem/.codex/worktrees/review-w1-integration/mashwar.
يملك features/support/** واختباراتها وحزمة docs/api/support/**
وتسليم docs/engineering/deliveries/W2-SUPPORT/** عداREVIEW.
المشرف يملكapp/config/router/DI/shared/الترجمات المولدة وsync script وSettings/
Trips/ActiveTrip/completion wiring واختباراتApp واللوحة. لا تعارض معcompletion.
UI-08: apps/customer/Tam Cusstomer UI/WhatsApp Image 2026-11-04 at 3.03.00 PM.jpeg
وUI-03: WhatsApp Image 2026-11-04 at 3.02.59 PM (1).jpeg منالمجلدنفسه.
فُتحا فعليًا؛ تظهرروابطالدعم/الشروط/الخصوصيةودعمالرحلة،ولاmockupلداخلها.
الداخلواجهةمبدئيةمتسقةبالثيمبدونادعاءمطابقةمرجعغيرموجود.

## النطاق والسلوك

دعم عام منSettings، أو بلاغ مرتبط بمعرفرحلة منTrips/completion/ActiveTrip.
المستودع يتحقق منوجودالرحلة فيMockTripStore لكلعمليةذاتtripId، لا قائمة
رحلات مكررة. generic يتيح فئاتغيرمرتبطةفقط؛ formفيtripcontext يتيح فئات
الرحلة والعام حسبcatalog. catalog يحتويid/اسمar/en وtripRequired؛ لا شروط
خدمة/قنوات اتصال أو وعوداستجابة أو هاتف/بريد/واتساب مختلقة.

قائمةطلباتيالدعم بترقيم20، تفاصيلالطلبوحالته ونصه وتاريخه، إرسالطلب
بنصtrim من10إلى2000codepoints وفئةصالحة، وtripId اختياريحسبفئتها.
SupportPolicy مركزي. لا مرفقات أو دردشةدعم أوتعديل/إغلاقبطرفالعميل أوSLA
مخترع. الحالاتopen/in_progress/resolved مصدرهاالخادم؛ defaultmock يبدأفارغًا
والطلباتالجديدةopen، ولايدّعينظرموظفحقيقي. أمثلةالحالاتواختباراتها مطلوبة.

client_request_id عشوائيآمن ثابت عبرretry وفقدالرد؛ نفسpayload/المعرف
يعيدنفسالتذكرة، والمختلف409IDEMPOTENCY_CONFLICT. unresolvedيقفلpayload
حتىحسمGET/listبمعرفالعميل أوretryنفسه؛ تحققack منالسياقوالنصوالفئةوالمعرف.
لا تكرارمتزامن،ولاresponseقديميرجعstateأحدثأويرجعنصوصجلسةسابقة.
مصدرMockSupportRepository واحدمملوكللتطبيق يبقىعندغلقالصفحة، ويُصفّربالخروج.
المسودة/غيرالمقبول لعمرالصفحة دونoutboxدائم؛Acceptedمستعادمنrepository.

الشروطوالخصوصية: صفحاتقراءةعامة، لكنالمحتوىغيرمنشورحتىيوفرهالمستخدم.
Mock يعيدunavailable/null معرسالةصريحة،لا تكتبنصًاقانونيًا أو ادعاءموافقة.
الترجمةلهذاالغرضمنARB،ولاWebView أو تنفيذHTML/URL arbitrary. يجوزنموذج
LegalDocument بplainText/version/publishedAt للمحتوىالمعتمدالمستقبلي،واختباره
بـtest double محلي فقط،لكنdefaultdata/mockلايعرضنصًاكأنهسياسةمعتمدة.
لا إقرارقبول أوtrackingقانوني جديدفيAuth. APIlegalعامبلاBearer،ticketsمحمي.

## الحدود والعقد للربط

Domain خالص SupportRepository/SupportPolicy وimmutablemodels/failures.
options({String?tripId}) -> SupportOptions (فئاتوسياقtripIdمتحقق)،
tickets({String?cursor}) -> SupportTicketPage،ticket(Stringid)->SupportTicket،
create({requiredStringclientRequestId,requiredStringcategoryId,requiredStringbody,
String?tripId})->SupportTicket؛legal(LegalDocumentKind,{requiredStringlanguageCode})
->LegalDocument?؛ Stream<SupportChange>changes معsessionReset.
LegalDocumentKind terms/privacy enum يصدرهsupport_entry للمشرف.
MockSupportRepository(MockTripStore,{now,policy,scenario}) وresetSession/dispose؛
SupportMockScenario.parse success/empty/offline/lost_response،وUnavailableSupportRepository.
المدخل registerSupportDependencies(GetIt) و
buildSupportFeature(repository,policy,now,onBack,onCreate,onTicket,onChooseTrip)
buildSupportEditorFeature(repository,policy,now,tripId,onBack,onCreated)
buildSupportTicketFeature(repository,id,onBack)
buildLegalFeature(repository,kind,languageCode,onBack).
ثبتsignaturesوالـimportsللمشرفمبكرًا؛ widgetsلاlocatorأوIO،وfactoryParamمستخدمفعليًا.
keys support-new-ticket/support-body/support-category/support-submit/support-retry.
SUPPORT_DATA_MODE يرثDATA_MODE وSUPPORT_MOCK_SCENARIO فيAppConfig.

API مقترحة: GET /support/options?trip_id=،GET /support/tickets?cursor=&limit=20،
GET /support/tickets/{id}،POST /support/tickets:client_request_id/category_id/body/trip_id،
GET /content/legal/{kind}?language=ar|en عامبلاauth. Legalnull يعنينصغيرمنشور.
كلticketsauth/ownership،Envelope/Timestamps/IDs/errorsمتسقةمعAuth؛
UTC/version/revision/pagination وترتيبالقائمةوقواعدالفئاتواضحةومختبرة.
حزمةsupport-v1.md وREADME.ar.md وPostman2.1 وأمثلةمطابقةmock/parser
للنجاحوالفراغوالترقيموالـreadonlylegalnullوالأخطاء401/403/404/409/422/429/503.
لاطلباتحيةأواستيرادخارجيأورفعPostman.

## القبول والفحوص

ثيموتوكنزومكوناتTamوARB support*،صفحاتمركبةوملفاتمركزةيفضل<=300.
حالاتloading/empty/error/offline/retry/disabled/success/uncertainوحفظالمحتوى
القديمعندالفشل،معsemanticsوتجاوب320/390/800/landscape وخط2x والكيبوردواللغتين.
اختباراتpagination/idempotency/late reads/close/logout/validation/ownership/
foreigntrip/unknowncategory/invalidack/codec/Postman/legalunavailable.
صورفعليةwidgetrendersمفتوحةومراجعة،ثمformat/analyze/fulltests/l10n/JSON/diff
وتسليمSHAمجمّدومراجعةمستقلةوفحصالتكامل.الصقلالبصريمرحلةثانية.

## تحديث تسليم المشرف — 2026-11-09

الحالة REVIEW؛ المنفذ الأصلي توقف برسالة usage limit. حُفظت تغييراته
المملوكة في كوميت وجُمعت إلى فرع التكامل؛ أكمل المشرف النواقص والعقود
والتحقق بنفسه. المرشح `7c040f7d9954033530d724237d382780b563bbea`
على codex/w2-final-features-integration؛569 اختبارًا ناجحًا، analyze نظيف،
format307/0 و76 اختبار مقارنة UI ناجحًا دون تحديث.
التسليم: docs/engineering/deliveries/W2-SUPPORT/HANDOFF.md.
المراجعة المستقلة معلقة وغير مسندة؛ لا اعتماد أو دمج نهائي. بطاقة
W2-FINAL-REVIEW تراجع الميزتين والتغييرات المشتركة على SHA واحد.
