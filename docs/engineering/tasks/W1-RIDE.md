# W1-RIDE — طلب الرحلة

التكليف: منفذ الميزة B، مسند وجاهز للتنفيذ عند وصول هذه البطاقة.
المراجع المستقل يعيّنه المشرف عند التسليم؛ لا تعتمد عملك بنفسك.
مرجع الأساس الثابت: Git tag `tam-w1-baseline-2026-11-07`؛ يجب أن يساوي
SHA الكامل الذي أرسله المستخدم في رسالة التكليف. لا تبدأ من main.
فرعك: `codex/w1-ride-request`. اسم مجلد عمل محلي مقترح:
`/home/hazem/projects/tam-w1-ride-request`، مستقل عن checkout المشرف والبقية.

## إنشاء مساحة العمل

على جهاز المستخدم، نفذ من أي مجلد دون تغيير فرع checkout المشرف:

```bash
git -C /home/hazem/projects/mashwar fetch origin tag tam-w1-baseline-2026-11-07
git -C /home/hazem/projects/mashwar worktree add -b codex/w1-ride-request /home/hazem/projects/tam-w1-ride-request tam-w1-baseline-2026-11-07
```

بعدها نفّذ **كل** قراءة وتعديل وأمر داخل `/home/hazem/projects/tam-w1-ride-request`
باستخدام workdir الأداة، وتحقق من HEAD مقابل SHA رسالة التكليف قبل الكتابة.
إذا كانت المساحة/الفرع موجودين، لا تحذفهما أو reset لهما؛ تحقق من أنهما
تكليفك الصحيح ولا تكتب في مساحة وكيل آخر. عند lock مؤقت من تجهيز وكيل
آخر، أعد المحاولة بعد انتهائه دون حذف lock نشط.

على جهاز آخر، استخدم clone مستقلًا من `git@github.com:Hazem-bcs/Tam.git`،
اجلب tag نفسه وأنشئ فرعك المحدد منه؛ لا يشترط وجود مسار جهاز المستخدم.
إن لم تتوفر أدوات Git/Flutter/الصور، أعلن ذلك وقدّم الأجزاء الممكنة وpatch
مرتبطًا بالأساس وفق القالب بدل الادعاء أنك نفذت الأوامر.

## الاستلام والبداية

اقرأ AGENTS.md ثم agent-onboarding.md والقواعد المرتبطة، وهذه البطاقة،
و[العقود المشتركة](../wave-one-contracts.md) و[سياسة Mock/API](../mock-api-policy.md)
و[متطلبات الباكند](../api-handoff-template.md). افتح الصور بصريًا من
[الفهرس](../design-reference-index.md): **UI-10, UI-11**.
سجّل ما قرأته وSHA/الفرع/المجلد وصورك وأدواتك في تقرير المهمة، ثم ابدأ
التنفيذ دون انتظار موافقة أخرى عندما تتطابق مدخلات التكليف. إن كانت صورة
أو أداة غير متاحة، تقدم في الأجزاء المستقلة واذكر ما يمنع الجزء المعتمد عليها.

## الملكية

- `apps/customer/lib/features/ride_request/**` بما فيه entry وl10n الخاصان بك.
- `apps/customer/test/features/ride_request/**`.
- `docs/api/ride_request/**` و`docs/engineering/deliveries/W1-RIDE/**` فقط.
- الكود المشترك والميزات الأخرى وroot tests وscripts وpubspec وملفات
  المنصات وapp/core وshared وAGENTS ولوحة المهام للقراءة فقط. أي حاجة لتغييرها
  تسجلها كطلب واضح للمشرف في تقريرك؛ لا تكررها داخل ميزتك.
- استثناء مشتقات الترجمة: شغّل أداة الجمع وFlutter gen-l10n محليًا للفحص؛
  لا تعدل النواتج يدويًا ولا تضمها لكوميتك. ارفع ARB fragment المملوك فقط.

## التنفيذ المطلوب

