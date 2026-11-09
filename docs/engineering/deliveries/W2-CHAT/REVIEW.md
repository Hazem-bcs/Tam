# W2-CHAT — مراجعة مستقلة

التاريخ: 2026-11-09. الدور: REVIEWER مستقل عن منفذ الميزة والمشرف الذي ربطها.
الحكم: **APPROVED_AT_SHA `5eb9d0eb2800d9152b508857469e9365b8ae8c8a`** للمرحلة الأولى.
كوميت هذا التقرير لاحق وتوثيقي فقط؛ لا يغير الشجرة البرمجية المعتمدة.

## النسخة والملكية

- الأساس الوظيفي: `a1199ef952f2f0f94c6088ff32d0609e0ec2b555`.
- مدخل المراجعة النظيف: `99b364488da6275aabef52cace5296e634084780`.
- تنفيذ الميزة: `8bf7964ef13e653399ada51c9e81f310aa090c88`؛ تسليم المنفذ `30b2866`.
- الفرع: `codex/review-w2-chat`.
- مكان العمل: `/home/hazem/.codex/worktrees/review-w1-integration/mashwar` فقط.
- إصلاح السلوك واختباراته: `c63bd92`؛ إصلاح حزمة Postman واختبار اتساقها: `5eb9d0e`.

راجعت diff كامل الأساس إلى مدخل المراجعة، بما فيه Domain/Data/Mock/Codec/Cubit/UI،
والربط المشترك في routes/config/DI/TamApp/session، ومدخل ActiveTrip، والترجمات،
واختبارات التطبيق الأربعة، وملفات العقد وPostman والأمثلة العشرين. قرأت AGENTS.md،
وبروتوكول agent-task-template، وخطة parallel-work، وبطاقة tasks/W2-CHAT، وHANDOFF،
والاتفاق وADR 0001 والثيم والتنقل وmock-api-policy وapi-handoff-template وخطة المرحلتين.
البطاقة والتسليم تحت `docs/engineering/`، وليس مجلد tasks في الجذر.

ملكية الإصلاح اقتصرت على عيوب محددة في الميزة واختباراتها وحزمة `docs/api/chat/`
وهذا التقرير. لم أعدل لوحة المهام أو customer-ui-progress أو checkout الجذر.
أدوات Git وFlutter/Dart وقراءة الملفات وعرض الصور متاحة فعليًا. لا backend حي؛
لم أشغّل Android build أو محاكيًا أو Actions، ولم أنفذ push أو دمجًا إلى main.

## العيوب المثبتة والمصححة

جميع البنود التالية P2، وحُلت في النسخة المعتمدة؛ لا توجد ملاحظة مانعة متبقية.

1. **تعليق تحميل التاريخ بعد تعليق التطبيق.** في `chat_cubit.dart:169` وما يتبعه،
   كان رد loadOlder يصل أثناء inactive فيُهمل وتبقى loadingOlder=true حتى بعد resume.
   أصبحت دورة النشاط تبطل طلبات التاريخ القديمة وتحرر التحميل؛ يظل cursor قابلًا لإعادة المحاولة.
2. **فقد مؤشر فجوة جديدة بسباق طلبين.** يبدأ loadOlder قبل50، ثم يكشف refresh
   صفحة100..129 وفجوة80..99، ثم يعيد رد التاريخ المتأخر cursor=20 ويخفي الفجوة.
   في `chat_cubit.dart:181` لا يُستبدل المؤشر إلا إذا بقي هو مؤشر الطلب الأصلي.
3. **خطأ هوية من طلب تاريخ قديم يحجب snapshot أحدث.** كان DRIVER_CHANGED متأخر
   من loadOlder يثبت `_identityLost` بعد نجاح refresh أحدث. تحرس `chat_cubit.dart:185`
   هوية طلب التاريخ وتسلسل التحديث قبل تثبيت الخطأ. حراسة refresh الأصلية نفسها سليمة.
4. **تأكيد إرسال متقدم يخفي فجوة polling.** تاريخ1..30 ثم send ack عند100 ثم
   GET71..100 كان يترك cursor=null. تقارن `chat_cubit.dart:112` أول الصفحة بآخر
   رسالة تسبقها، فلا يخفي ack المتقدم الرسائل31..70، وتظل قابلة للاسترجاع بالترقيم.
