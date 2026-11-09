# W2-CHAT — محادثة العميل والسائق

التاريخ2026-11-09، الدور SUPERVISOR؛ تكليف المستخدم بمتابعة المحادثة بنفس
معايير المشروع. الأساس a1199ef952f2f0f94c6088ff32d0609e0ec2b555 نظيف.
الحالة READY ثم IMPLEMENTING بعد تثبيت هذه البطاقة. المشرف يملك التكامل،
ومنفذ مستقل يملك الميزة في codex/w2-chat؛ المراجعة المستقلة عند SHA التسليم.

قُرئت AGENTS.md والبروتوكول وخطة التوازي والاتفاق وADR والثيم والتنقل
وسياسة mock/API ومتطلبات التسليم وخطة المرحلتين واللوحة. فُتح فعليًا UI-13:
apps/customer/Tam Cusstomer UI/WhatsApp Image 2026-11-04 at 3.03.02 PM.jpeg
يعرض ترويسة السائق وفقاعات الرسائل والتوقيت وعلامات القراءة وحقل الإرسال.
Git/Flutter/عرض الصور متاحة؛ لا backend أو اتصال سائق أو رسائل فعلية.

## النطاق والملكية

المنفذ: lib/features/chat/** وtest/features/chat/** وحزمة docs/api/chat/**
وdocs/engineering/deliveries/W2-CHAT/HANDOFF.md وscreenshots/ الخاصة بها.
المشرف فقط: app/router/DI/config/app.dart وActiveTrip entry points، الترجمات
المولدة وsync script، اختبارات app والتكييفات اللازمة في navigation spies،
لوحة المهام والتقدم والبطاقة. لا تغيير Auth/OTP/هاتف/ثيم/منصات/dependencies.

محادثة واحدة مرتبطة بمعرف رحلة وسائق معيّن؛ لا قائمة رحلات أو سائق بديل.
تستخدم MockTripStore مصدر حالة الرحلة، وتعزل الرسائل في MockChatRepository
مملوك للتطبيق؛ لا حالة عامة أو fixture داخل UI/Cubit. الكتابة فقط للحالات
confirmed/driverEnRoute/driverArrived/inProgress مع سائق. قبل التعيين لا محادثة؛
completed/cancelled تقرأ المحادثة السابقة دون إرسال. noDriver لا محادثة.
يحسم repository أهلية كل عملية وقت تنفيذها؛ زر UI ليس قيد الصلاحية الوحيد.
تغيير السائق لا يرسل للهوية السابقة؛ يعرض عدم توفر المحادثة بدل خلطها.

نصوص فقط: trim ثم1..1000 Unicode code points، مع حد مركزي ChatPolicy.
الرسالة لها id/sequence/server timestamp وclient_message_id للعميل؛ معرف
العميل ثابت في retry ويمنع التكرار عند فقد الرد أو إعادة فتح الصفحة.
تظهر sending/failed/uncertain/sent/delivered/read بنص وإشارة مفهومة، ولا تدّعي
القراءة قبل بيانات المستودع. لا retry بمفتاح جديد لنفس الرسالة. الرسالة
المعلقة تحتفظ بالنص ولا تمسح مسودة أحدث عند اكتمال إرسال قديم.
ترتيب رسائل الخادم sequence تصاعدي بلا تكرار؛ أحدث صفحة30 رسالة، وترقيم
أقدم before_sequence مع مؤشر next_before_sequence. polling5s/invalidations
يعيدان دمج أحدث صفحة ويحفظان التاريخ الأقدم ويصالحان pending بحسبclientid.
لا رد قديم يعكس revision أو receipts، وتُحمى الهوية والجلسة وclose/late replies.
قراءة أحدث قائمة بعد استئناف/انقطاع؛ الخطأ يحفظ آخر بيانات دون نجاح وهمي.
تأكيد القراءة لا يتجاوز آخر رسالة معروضة، ويتوقف عند فقد الصفحة/فشل التحميل.

## العقد المتفق عليه

Domain خالص، ChatRepository وChatPolicy وimmutable models/failures.
Repository.fetch(tripId,{beforeSequence}) يعيد metadata وصفحة الرسائل،
send(tripId,{clientMessageId,body}) يعيد رسالة مؤكدة مع metadata محدثة،
markRead(tripId,throughSequence) وchanges للإبطال الاختياري. يجوز اختيار أسماء
أنواع واضحة مع تثبيت signatures للمشرف قبل الربط. لا forwarding use cases.
المدخل registerChatDependencies(GetIt) وbuildChatFeature بإدخال repository،
tripId وChatPolicy وnow، وonBack callback؛ لا اعتماد widget على locator.
MockChatRepository(MockTripStore,{now,scenario}) مع resetSession/dispose؛
UnavailableChatRepository يفشل SERVICE_UNAVAILABLE دون fallback.
AppConfig يملك CHAT_DATA_MODE وChatPolicy وCHAT_MOCK_SCENARIO.

عمليات API المقترحة:
GET /trips/{trip_id}/chat/messages?before_sequence=&limit=30
POST /trips/{trip_id}/chat/messages: client_message_id/body
PUT /trips/{trip_id}/chat/read: through_sequence
لا WebSocket أو typing أو attachments أو مكالمات أو push أو بحث/حذف/تعديل.
العقد envelope data/error.code/message.ar/en وUTC صارم وversion/revision
متزايدة، metadata تتضمن هوية الرحلة/السائق وأهلية الكتابة وreceipt watermarks.
أمثلة النجاح/الفراغ/ترقيم/قراءة/مغلق/خطأ وصلاحيات/429/409/idempotency موثقة.
العقد v1 عربي وREADME وPostman2.1 وfixtures من المحاكاة واختبارات تطابقها.
لا رفع أو استيراد حساب Postman تلقائيًا أو HTTP حي.

## القبول والفحوص

صفحة مركبة من widgets واضحة، ملفات مركزة يفضل<=300 سطر. theme/tokens/Tam
controls/ARB chat*، RTL/LTR، محاذاة bubbles وأوقات/حالات واضحة. عرض النص
كما أرسله صاحبه دون ترجمته. حقل متعدد الأسطر مع حد ونمو طبيعي وإرسال
قابل للوصول على320/390/800 وlandscape وخط2x مع keyboard insets. الحفاظ
على موضع التمرير عند تحميل أقدم، والانتقال لآخر رسالة دون سحب القارئ من
التاريخ عند كلpoll؛ أزرار refresh/load older/scroll newest عند الحاجة.

اختبارات validation/pagination/order/receipts/idempotency/lost response/retry/
readonly/driver identity/session isolation/late read-vs-send/close، والعقد
والتوجيه والربط الحقيقي معActiveTrip والخروج وAPI guard. صور widget renders
مفحوصة فعليًا وفقUI-13، لا ادعاءAndroid أو مطابقة نهائية. format/analyze/full
flutter test وl10n/JSON/diff؛ ثم مراجع مستقل علىSHA نهائي وفحص التكامل.
الصقل النهائي مرحلة ثانية. لا push/main/Actions أوAndroid build/محاكي.