- اختيار الانطلاق والوجهة والبحث عن مكان بمحاكاة محددة، اختيار فئة السيارة، عرض السعر، المراجعة والتأكيد المحاكى.
- اعرض مساحة موقع محاكاة بنفس لغة التصميم، دون الادعاء أنها خريطة حية أو GPS. لا تضف Maps SDK أو permissions أو مفاتيح الآن.
- استخدم GeoPoint/TripLocation/Money/TripBookingInput وTripPrefill المشتركة، وطوّر RideDraftBloc الموجود بدل بناء draft منافس. إعادة الطلب تملأ الموقعين فقط وتعيد التسعير.
- يحدد domain عقود البحث/عرض السعر/التأكيد. تطبيق mock يستخدم mockTrips المحقون لتأكيد الحجز، بنفس Idempotency-Key عند retry. امنع النقر المكرر وانتهاء quote ورفض المدخلات.
- نقدًا هي طريقة الدفع الفعالة بالمحاكاة؛ المحفظة/الكوبون/الجدولة UI-09/الدردشة/مطابقة السائق والتتبع الحي مؤجلة. لا تضف تدفقات موازية أو خصم مال فعلي.
- بعد نجاح التأكيد افتح navigation.openTrip(id) من السجل نفسه، ولا تبن صفحة تفاصيل بديلة.
- استبدل حدود ride_request_entry مع الحفاظ على التوقيع. لا تنشئ MockTripStore في Widget أو Repository بدل المحقون.

## معايير القبول

- لا تأكيد قبل صلاحية الموقعين والفئة وquote؛ ترفض الأسعار المنتهية والفشل ويعمل retry بمفتاح ثابت دون رحلة مكررة.
- رحلة مؤكدة محليًا موجودة فورًا في mockTrips وتقرأها ميزة طلباتي؛ تبقى هوية Auth كما هي.
- اختبارات repository/cubit والـwidgets تشمل prefill، صلاحية المدخلات، quote expiry، double tap/error/retry، الهاتف والتابلت واللغتين والكيبورد.
- Clean Architecture/SOLID/DRY بصورة عملية، الثيم والمكونات المركزية،
  ملفات مكتوبة يدويًا يفضل ألا تتجاوز 300 سطر مع تفسير أي استثناء.
- مصدر البيانات يختار في entry/composition فقط. لا fixtures أو if(mock)
  داخل Page/Cubit؛ في api غير الجاهز استخدم repository يفشل بوضوح
  SERVICE_UNAVAILABLE ولا fallback إلى Mock. لا تنفيذ HTTP حي أو fake Auth.
- تصميم هاتف 320/390 وتابلت 800dp، RTL/LTR، خط 2x، safe areas والكيبورد
  والنص الطويل والرجوع؛ لا تحتاج Android build لكل تعديل صغير.

## تسليم الباكند إلزامي

GET /places، POST /ride-quotes، POST /trips؛ تفاصيل quote expiration وIdempotency-Key. لا تعدّل عمليات قراءة/إلغاء Trips المملوكة لـC.

سلّم داخل docs/api/ride_request/: README.ar.md، ride_request-v1.md،
ride_request-v1.postman_collection.json (v2.1) وأمثلة تطابق fixtures/parsing.
وثق headers/auth والحقول والأنواع/nullable والقيود والنجاح والأخطاء والترقيم
وحالات التعديل، بعقد مقترح للباكند لا ادعاء endpoint قائم. لا أسرار أو
تعديل للعقد الأصلي لـAuth. افحص JSON والعقد والأمثلة وأبلغ بحدود التحقق.

## التحقق والتسليم للمشرف

من جذر المستودع: `python3 scripts/dev/sync_feature_l10n.py`.
من apps/customer: `flutter gen-l10n` ثم
`dart format --output=none --set-exit-if-changed lib test`،
`flutter analyze --no-pub`، `flutter test --no-pub`.
أصلح عيوب نطاقك؛ اذكر فشلًا ناتجًا عن عقد/اختبار مشترك مع خطواته وطلب تغييره
دون حذفه لإظهار نتيجة خضراء. افحص UI فعلية واحفظ الصور ضمن deliveries/W1-RIDE.
نسق أي استخدام للمحاكي عبر المستخدم؛ لا تشغله إذا كان وكيل آخر يستخدمه.

احفظ تقرير HANDOFF.md ضمن deliveries/W1-RIDE: baseline/فرع/SHA، الملفات،
ما اكتمل، أوامر ونتائج فعلية، الصور والبيئة، حزمة API، القيود وطلبات المشترك.
اعمل كوميت بملفاتك المملوكة فقط ورسالة تنتهي [skip ci]، وارفع **فرعك فقط**
إلى origin إن توفرت الصلاحية. هذا التكليف يفوض ذلك؛ لا main ولا merge
ولا Actions ولا force-push. إن تعذر push احتفظ بالكوميت واذكر العائق.
أعد للمستخدم تقريرًا لينقله للمشرف مع SHA النهائي، ثم جمّد نسخة التسليم
للمراجعة. لا تراسل وكلاء أو أطرافًا أخرى دون تفويض، ولا تبدأ مهمة أخرى تلقائيًا.