5. **تأكيد قراءة رسالة غير مرئية خلف pending طويل.** كان offset=0 كافيًا لقراءة
   آخر accepted message حتى لو ملأ pending الطويل مساحة القائمة وحجب رسالة السائق.
   تفحص `chat_page.dart:52` تقاطع آخر رسالة مقبولة مع مساحة القائمة بعد الرسم، إضافة
   إلى current/resumed/newest والحراس القائمة. يمرر ChatTimeline مفتاح الرسالة للقياس.
6. **هيدر هوية السائق ناقص في Postman GET.** طلب التاريخ الأقدم لم يرسل
   X-Chat-Driver-Id رغم اشتراطه بعد أول قراءة في العقد. أضيف مفعّلًا للأقدم، ومعطلًا
   افتراضيًا لأول GET للأحدث مع تعليمات تفعيله بعد تثبيت driver_id. حدثت originalRequest
   في saved responses وREADME، ويختبر العقد اتساق الهيدر والطلبات المحفوظة.

أضيفت أربع حالات في `chat_cubit_pagination_test.dart` وحالتان في
`chat_visibility_test.dart`. شُغلت حالات الترقيم الأربع على Cubit الأصلي عمدًا:
فشلت الأربع بالأعراض أعلاه، ثم نجحت بعد الإصلاح. وأثبت اختبار الظهور فشل receipt
قبل الإصلاح، ثم نجاحه مع بقاء التأكيد الطبيعي عند ظهور الرسالة بعد المصالحة.
اختبار anchor مرئي مع رسالة وافدة طويلة نجح في السلوك الأصلي؛ يقارن مفتاح الرسالة
وموضعها dy ضمن1dp، لذلك لم أغير منطق تثبيت التمرير بلا دليل على عيب.

## نتيجة مراجعة السلوك والحدود

حدود الطبقات وحقن الاعتماديات ملائمة، وDomain خالٍ من Flutter/transport/storage.
المحاكاة في data/mock وتستمد أهلية كل عملية من مصدر الرحلات المشترك، مع تثبيت هوية
السائق وعدم تحويل تغيرها إلى إرسال لسائق آخر. إعادة المحاولة تحفظ المعرف والنص؛
فقد الرد يصالح الرسالة المقبولة دون تكرار، والإغلاق يمنع كتابة جديدة مع إتاحة التاريخ.
المراسلات immutable وترتب sequence، ولا تعكس الردود القديمة revision/receipts الأحدث.
تُحفظ البيانات السابقة عند الخطأ، وتُحمى الردود المتأخرة عند close/resetSession.

ربط TamApp يملك المستودع ويصفره عند خروج الجلسة ويحرر موارده. حارس chat مستقل
عن أوضاع الميزات المجاورة؛ guest وlocalAccess لا يفتحان API، وAPI غير المتاح يفشل
بوضوح دون mock fallback أو إنشاء credentials. اختبارات التطبيق تمارس الحجز والتعيين
والإرسال وإعادة الفتح والإلغاء والقراءة فقط والخروج والجلسة الجديدة، إضافة إلى حراسة API.

المسودة وpending غير المقبول مرتبطان بعمر الصفحة باتفاق البطاقة؛ لا outbox دائم
مطلوب الآن. الرسائل المقبولة تستعاد من repository. المحاكاة ضمن عمر عملية التطبيق،
والربط الحي والتخزين الدائم والتفويض الخادمي اختبارات ومهام لاحقة. حزمة v1 مقترحة،
وليست وصفًا لخادم مختبر حيًا. Cubit الآن355 سطرًا بعد حراس الإصلاح؛ أبقيت استثناء
الدورة async المتماسكة المفسر في HANDOFF، دون ضغط التنسيق أو تقسيم شكلي.

## الفحوص المنفذة

البيئة: Linux محلي، Flutter3.41.4 stable، Dart3.11.1. أوامر Flutter من `apps/customer`.

