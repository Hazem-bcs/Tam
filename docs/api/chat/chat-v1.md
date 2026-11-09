# عقد محادثة العميل والسائق — v1

الحالة: مقترح للتنفيذ الخلفي، مرحلة أولى. أُعد بتاريخ 2026-11-09؛ لا رسائل فعلية.
النطاق نصوص داخل رحلة واحدة وسائق واحد. لا مرفقات أو typing أو مكالمات أو حذف/تعديل.

## الملكية والهوية

Bearer authentication حقيقي مطلوب لكل API؛ يتحقق الخادم من ملكية trip للعميل في كل عملية.
الضيف وlocalAccess لا يُصدران token ولا يملكان وصول API. أول GET يثبت driver.id في adapter.
كل send/read وGET لاحق يرسل `X-Chat-Driver-Id` من هذا السياق. يقارن الخادم الهوية
ذرّيًا مع حالة الرحلة عند التنفيذ؛ تبدل السائق يعطي409 DRIVER_CHANGED دون إرساله للسابق
أو الجديد ضمن السياق القديم. لا يثق الخادم بزر UI. يجب أن تُفصل الرسائل بمفتاح
customer-session + trip_id + driver_id في الخادم وفي cache؛ لا تعِد بيانات سائق سابق
لسياق جديد. يحتفظ العميل بالهوية الأولى ويرفض تبديلها تلقائيًا.

| حالة الرحلة | قراءة | إرسال |
| --- | --- | --- |
| confirmed / driver_en_route / driver_arrived / in_progress مع سائق | نعم | نعم |
| completed / cancelled مع سائق سابق | سجل سابق فقط | لا؛409 CHAT_CLOSED |
| scheduled / requested / no_driver أو لا سائق | لا؛409 CHAT_UNAVAILABLE | لا |

GET لا ينشئ محادثة باكند أو تعيينًا. الرسائل immutable؛ لا إعادة استخدام id أو sequence.
تأكيد الإرسال لا يثبت تسليمًا أو قراءة، ولا يحول المحاكاة إلى حجز/جلسة حقيقية.

## الشكل المشترك

نجاح `data`، وفشل `error.code` و`error.message.ar/en`، متسقان مع عقد Auth القائم.
راجع JSON الكامل تحت examples. كل response يحمل `metadata` التالية:

| حقل | قاعدة |
| --- | --- |
| version | العدد1، رفض الإصدار غير المدعوم |
| trip_id | نص opaque غير فارغ، مطابق للسياق |
| driver.id / name_ar / name_en | معرف opaque وأسماء عرض غير فارغة |
| revision | integer موجب، متزايد لكل تغيير بالرسائل/الأهلية/receipts، مورد ذري واحد |
| can_send | boolean محسوب لحظة العملية، ليس إذنًا دائمًا |
| delivered_through / read_through | integer >=0؛ read<=delivered؛ لا تراجع |
| customer_read_through | آخر sequence أقره العميل، لا تراجع؛ مستقل عن قراءة السائق |

الرسالة: `id` نص فريد، `sequence` integer موجب متزايد داخل محادثة trip+driver،
`author` من customer/driver، `body` نص محفوظ كما أُرسل بعد trim على الأطراف،
`sent_at` UTC ISO8601 من الخادم مع Z وتاريخ صالح، و`client_message_id` غير فارغ
للعميل وnull للسائق. لا ترتب بالساعة المحلية؛ الترتيب sequence. timestamps غير متراجعة.
حد النص1..1000 Unicode code points بعد trim (ليس UTF16 units أو grapheme clusters).
لا ترجمة لنص المستخدم. Flutter ChatPolicy مالك حد1000 والصفحة30 وpoll5s المركزي.

## GET /trips/{trip_id}/chat/messages

Query `limit=30` فقط حاليًا؛ اختيار before_sequence integer موجب exclusive يعيد أقرب
30 رسالة قبله. الافتراضي أحدث30. `messages` تصاعدية sequence بلا تكرارid/clientid/sequence.
`next_before_sequence` يساوي sequence أول رسالة بالصفحة إن بقي تاريخ أقدم، وإلاnull.
الفراغ `messages:[]` مع cursor:null؛ ليس خطأ ولا نجاح إرسال.
كل صفحة snapshot متسقة مع metadata.revision. الصفحات مستقلة؛ metadata القديمة لا تُرجع
receipts/revision الأحدث في العميل. polling5s/استئناف الصفحة/التحديث اليدوي تدمج أحدث صفحة
مع التاريخ المحمل وتصالح pending بالـclient_message_id. لا يُمحى التاريخ عند خطأ الشبكة.
إذا فات أكثر من30 رسالة بين pollين، يتبع cursor أحدث صفحة لملء الفجوة دون تكرار.

## POST /trips/{trip_id}/chat/messages