| الأمر/الفحص | النتيجة الفعلية |
| --- | --- |
| `dart format --output=none --set-exit-if-changed lib test` |257 ملفًا،0 تغيير |
| `flutter analyze --no-pub` |بلا ملاحظات |
| `flutter test --no-pub` |468 PASS بعد الإصلاح؛462 PASS على input قبل الإصلاح |
| `flutter test --no-pub test/features/chat` |55 PASS |
| `flutter test --no-pub --dart-define=CAPTURE_CHAT_UI=true test/features/chat/chat_widget_test.dart` |17 PASS، مقارنة فقط دون update؛23 صورة |
| `flutter test --no-pub --dart-define=CAPTURE_ACTIVE_TRIP_UI=true test/features/active_trip/active_trip_widget_test.dart` |15 PASS، مقارنة فقط دون update؛19 صورة |
| `python3 scripts/dev/sync_feature_l10n.py --check` من الجذر |متزامن |
| `flutter gen-l10n` |نجح؛ لم يغير المخرجات المولدة |
| `json.loads` لكل `docs/api/chat/**/*.json` |21 ملفًا صالحًا؛20 مثالًا وCollection |
| `git diff --check` |سليم |
| مقارنة مخرجات l10n وgoldens وصور التسليم بـinput |لا اختلاف |

سجلات التنفيذ المؤقتة: `/tmp/w2-chat-review-final-full.log`،
`/tmp/w2-chat-review-feature-after.log`، `/tmp/w2-chat-review-chat-goldens.log`،
`/tmp/w2-chat-review-active-goldens.log`، و`/tmp/w2-chat-review-pagination-before.log`.
فُحصت بنية Collection والأمثلة باختبارات العقد؛ لم أدع استيرادها في تطبيق Postman
أو تنفيذ HTTP حي. إعادة gen-l10n لم تضف تغييرات مشتركة.

## الفحص البصري الفعلي

فتحت UI-13 الأصلي فعليًا:
`apps/customer/Tam Cusstomer UI/WhatsApp Image 2026-11-04 at 3.03.02 PM.jpeg`.
راجعت جميع23 صورة في `docs/engineering/deliveries/W2-CHAT/screenshots/` بعرضها في
contact sheets فعلية، مع مراجعة الأصل: مجموعات conversation وkeyboard باللغتين
ar/en عند320×640/2x،390×844/1x،800×1000/2x،800×390/1x، وحالات
state-empty/loading/disconnect/sendFailure/lostResponse/read-only/read-receipt.

فتحت كذلك جميع19 صورة حالية في `apps/customer/test/features/active_trip/goldens/`:
arrived، cancelled، completed، confirmed، dispatched، en-route، in-progress، no-driver،
offline، requested، scheduled؛ وdriver-ar-320-x2، driver-ar-800-x1،
driver-en-390-x1، driver-en-800-x2، وresponsive-ar-320-x2، responsive-ar-800-x1،
responsive-en-390-x1، responsive-en-800-x2. تشمل مدخل المحادثة وحوار السائق
المتأثرين؛ صور التسليم التاريخية لActiveTrip ليست دليل النسخة الحالية.

الواجهة تستعمل الثيم المركزي والتوكنات وARB، وتعرض حالات الرسائل بالنص والأيقونة.
محاذاة العميل يمينًا والسائق يسارًا متسقة مع المرجع، والنص الأصلي لا يترجم.
الصور واختبارات القيود تؤيد قابلية الاستخدام مع RTL/LTR والخط الكبير والكيبورد
والهاتف/التابلت/landscape، مع قابلية تمرير التاريخ والحقل والحوار عند الضيق.
أدلة renderer تستخدم خطوط preview محلية وMaterialIcons؛ لا Android/IME حقيقي
أو فحص screen reader على جهاز. لا ادعاء لتمام المطابقة البصرية أو release readiness.

صقل ذيول الفقاعات والخطوط والمسافات وتجميع التواريخ وتوزيع الرسائل القصيرة يؤجل
للمرحلة الثانية كما هو مسجل في HANDOFF. لا عائق مشترك مفتوح ضمن نطاق هذه المراجعة.