JSON: `{"client_message_id":"opaque-random-id","body":"أنا عند المدخل."}`.
الهيدر X-Chat-Driver-Id مطلوب. استجابة200 `data.metadata` و`data.message` مؤكدة؛
المحاكاة لا تدعي HTTP201. المعرّف client-scoped ثابت عبر retry وفقد الرد وإعادة فتح الصفحة.
ينفذ الخادم التخزين والتحقق idempotency وإرسال event داخل معاملة ذرية واحدة؛ المفتاح
customer + trip + driver + client_message_id، محفوظ طوال عمر سجل المحادثة على الأقل.
تكرار نفس المعرف والنص يعيد الرسالة الأصلية id/sequence/timestamp دون رسالة أو side effect ثانية.
نفس المعرف بنص مختلف409 IDEMPOTENCY_CONFLICT. يتحقق الخادم من الملكية وهوية السائق أولًا، ثم يبحث عن معرف الرسالة قبل أهلية كتابة جديدة؛
بعد الإغلاق يعيد نفس الرسالة المقبولة سابقًا دون كتابة جديدة مع metadata.can_send=false.
إذا لم يكن المعرف مقبولًا سابقًا يعيد CHAT_CLOSED. ويمكن GET كذلك أن يصالح النتيجة السابقة.
إذا انقطع الرد بعد قبول الخادم يعرض العميل uncertain ويحفظ النص والمعرف، ويستخدم GET
أو retry بنفسهما. إرسال جديد فقط يولد معرفًا عشوائيًا جديدًا، حتى بعد إعادة فتح الصفحة
والساعة المحلية ثابتة. لا retry تلقائي بلا تمييز عند409/422/429.

## PUT /trips/{trip_id}/chat/read

JSON: `{"through_sequence":3}` مع الهيدر نفسه. نجاح200 `data.metadata`.
0 مسموح no-op، والقيمة لا تتجاوز آخر رسالة موجودة. الخادم يحفظ max(old,through_sequence)،
ويزيد revision فقط عند تغيير فعلي. الإغلاق يسمح بتأكيد قراءة سجل سابق دون إرسال نص.
العميل يقر فقط آخر رسالة ظهرت في الصفحة الحالية وهي resumed وعند الوصول للأحدث؛
تحميل صفحة خلفية أو polling أو قراءة التاريخ لا يعني رؤية رسائل أحدث. خطأ التحميل
يوقف التأكيد. الطلب المتأخر لا يعكس metadata أحدث أو يعيد نصوص جلسة أُغلقت.

## الأخطاء

| HTTP | code | سلوك العميل |
| --- | --- | --- |
| 401 | UNAUTHENTICATED | معالجة الجلسة مركزيًا؛ لا mock fallback |
| 403 | FORBIDDEN | لا عرض لمورد ليس للعميل |
| 404 | TRIP_NOT_FOUND | تعطيل المحادثة |
| 409 | CHAT_UNAVAILABLE / DRIVER_CHANGED / CHAT_CLOSED | تعطيل الإرسال، تحديث الأهلية |
| 409 | IDEMPOTENCY_CONFLICT | لا توليد مفتاح جديد للرسالة نفسها |
| 422 | VALIDATION_ERROR | نص/معرف/حد/ترقيم/sequence غير صالح |
| 429 | RATE_LIMITED | Retry-After بالثواني، مثال5؛ لا نجاح وهمي |
| 503 | SERVICE_UNAVAILABLE | آخر بيانات محفوظة، إعادة محاولة صريحة |

NETWORK_ERROR وINVALID_RESPONSE وSESSION_ENDED أخطاء عميل/محاكاة محلية وليست envelope
HTTP إضافية. timeout بعد POST يعني uncertain حتى المصالحة، وقد تعني أخطاء الشبكة قبل
الإرسال failed عندما يستطيع adapter إثبات عدم القبول. API غير مربوط حاليًا ويعيد503محليًا.

## خريطة التحقق

Collection v2.1 تضم العمليات الأربع والأمثلة saved responses مع errors والتفرغ والترقيم
والإغلاق والقراءة والتسليم. ChatCodec يفحص UTC/version/أنواع/ترتيب/هوية/حدود/cursor.
الاختبارات تفك جميع الأمثلة وتقارن fixture البداية وPOST/read مباشرة مع mock،
وتغطي فقد الرد والتكرار والقراءة المتأخرة والجلسة والسائق والصفحة المغلقة والتجاوب.
التنفيذ الحقيقي للباكند وحمل الشبكة ومعدلات التحديد واستيراد Postman الفعلي خارج التحقق الحالي.

المسودة وpending غير المقبول لا يُحفظان بعد مغادرة الصفحة في هذه الدفعة.
الرسائل التي قبلها الخادم/المحاكاة تستعاد من repository عند إعادة الفتح؛
لا outbox دائم ولا حفظ على القرص. retry داخل الصفحة يحتفظ بالمعرف الأصلي.
